#include <sourcemeta/core/build.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/options.h>
#include <sourcemeta/core/parallel.h>

#include <sourcemeta/registry/configuration.h>
#include <sourcemeta/registry/license.h>
#include <sourcemeta/registry/metapack.h>
#include <sourcemeta/registry/resolver.h>

#include "configure.h"
#include "explorer.h"
#include "generators.h"
#include "output.h"
#include "validator.h"

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

static auto index_main(const std::string_view &program,
                       const sourcemeta::core::Options &app) -> int {
  std::cout << "Sourcemeta Registry v" << sourcemeta::registry::PROJECT_VERSION;
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

  // Prepare the output directory
  sourcemeta::registry::Output output{app.positional().at(1)};
  std::cerr << "Writing output to: " << output.path().string() << "\n";

  // --------------------------------------------
  // (1) Process the configuration file
  // --------------------------------------------

  // Read and validate the configuration file
  sourcemeta::registry::Resolver resolver;
  sourcemeta::registry::Validator validator{resolver};
  const auto configuration_path{
      std::filesystem::canonical(app.positional().at(0))};
  std::cerr << "Using configuration: " << configuration_path.string() << "\n";
  const auto raw_configuration{sourcemeta::registry::Configuration::read(
      configuration_path, SOURCEMETA_REGISTRY_COLLECTIONS)};
  auto configuration{
      sourcemeta::registry::Configuration::parse(raw_configuration)};
  if (app.contains("url")) {
    std::cerr << "Overriding the URL in the configuration file with: "
              << app.at("url").at(0) << "\n";
    sourcemeta::core::URI url{std::string{app.at("url").at(0)}};
    if (url.is_absolute() &&
        (url.scheme().value() == "https" || url.scheme().value() == "http")) {
      // TODO: Unit test this
      configuration.url =
          sourcemeta::core::URI::canonicalize(std::string{app.at("url").at(0)});
    } else {
      std::cerr << "error: The URL option must be an absolute HTTP(s) URL\n";
      return EXIT_FAILURE;
    }
  }

  // We want to keep this file uncompressed and without a leading header to that
  // the server can quickly read on start
  // TODO: Get rid of this file
  const auto configuration_summary_path{output.path() / "configuration.json"};
  auto summary{sourcemeta::core::JSON::make_object()};
  summary.assign("version",
                 sourcemeta::core::JSON{sourcemeta::registry::PROJECT_VERSION});
  // We use this configuration file to track whether we should invalidate
  // the cache if running on a different version. Therefore, we need to be
  // careful to not update it unless its really necessary
  if (std::filesystem::exists(configuration_summary_path)) {
    const auto summary_contents{
        sourcemeta::core::read_json(configuration_summary_path)};
    if (summary_contents != summary) {
      output.write_json(configuration_summary_path, summary);
    } else {
      output.track(configuration_summary_path);
    }
  } else {
    output.write_json(configuration_summary_path, summary);
  }

  for (const auto &element : configuration.entries) {
    if (!std::holds_alternative<
            sourcemeta::registry::Configuration::Collection>(element.second)) {
      continue;
    }

    const auto &collection{
        std::get<sourcemeta::registry::Configuration::Collection>(
            element.second)};
    for (const auto &entry : std::filesystem::recursive_directory_iterator{
             collection.absolute_path}) {
      const auto extension{entry.path().extension()};
      const auto is_schema_file{extension == ".yaml" || extension == ".yml" ||
                                extension == ".json"};
      if (!entry.is_regular_file() || !is_schema_file) {
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

      resolver.add(configuration.url, element.first, collection, entry.path());
    }
  };

  // Give it a generous thread stack size, otherwise we might overflow
  // the small-by-default thread stack with Blaze
  constexpr auto THREAD_STACK_SIZE{8 * 1024 * 1024};

  sourcemeta::core::BuildAdapterFilesystem adapter;

  std::mutex mutex;

  sourcemeta::core::parallel_for_each(
      resolver.begin(), resolver.end(),
      [&output, &resolver, &validator, &mutex, &adapter,
       &configuration_summary_path](const auto &schema, const auto threads,
                                    const auto cursor) {
        {
          const auto percentage{cursor * 100 / resolver.size()};
          std::lock_guard<std::mutex> lock(mutex);
          std::cerr << "(" << std::setfill(' ') << std::setw(3)
                    << static_cast<int>(percentage) << "%) "
                    << "Ingesting: " << schema.first << " ["
                    << std::this_thread::get_id() << "/" << threads << "]\n";
        }

        const auto base_path{output.path() / std::filesystem::path{"schemas"} /
                             schema.second.relative_path / SENTINEL};
        const auto destination{base_path / "schema.metapack"};
        assert(schema.second.path.has_value());
        assert(schema.second.path.value().is_absolute());

        if (!sourcemeta::core::build<std::tuple<
                std::string_view,
                std::reference_wrapper<sourcemeta::registry::Validator>,
                std::reference_wrapper<sourcemeta::registry::Resolver>>>(
                adapter, sourcemeta::registry::GENERATE_MATERIALISED_SCHEMA,
                destination,
                {schema.second.path.value(), configuration_summary_path},
                {schema.first, validator, resolver})) {
          std::lock_guard<std::mutex> lock(mutex);
          std::cerr << "(skip) "
                    << "Ingesting: " << schema.first << " ["
                    << std::this_thread::get_id() << "/" << threads << "]\n";
        }

        output.track(destination);
        output.track(base_path / "schema.metapack.deps");

        resolver.materialise(schema.first, destination);
      },
      std::thread::hardware_concurrency(), THREAD_STACK_SIZE);

  sourcemeta::core::parallel_for_each(
      resolver.begin(), resolver.end(),
      [&output, &resolver, &mutex, &adapter, &configuration_summary_path](
          const auto &schema, const auto threads, const auto cursor) {
        {
          const auto percentage{cursor * 100 / resolver.size()};
          std::lock_guard<std::mutex> lock(mutex);
          std::cerr << "(" << std::setfill(' ') << std::setw(3)
                    << static_cast<int>(percentage) << "%) "
                    << "Analysing: " << schema.first << " ["
                    << std::this_thread::get_id() << "/" << threads << "]\n";
        }

        const auto base_path{output.path() / std::filesystem::path{"schemas"} /
                             schema.second.relative_path / SENTINEL};

        if (!sourcemeta::core::build<sourcemeta::registry::Resolver>(
                adapter, sourcemeta::registry::GENERATE_POINTER_POSITIONS,
                base_path / "positions.metapack",
                {base_path / "schema.metapack", configuration_summary_path},
                resolver)) {
          std::lock_guard<std::mutex> lock(mutex);
          std::cerr << "(skip) Analysing: " << schema.first << " [positions]\n";
        }

        output.track(base_path / "positions.metapack");
        output.track(base_path / "positions.metapack.deps");

        if (!sourcemeta::core::build<sourcemeta::registry::Resolver>(
                adapter, sourcemeta::registry::GENERATE_FRAME_LOCATIONS,
                base_path / "locations.metapack",
                {base_path / "schema.metapack", configuration_summary_path},
                resolver)) {
          std::lock_guard<std::mutex> lock(mutex);
          std::cerr << "(skip) Analysing: " << schema.first << " [locations]\n";
        }

        output.track(base_path / "locations.metapack");
        output.track(base_path / "locations.metapack.deps");

        if (!sourcemeta::core::build<sourcemeta::registry::Resolver>(
                adapter, sourcemeta::registry::GENERATE_DEPENDENCIES,
                base_path / "dependencies.metapack",
                {base_path / "schema.metapack", configuration_summary_path},
                resolver)) {
          std::lock_guard<std::mutex> lock(mutex);
          std::cerr << "(skip) Analysing: " << schema.first
                    << " [dependencies]\n";
        }

        output.track(base_path / "dependencies.metapack");
        output.track(base_path / "dependencies.metapack.deps");

        if (!sourcemeta::core::build<sourcemeta::registry::Resolver>(
                adapter, sourcemeta::registry::GENERATE_HEALTH,
                base_path / "health.metapack",
                {base_path / "schema.metapack",
                 base_path / "dependencies.metapack",
                 configuration_summary_path},
                resolver)) {
          std::lock_guard<std::mutex> lock(mutex);
          std::cerr << "(skip) Analysing: " << schema.first << " [health]\n";
        }

        output.track(base_path / "health.metapack");
        output.track(base_path / "health.metapack.deps");

        if (!sourcemeta::core::build<sourcemeta::registry::Resolver>(
                adapter, sourcemeta::registry::GENERATE_BUNDLE,
                base_path / "bundle.metapack",
                {base_path / "schema.metapack",
                 base_path / "dependencies.metapack",
                 configuration_summary_path},
                resolver)) {
          std::lock_guard<std::mutex> lock(mutex);
          std::cerr << "(skip) Analysing: " << schema.first << " [bundle]\n";
        }

        output.track(base_path / "bundle.metapack");
        output.track(base_path / "bundle.metapack.deps");

        if (!sourcemeta::core::build<sourcemeta::registry::Resolver>(
                adapter, sourcemeta::registry::GENERATE_UNIDENTIFIED,
                base_path / "unidentified.metapack",
                {base_path / "bundle.metapack", configuration_summary_path},
                resolver)) {
          std::lock_guard<std::mutex> lock(mutex);
          std::cerr << "(skip) Analysing: " << schema.first
                    << " [unidentified]\n";
        }

        output.track(base_path / "unidentified.metapack");
        output.track(base_path / "unidentified.metapack.deps");

        if (schema.second.blaze_exhaustive) {
          if (!sourcemeta::core::build<sourcemeta::registry::Resolver>(
                  adapter,
                  sourcemeta::registry::GENERATE_BLAZE_TEMPLATE_EXHAUSTIVE,
                  base_path / "blaze-exhaustive.metapack",
                  {base_path / "bundle.metapack", configuration_summary_path},
                  resolver)) {
            std::lock_guard<std::mutex> lock(mutex);
            std::cerr << "(skip) Analysing: " << schema.first
                      << " [blaze-exhaustive]\n";
          }

          output.track(base_path / "blaze-exhaustive.metapack");
          output.track(base_path / "blaze-exhaustive.metapack.deps");
        }
      },
      std::thread::hardware_concurrency(), THREAD_STACK_SIZE);

  std::cerr << "Generating registry explorer\n";

  for (const auto &schema : resolver) {
    auto schema_nav_path{std::filesystem::path{"explorer"} /
                         schema.second.relative_path};
    schema_nav_path.replace_extension("");
    schema_nav_path /= SENTINEL;
    schema_nav_path /= "schema.metapack";
    output.write_metapack_json(
        schema_nav_path, sourcemeta::registry::MetaPackEncoding::GZIP,
        sourcemeta::registry::GENERATE_NAV_SCHEMA(
            configuration.url, resolver,
            output.path() / "schemas" / schema.second.relative_path / SENTINEL /
                "schema.metapack",
            output.path() / "schemas" / schema.second.relative_path / SENTINEL /
                "health.metapack",
            schema.second.relative_path));
  }

  const auto base{output.path() / "schemas"};
  const auto navigation_base{output.path() / "explorer"};

  std::vector<std::filesystem::path> schema_directories;
  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{base}) {
    if (entry.is_directory() && entry.path().filename() != SENTINEL &&
        !std::filesystem::exists(entry.path() / SENTINEL) &&
        !output.is_untracked_file(entry.path())) {
      schema_directories.push_back(entry.path());
    }
  }

  // Handle deep directories first
  std::ranges::sort(schema_directories, [](const std::filesystem::path &left,
                                           const std::filesystem::path &right) {
    const auto left_depth{std::distance(left.begin(), left.end())};
    const auto right_depth{std::distance(right.begin(), right.end())};
    if (left_depth == right_depth) {
      return left < right;
    } else {
      return left_depth > right_depth;
    }
  });

  for (const auto &entry : schema_directories) {
    const auto relative_path{std::filesystem::path{"explorer"} /
                             std::filesystem::relative(entry, base) / SENTINEL /
                             "directory.metapack"};
    output.write_metapack_json(
        relative_path, sourcemeta::registry::MetaPackEncoding::GZIP,
        sourcemeta::registry::GENERATE_NAV_DIRECTORY(
            configuration, navigation_base, base, entry, output));
  }

  output.write_metapack_json(
      std::filesystem::path{"explorer"} / SENTINEL / "directory.metapack",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::registry::GENERATE_NAV_DIRECTORY(
          configuration, navigation_base, base, base, output));

  std::vector<std::filesystem::path> navs;
  navs.reserve(resolver.size());
  for (const auto &schema : resolver) {
    auto schema_nav_path{output.path() / "explorer" /
                         schema.second.relative_path};
    schema_nav_path.replace_extension("");
    schema_nav_path /= "%";
    schema_nav_path /= "schema.metapack";
    navs.push_back(std::move(schema_nav_path));
  }

  const auto search_index{sourcemeta::registry::GENERATE_SEARCH_INDEX(navs)};
  output.write_metapack_jsonl(std::filesystem::path{"explorer"} / SENTINEL /
                                  "search.metapack",
                              // We don't want to compress this one so we can
                              // quickly skim through it while streaming it
                              sourcemeta::registry::MetaPackEncoding::Identity,
                              search_index.cbegin(), search_index.cend());

  // TODO: Add a test for this
  if (configuration.html.has_value()) {
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
            relative_destination, sourcemeta::registry::MetaPackEncoding::GZIP,
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
                 .string() +
             ".json")};

        const auto dependencies_path{schema_base_path / SENTINEL /
                                     "dependencies.metapack"};
        const auto health_path{schema_base_path / SENTINEL / "health.metapack"};

        output.write_metapack_html(
            relative_destination, sourcemeta::registry::MetaPackEncoding::GZIP,
            sourcemeta::registry::GENERATE_EXPLORER_SCHEMA_PAGE(
                configuration, entry.path(), dependencies_path, health_path));
      }
    }

    output.write_metapack_html(
        std::filesystem::path{"explorer"} / SENTINEL /
            "directory-html.metapack",
        sourcemeta::registry::MetaPackEncoding::GZIP,
        sourcemeta::registry::GENERATE_EXPLORER_INDEX(
            configuration, output.path() / std::filesystem::path{"explorer"} /
                               SENTINEL / "directory.metapack"));

    output.write_metapack_html(
        std::filesystem::path{"explorer"} / SENTINEL / "404.metapack",
        sourcemeta::registry::MetaPackEncoding::GZIP,
        sourcemeta::registry::GENERATE_EXPLORER_404(configuration));
  }

  output.remove_unknown_files();
  return EXIT_SUCCESS;
}

auto main(int argc, char *argv[]) noexcept -> int {
  try {
    sourcemeta::core::Options app;
    // TODO: Support a --help flag
    app.option("url", {"u"});
    app.parse(argc, argv);
    const std::string_view program{argv[0]};
    if (!sourcemeta::registry::license_permitted()) {
      std::cerr << sourcemeta::registry::license_error();
      return EXIT_FAILURE;
    }

    return index_main(program, app);
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
  } catch (const sourcemeta::registry::ValidatorError &error) {
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
