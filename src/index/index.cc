#include <sourcemeta/core/build.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/options.h>
#include <sourcemeta/core/parallel.h>

#include <sourcemeta/registry/configuration.h>
#include <sourcemeta/registry/resolver.h>
#include <sourcemeta/registry/shared.h>

#include "explorer.h"
#include "generators.h"
#include "output.h"
#include "web.h"

// TODO: Revise these includes
#include <cassert>     // assert
#include <cstdlib>     // EXIT_FAILURE, EXIT_SUCCESS
#include <exception>   // std::exception
#include <filesystem>  // std::filesystem
#include <iomanip>     // std::setw, std::setfill
#include <iostream>    // std::cerr, std::cout
#include <span>        // std::span
#include <string>      // std::string
#include <string_view> // std::string_view
#include <utility>     // std::move
#include <vector>      // std::vector

// We rely on this special prefix to avoid file system collisions. The reason it
// works is that URIs cannot have "%" without percent-encoding it as "%25", and
// the resolver will not unescape it back when computing the relative path to an
// entry
constexpr auto SENTINEL{"%"};

static auto attribute_not_disabled(
    const sourcemeta::registry::Configuration::Collection &collection,
    const sourcemeta::core::JSON::String &property) -> bool {
  return !collection.extra.defines(property) ||
         !collection.extra.at(property).is_boolean() ||
         collection.extra.at(property).to_boolean();
}

static auto attribute_enabled(
    const sourcemeta::registry::Configuration::Collection &collection,
    const sourcemeta::core::JSON::String &property) -> bool {
  return collection.extra.defines(property) &&
         collection.extra.at(property).is_boolean() &&
         collection.extra.at(property).to_boolean();
}

static auto print_progress(std::mutex &mutex, const std::size_t threads,
                           const std::string_view title,
                           const std::string_view prefix,
                           const std::size_t current, const std::size_t total)
    -> void {
  const auto percentage{current * 100 / total};
  std::lock_guard<std::mutex> lock{mutex};
  std::cerr << "(" << std::setfill(' ') << std::setw(3)
            << static_cast<int>(percentage) << "%) " << title << ": " << prefix
            << " [" << std::this_thread::get_id() << "/" << threads << "]\n";
}

template <typename Handler, typename Adapter>
static auto
DISPATCH(const std::filesystem::path &destination,
         const sourcemeta::core::BuildDependencies<typename Adapter::node_type>
             &dependencies,
         const typename Handler::Context &context, std::mutex &mutex,
         const std::string_view title, const std::string_view prefix,
         const std::string_view suffix, Adapter &adapter,
         sourcemeta::registry::Output &output) -> void {
  if (!sourcemeta::core::build<typename Handler::Context>(
          adapter, Handler::handler, destination, dependencies, context)) {
    std::lock_guard<std::mutex> lock{mutex};
    std::cerr << "(skip) " << title << ": " << prefix << " [" << suffix
              << "]\n";
  }

  // We need to mark files regardless of whether they were generated or not
  output.track(destination);
  output.track(destination.string() + ".deps");
}

static auto index_main(const std::string_view &program,
                       const sourcemeta::core::Options &app) -> int {
  std::cout << "Sourcemeta Registry v" << sourcemeta::registry::version();
#if defined(SOURCEMETA_REGISTRY_ENTERPRISE)
  std::cout << " Enterprise ";
#elif defined(SOURCEMETA_REGISTRY_PRO)
  std::cout << " Pro ";
#else
  std::cout << " Starter ";
#endif
  std::cout << "Edition\n";

  if (app.positional().size() != 2) {
    std::cout << "Usage: " << std::filesystem::path{program}.filename().string()
              << " <registry.json> <path/to/output/directory>\n";
    return EXIT_FAILURE;
  }

  /////////////////////////////////////////////////////////////////////////////
  // (1) Prepare the output directory
  /////////////////////////////////////////////////////////////////////////////

  sourcemeta::registry::Output output{app.positional().at(1)};
  std::cerr << "Writing output to: " << output.path().string() << "\n";

  /////////////////////////////////////////////////////////////////////////////
  // (2) Process the configuration file
  /////////////////////////////////////////////////////////////////////////////

  const auto configuration_path{
      std::filesystem::canonical(app.positional().at(0))};
  std::cerr << "Using configuration: " << configuration_path.string() << "\n";
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, SOURCEMETA_REGISTRY_COLLECTIONS)};
  auto configuration{
      sourcemeta::registry::Configuration::parse(raw_configuration)};

  /////////////////////////////////////////////////////////////////////////////
  // (3) Support overriding the target URL from the CLI
  /////////////////////////////////////////////////////////////////////////////

  if (app.contains("url")) {
    std::cerr << "Overriding the URL in the configuration file with: "
              << app.at("url").at(0) << "\n";
    sourcemeta::core::URI url{std::string{app.at("url").at(0)}};
    if (url.is_absolute() && url.scheme().has_value() &&
        (url.scheme().value() == "https" || url.scheme().value() == "http")) {
      // TODO: Write a test that covers URL overriding
      configuration.url =
          sourcemeta::core::URI::canonicalize(std::string{app.at("url").at(0)});
    } else {
      std::cerr << "error: The URL option must be an absolute HTTP(s) URL\n";
      return EXIT_FAILURE;
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  // (4) Store a mark of the Registry version for target dependencies
  /////////////////////////////////////////////////////////////////////////////

  // We do this so that targets can be re-built if the Registry version changes
  const auto mark_version_path{output.path() / "version.json"};
  // Note we only write back if the content changed in order to not accidentally
  // bump up the file modified time
  output.write_json_if_different(
      mark_version_path,
      sourcemeta::core::JSON{sourcemeta::registry::version()});

  /////////////////////////////////////////////////////////////////////////////
  // (5) Store the full configuration file for target dependencies
  /////////////////////////////////////////////////////////////////////////////

  // For targets that depend on the contents of the configuration or on anything
  // potentially derived from the configuration, such as the resolver
  const auto mark_configuration_path{output.path() / "configuration.json"};
  // Note we only write back if the content changed in order to not accidentally
  // bump up the file modified time
  output.write_json_if_different(mark_configuration_path, raw_configuration);

  /////////////////////////////////////////////////////////////////////////////
  // (6) First pass to locate all of the schemas we will be indexing
  // NOTE: No files are generated. We only want to know what's out there
  /////////////////////////////////////////////////////////////////////////////

  sourcemeta::registry::Resolver resolver;
  // This step is very fast, so going parallel about it seems overkill, even
  // though in theory we could
  for (const auto &pair : configuration.entries) {
    const auto *collection{
        std::get_if<sourcemeta::registry::Configuration::Collection>(
            &pair.second)};
    if (!collection) {
      continue;
    }

    for (const auto &entry : std::filesystem::recursive_directory_iterator{
             collection->absolute_path}) {
      if (!entry.is_regular_file()) {
        continue;
      }

      const auto extension{entry.path().extension()};
      // TODO: Allow the configuration file to override this
      const auto looks_like_schema_file{
          extension == ".yaml" || extension == ".yml" || extension == ".json"};
      if (!looks_like_schema_file) {
        continue;
      }

      std::cerr << "Detecting: " << entry.path().string() << " (#"
                << resolver.size() + 1 << ")\n";

      // See https://github.com/sourcemeta/registry/blob/main/LICENSE
#if defined(SOURCEMETA_REGISTRY_PRO)
      constexpr auto SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_PRO{1000};
      if (resolver.size() >= SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_PRO) {
        std::cerr << "error: The Pro edition is restricted to "
                  << SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_PRO << " schemas\n";
        std::cerr << "Upgrade to the Enterprise edition to waive limits\n";
        std::cerr << "Buy a new license at https://www.sourcemeta.com\n";
        return EXIT_FAILURE;
      }
#elif defined(SOURCEMETA_REGISTRY_STARTER)
      constexpr auto SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_STARTER{100};
      if (resolver.size() >= SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_STARTER) {
        std::cerr << "error: The Starter edition is restricted to "
                  << SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_STARTER << " schemas\n";
        std::cerr << "Buy a Pro or Enterprise license at "
                     "https://www.sourcemeta.com\n";
        return EXIT_FAILURE;
      }
#endif

      const auto mapping{resolver.add(configuration.url, pair.first,
                                      *collection, entry.path())};
      // Useful for debugging
      if (app.contains("verbose")) {
        std::cerr << mapping.first.get() << " => " << mapping.second.get()
                  << "\n";
      }
    }
  };

  /////////////////////////////////////////////////////////////////////////////
  // (7) Do a first analysis pass on the schemas and materialise them for
  // further analysis. We do this so that we don't end up rebasing the same
  // schemas over and over again depending on the order of analysis later on
  /////////////////////////////////////////////////////////////////////////////

  const auto schemas_path{output.path() / "schemas"};
  sourcemeta::core::BuildAdapterFilesystem adapter;
  // Mainly to not screw up the logs
  std::mutex mutex;
  // TODO: Let the user override this from the command line
  const auto concurrency{std::thread::hardware_concurrency()};
  sourcemeta::core::parallel_for_each(
      resolver.begin(), resolver.end(),
      [&output, &schemas_path, &resolver, &mutex, &adapter,
       &mark_configuration_path, &mark_version_path](
          const auto &schema, const auto threads, const auto cursor) {
        print_progress(mutex, threads, "Ingesting", schema.first, cursor,
                       resolver.size());
        const auto destination{schemas_path / schema.second.relative_path /
                               SENTINEL / "schema.metapack"};
        DISPATCH<sourcemeta::registry::GENERATE_MATERIALISED_SCHEMA>(
            destination,
            {schema.second.path,
             // This target depends on the configuration file given things like
             // resolve maps and base URIs
             mark_configuration_path, mark_version_path},
            {schema.first, resolver}, mutex, "Ingesting", schema.first,
            "materialise", adapter, output);

        // Mark the materialised schema in the resolver
        resolver.cache_path(schema.first, destination);
      },
      concurrency);

  /////////////////////////////////////////////////////////////////////////////
  // (8) Generate all the artifacts that purely depend on the schemas
  /////////////////////////////////////////////////////////////////////////////

  // Give it a generous thread stack size, otherwise we might overflow
  // the small-by-default thread stack with Blaze
  constexpr auto THREAD_STACK_SIZE{8 * 1024 * 1024};

  sourcemeta::core::parallel_for_each(
      resolver.begin(), resolver.end(),
      [&output, &schemas_path, &resolver, &mutex, &adapter,
       &mark_configuration_path, &mark_version_path](
          const auto &schema, const auto threads, const auto cursor) {
        print_progress(mutex, threads, "Analysing", schema.first, cursor,
                       resolver.size());
        const auto base_path{schemas_path / schema.second.relative_path /
                             SENTINEL};

        if (attribute_enabled(schema.second.collection.get(),
                              "x-sourcemeta-registry:protected")) {
          DISPATCH<sourcemeta::registry::GENERATE_MARKER>(
              base_path / "protected.metapack",
              {// Because this flag is set in the config file
               mark_configuration_path, mark_version_path},
              resolver, mutex, "Analysing", schema.first, "protected", adapter,
              output);
        }

        DISPATCH<sourcemeta::registry::GENERATE_POINTER_POSITIONS>(
            base_path / "positions.metapack",
            {base_path / "schema.metapack", mark_version_path}, resolver, mutex,
            "Analysing", schema.first, "positions", adapter, output);

        DISPATCH<sourcemeta::registry::GENERATE_FRAME_LOCATIONS>(
            base_path / "locations.metapack",
            {base_path / "schema.metapack", mark_version_path}, resolver, mutex,
            "Analysing", schema.first, "locations", adapter, output);

        DISPATCH<sourcemeta::registry::GENERATE_DEPENDENCIES>(
            base_path / "dependencies.metapack",
            {base_path / "schema.metapack", mark_version_path}, resolver, mutex,
            "Analysing", schema.first, "dependencies", adapter, output);

        DISPATCH<sourcemeta::registry::GENERATE_HEALTH>(
            base_path / "health.metapack",
            {base_path / "schema.metapack", base_path / "dependencies.metapack",
             mark_version_path},
            resolver, mutex, "Analysing", schema.first, "health", adapter,
            output);

        DISPATCH<sourcemeta::registry::GENERATE_BUNDLE>(
            base_path / "bundle.metapack",
            {base_path / "schema.metapack", base_path / "dependencies.metapack",
             mark_version_path},
            resolver, mutex, "Analysing", schema.first, "bundle", adapter,
            output);

        DISPATCH<sourcemeta::registry::GENERATE_EDITOR>(
            base_path / "editor.metapack",
            {base_path / "bundle.metapack", mark_version_path}, resolver, mutex,
            "Analysing", schema.first, "editor", adapter, output);

        if (attribute_not_disabled(schema.second.collection.get(),
                                   "x-sourcemeta-registry:evaluate")) {
          // TODO: Compile fast templates too
          DISPATCH<sourcemeta::registry::GENERATE_BLAZE_TEMPLATE>(
              base_path / "blaze-exhaustive.metapack",
              {base_path / "bundle.metapack", mark_version_path},
              sourcemeta::blaze::Mode::Exhaustive, mutex, "Analysing",
              schema.first, "blaze-exhaustive", adapter, output);
        }
      },
      concurrency, THREAD_STACK_SIZE);

  /////////////////////////////////////////////////////////////////////////////
  // (9) Do a pass over the current output to determine directory layout
  /////////////////////////////////////////////////////////////////////////////

  // This is a pretty fast step that will be useful for us to properly declare
  // dependencies for HTML and navigational targets

  std::cerr << "Generating registry explorer\n";

  // TODO: We could make this a vector of pairs where the values are the
  // directory entries to a full list of dependencies for navigation targets
  std::vector<std::filesystem::path> directories;
  if (std::filesystem::exists(schemas_path)) {
    for (const auto &entry :
         std::filesystem::recursive_directory_iterator{schemas_path}) {
      if (entry.is_directory() && entry.path().filename() != SENTINEL &&
          !output.is_untracked_file(entry.path())) {
        const auto children{
            std::distance(std::filesystem::directory_iterator(entry.path()),
                          std::filesystem::directory_iterator{})};
        if (children == 0 ||
            (std::filesystem::exists(entry.path() / SENTINEL) &&
             children == 1)) {
          continue;
        }

        assert(entry.path().is_absolute());
        directories.push_back(entry.path());
      }
    }

    // Re-order the directories so that the most nested ones come first, as we
    // often need to process directories in that order
    std::ranges::sort(directories, [](const std::filesystem::path &left,
                                      const std::filesystem::path &right) {
      const auto left_depth{std::distance(left.begin(), left.end())};
      const auto right_depth{std::distance(right.begin(), right.end())};
      if (left_depth == right_depth) {
        return left < right;
      } else {
        return left_depth > right_depth;
      }
    });
  }

  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  const auto explorer_path{output.path() / "explorer"};
  std::vector<std::filesystem::path> navs;
  navs.reserve(resolver.size());
  for (const auto &schema : resolver) {
    auto schema_nav_path{std::filesystem::path{"explorer"} /
                         schema.second.relative_path};
    schema_nav_path /= SENTINEL;
    schema_nav_path /= "schema.metapack";

    output.write_metapack_json(
        schema_nav_path, sourcemeta::registry::Encoding::GZIP,
        sourcemeta::registry::GENERATE_NAV_SCHEMA(
            configuration.url, resolver,
            output.path() / "schemas" / schema.second.relative_path / SENTINEL /
                "schema.metapack",
            output.path() / "schemas" / schema.second.relative_path / SENTINEL /
                "health.metapack",
            output.path() / "schemas" / schema.second.relative_path / SENTINEL /
                "protected.metapack",
            schema.second.collection.get(), schema.second.relative_path));

    navs.push_back(output.path() / schema_nav_path);
  }

  const auto search_index{sourcemeta::registry::GENERATE_SEARCH_INDEX(navs)};
  output.write_metapack_jsonl(
      std::filesystem::path{"explorer"} / SENTINEL / "search.metapack",
      // We don't want to compress this one so we can
      // quickly skim through it while streaming it
      sourcemeta::registry::Encoding::Identity, search_index);

  for (const auto &entry : directories) {
    const auto relative_path{std::filesystem::path{"explorer"} /
                             std::filesystem::relative(entry, schemas_path) /
                             SENTINEL / "directory.metapack"};
    output.write_metapack_json(
        relative_path, sourcemeta::registry::Encoding::GZIP,
        sourcemeta::registry::GENERATE_NAV_DIRECTORY(
            configuration, explorer_path, schemas_path, entry, output));
  }

  output.write_metapack_json(
      std::filesystem::path{"explorer"} / SENTINEL / "directory.metapack",
      sourcemeta::registry::Encoding::GZIP,
      sourcemeta::registry::GENERATE_NAV_DIRECTORY(
          configuration, explorer_path, schemas_path, schemas_path, output));

  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////

  if (configuration.html.has_value()) {
    std::cerr << "Generating registry web interface\n";

    const auto explorer_base{output.path() / "explorer"};

    for (const auto &entry :
         std::filesystem::recursive_directory_iterator{explorer_base}) {
      if (entry.path().parent_path() == explorer_base / SENTINEL) {
        continue;
      } else if (entry.path().filename() == "directory.metapack") {
        const auto relative_destination{
            std::filesystem::relative(entry.path().parent_path(),
                                      output.path()) /
            "directory-html.metapack"};
        output.write_metapack_html(
            relative_destination, sourcemeta::registry::Encoding::GZIP,
            sourcemeta::registry::GENERATE_EXPLORER_DIRECTORY_PAGE(
                configuration, entry.path()));
      } else if (entry.path().filename() == "schema.metapack") {
        const auto relative_destination{
            std::filesystem::relative(entry.path().parent_path(),
                                      output.path()) /
            "schema-html.metapack"};

        const auto schema_base_path{
            output.path() / "schemas" /
            (std::filesystem::relative(entry.path().parent_path(),
                                       output.path() / "explorer")
                 .parent_path()
                 .string())};

        const auto dependencies_path{schema_base_path / SENTINEL /
                                     "dependencies.metapack"};
        const auto health_path{schema_base_path / SENTINEL / "health.metapack"};

        output.write_metapack_html(
            relative_destination, sourcemeta::registry::Encoding::GZIP,
            sourcemeta::registry::GENERATE_EXPLORER_SCHEMA_PAGE(
                configuration, entry.path(), dependencies_path, health_path));
      }
    }

    output.write_metapack_html(
        std::filesystem::path{"explorer"} / SENTINEL /
            "directory-html.metapack",
        sourcemeta::registry::Encoding::GZIP,
        sourcemeta::registry::GENERATE_EXPLORER_INDEX(
            configuration, output.path() / std::filesystem::path{"explorer"} /
                               SENTINEL / "directory.metapack"));

    output.write_metapack_html(
        std::filesystem::path{"explorer"} / SENTINEL / "404.metapack",
        sourcemeta::registry::Encoding::GZIP,
        sourcemeta::registry::GENERATE_EXPLORER_404(configuration));
  }

  // TODO: Print the size of the output directory here

  output.remove_unknown_files();
  return EXIT_SUCCESS;
}

auto main(int argc, char *argv[]) noexcept -> int {
  try {
    sourcemeta::core::Options app;
    // TODO: Support a --help flag
    app.option("url", {"u"});
    app.flag("verbose", {"v"});
    app.parse(argc, argv);
    const std::string_view program{argv[0]};
    if (!sourcemeta::registry::license_permitted()) {
      std::cerr << sourcemeta::registry::license_error();
      return EXIT_FAILURE;
    }

    return index_main(program, app);
  } catch (const sourcemeta::registry::ConfigurationReadError &error) {
    std::cerr << "error: " << error.what() << "\n";
    std::cerr << "  from " << error.from().string() << "\n";
    std::cerr << "  at \"" << sourcemeta::core::to_string(error.location())
              << "\"\n";
    std::cerr << "  to " << error.target().string() << "\n";
    return EXIT_FAILURE;
  } catch (
      const sourcemeta::registry::ConfigurationUnknownBuiltInCollectionError
          &error) {
    std::cerr << "error: " << error.what() << "\n";
    std::cerr << "  from " << error.from().string() << "\n";
    std::cerr << "  at \"" << sourcemeta::core::to_string(error.location())
              << "\"\n";
    std::cerr << "  to " << error.identifier() << "\n";
    return EXIT_FAILURE;
  } catch (const sourcemeta::core::OptionsUnexpectedValueFlagError &error) {
    std::cerr << "error: " << error.what() << " '" << error.name() << "'\n";
    return EXIT_FAILURE;
  } catch (const sourcemeta::core::OptionsMissingOptionValueError &error) {
    std::cerr << "error: " << error.what() << " '" << error.name() << "'\n";
    return EXIT_FAILURE;
  } catch (const sourcemeta::core::OptionsUnknownOptionError &error) {
    std::cerr << "error: " << error.what() << " '" << error.name() << "'\n";
    return EXIT_FAILURE;
  } catch (const sourcemeta::registry::ConfigurationValidationError &error) {
    std::cerr << "error: " << error.what() << "\n" << error.stacktrace();
    return EXIT_FAILURE;
  } catch (
      const sourcemeta::registry::GENERATE_MATERIALISED_SCHEMA::MetaschemaError
          &error) {
    std::cerr << "error: " << error.what() << "\n" << error.stacktrace();
    return EXIT_FAILURE;
  } catch (const sourcemeta::registry::ResolverOutsideBaseError &error) {
    std::cerr << "error: " << error.what() << "\n  at " << error.uri()
              << "\n  with base " << error.base() << "\n";
    return EXIT_FAILURE;
  } catch (const sourcemeta::core::SchemaResolutionError &error) {
    std::cerr << "error: " << error.what() << "\n  " << error.id()
              << "\n\nDid you forget to register a schema with such URI in the "
                 "registry?\n";
    return EXIT_FAILURE;
  } catch (const sourcemeta::core::SchemaReferenceError &error) {
    std::cerr << "error: " << error.what() << "\n  " << error.id()
              << "\n    at schema location \"";
    sourcemeta::core::stringify(error.location(), std::cerr);
    std::cerr << "\"\n";
    return EXIT_FAILURE;
  } catch (const std::filesystem::filesystem_error &error) {
    if (error.code() == std::make_error_condition(std::errc::file_exists) ||
        error.code() == std::make_error_condition(std::errc::not_a_directory)) {
      std::cerr << "error: file already exists\n  at " << error.path1().string()
                << "\n";
    } else if (error.code() == std::errc::no_such_file_or_directory) {
      std::cerr << "error: could not locate the requested file\n  at "
                << error.path1().string() << "\n";
    } else {
      std::cerr << error.what() << "\n";
    }

    return EXIT_FAILURE;
  } catch (const std::exception &error) {
    std::cerr << "unexpected error: " << error.what() << "\n";
    return EXIT_FAILURE;
  }
}
