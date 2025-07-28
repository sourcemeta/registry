#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>

#include <sourcemeta/registry/license.h>
#include <sourcemeta/registry/metapack.h>
#include <sourcemeta/registry/resolver.h>

#include "configure.h"
#include "explorer.h"
#include "generators.h"
#include "output.h"
#include "parallel.h"
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

static auto attribute(const sourcemeta::core::JSON &configuration,
                      const sourcemeta::core::JSON::String &collection,
                      const sourcemeta::core::JSON::String &name) -> bool {
  return configuration.at("schemas")
      .at(collection)
      .at_or(name, sourcemeta::core::JSON{true})
      .to_boolean();
}

static auto index_main(const std::string_view &program,
                       const std::span<const std::string> &arguments) -> int {
  std::cout << "Sourcemeta Registry v" << sourcemeta::registry::PROJECT_VERSION;
#if defined(SOURCEMETA_REGISTRY_ENTERPRISE)
  std::cout << " Enterprise ";
#elif defined(SOURCEMETA_REGISTRY_PRO)
  std::cout << " Pro ";
#else
  std::cout << " Starter ";
#endif
  std::cout << "Edition\n";

  if (arguments.size() < 2) {
    std::cout << "Usage: " << std::filesystem::path{program}.filename().string()
              << " <registry.json> <path/to/output/directory>\n";
    return EXIT_FAILURE;
  }

  // Prepare the output directory
  sourcemeta::registry::Output output{arguments[1]};
  std::cerr << "Writing output to: " << output.path().string() << "\n";

  // --------------------------------------------
  // (1) Process the configuration file
  // --------------------------------------------

  // Read and validate the configuration file
  sourcemeta::registry::Resolver resolver;
  sourcemeta::registry::Validator validator{resolver};
  const auto configuration_path{std::filesystem::canonical(arguments[0])};
  std::cerr << "Using configuration: " << configuration_path.string() << "\n";
  const auto configuration_schema{sourcemeta::core::parse_json(
      std::string{sourcemeta::registry::SCHEMA_CONFIGURATION})};
  auto configuration{sourcemeta::core::read_json(configuration_path)};
  validator.validate_or_throw(configuration_schema, configuration,
                              "Invalid configuration");
  if (configuration.is_object()) {
    configuration.assign_if_missing(
        "title",
        configuration_schema.at("properties").at("title").at("default"));
    configuration.assign_if_missing(
        "description",
        configuration_schema.at("properties").at("description").at("default"));
  }

  // We want to keep this file uncompressed and without a leading header to that
  // the server can quickly read on start
  output.write_json(
      "configuration.json",
      sourcemeta::registry::GENERATE_SERVER_CONFIGURATION(configuration));

  const auto server_url{
      sourcemeta::core::URI{configuration.at("url").to_string()}
          .canonicalize()};
  for (const auto &schema_entry : configuration.at("schemas").as_object()) {
    const sourcemeta::registry::ResolverCollection collection{
        configuration_path.parent_path(), schema_entry.first,
        schema_entry.second};
    for (const auto &entry :
         std::filesystem::recursive_directory_iterator{collection.path}) {
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

      resolver.add(server_url, collection, entry.path());
    }
  }

  // Give it a generous thread stack size, otherwise we might overflow
  // the small-by-default thread stack with Blaze
  constexpr auto THREAD_STACK_SIZE{8 * 1024 * 1024};

  sourcemeta::registry::parallel_for_each(
      resolver.begin(), resolver.end(),
      [](const auto id, const auto threads, const auto percentage,
         const auto &schema) {
        std::cerr << "(" << std::setfill(' ') << std::setw(3)
                  << static_cast<int>(percentage) << "%) "
                  << "Ingesting: " << schema.first << " [" << id << "/"
                  << threads << "]\n";
      },
      [&output, &resolver, &validator](const auto &schema) {
        const auto subresult{resolver(schema.first)};
        assert(subresult.has_value());
        const auto dialect_identifier{
            sourcemeta::core::dialect(subresult.value())};
        assert(dialect_identifier.has_value());
        const auto metaschema{resolver(dialect_identifier.value())};
        assert(metaschema.has_value());
        validator.validate_or_throw(
            dialect_identifier.value(), metaschema.value(), subresult.value(),
            "The schema does not adhere to its metaschema");
        const auto base_path{std::filesystem::path{"schemas"} /
                             schema.second.relative_path};
        const auto destination{output.write_metapack_jsonschema(
            base_path.string() + ".schema",
            sourcemeta::registry::MetaPackEncoding::GZIP, subresult.value(),
            dialect_identifier.value())};
        resolver.materialise(schema.first, destination);
      },
      THREAD_STACK_SIZE);

  // TODO: Put file dependency information in the metapack extensions,
  // as these are the files that want to be able to re-generate if something
  // changes?
  sourcemeta::registry::parallel_for_each(
      resolver.begin(), resolver.end(),
      [](const auto id, const auto threads, const auto percentage,
         const auto &schema) {
        std::cerr << "(" << std::setfill(' ') << std::setw(3)
                  << static_cast<int>(percentage) << "%) "
                  << "Analysing: " << schema.first << " [" << id << "/"
                  << threads << "]\n";
      },
      [&output, &resolver, &configuration](const auto &schema) {
        const auto base_path{std::filesystem::path{"schemas"} /
                             schema.second.relative_path};
        const auto dialect_identifier{
            sourcemeta::core::dialect(resolver(schema.first).value())};
        assert(dialect_identifier.has_value());

        output.write_metapack_json(
            base_path.string() + ".positions",
            sourcemeta::registry::MetaPackEncoding::GZIP,
            sourcemeta::registry::GENERATE_POINTER_POSITIONS(
                resolver, output.path() / (base_path.string() + ".schema")));

        output.write_metapack_json(
            base_path.string() + ".dependencies",
            sourcemeta::registry::MetaPackEncoding::GZIP,
            sourcemeta::registry::GENERATE_DEPENDENCIES(
                resolver, output.path() / (base_path.string() + ".schema")));

        // TODO: The bundle target should depend on the .dependencies file

        output.write_metapack_jsonschema(
            base_path.string() + ".bundle",
            sourcemeta::registry::MetaPackEncoding::GZIP,
            sourcemeta::registry::GENERATE_BUNDLE(
                resolver, output.path() / (base_path.string() + ".schema")),
            dialect_identifier.value());

        if (attribute(configuration, schema.second.collection_name,
                      "x-sourcemeta-registry:blaze-exhaustive")) {
          output.write_metapack_json(
              base_path.string() + ".blaze-exhaustive",
              // Don't compress, as we need to internally read from disk
              sourcemeta::registry::MetaPackEncoding::Identity,
              sourcemeta::registry::GENERATE_BLAZE_TEMPLATE_EXHAUSTIVE(
                  resolver, output.path() / (base_path.string() + ".bundle")));
        }

        output.write_metapack_jsonschema(
            base_path.string() + ".unidentified",
            sourcemeta::registry::MetaPackEncoding::GZIP,
            sourcemeta::registry::GENERATE_UNIDENTIFIED(
                resolver, output.path() / (base_path.string() + ".bundle")),
            dialect_identifier.value());
      },
      THREAD_STACK_SIZE);

  std::cerr << "Generating registry explorer\n";

  for (const auto &schema : resolver) {
    auto schema_nav_path{std::filesystem::path{"explorer"} / "pages" /
                         schema.second.relative_path};
    schema_nav_path.replace_extension("nav");
    output.write_metapack_json(
        schema_nav_path, sourcemeta::registry::MetaPackEncoding::GZIP,
        sourcemeta::registry::GENERATE_NAV_SCHEMA(
            configuration, resolver,
            output.path() / "schemas" /
                (schema.second.relative_path.string() + ".schema"),
            schema.second.relative_path));
  }

  const auto base{output.path() / "schemas"};
  const auto navigation_base{output.path() / "explorer" / "pages"};
  output.write_metapack_json(std::filesystem::path{"explorer"} / "pages.nav",
                             sourcemeta::registry::MetaPackEncoding::GZIP,
                             sourcemeta::registry::GENERATE_NAV_DIRECTORY(
                                 configuration, navigation_base, base, base));

  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{base}) {
    if (entry.is_directory()) {
      auto relative_path{
          std::filesystem::path{"explorer"} / std::filesystem::path{"pages"} /
          (std::filesystem::relative(entry.path(), base).string() + ".nav")};
      output.write_metapack_json(
          relative_path, sourcemeta::registry::MetaPackEncoding::GZIP,
          sourcemeta::registry::GENERATE_NAV_DIRECTORY(
              configuration, navigation_base, base, entry.path()));
    }
  }

  std::vector<std::filesystem::path> navs;
  navs.reserve(resolver.size());
  for (const auto &schema : resolver) {
    auto schema_nav_path{output.path() / "explorer" / "pages" /
                         schema.second.relative_path};
    schema_nav_path.replace_extension("nav");
    navs.push_back(std::move(schema_nav_path));
  }

  const auto search_index{sourcemeta::registry::GENERATE_SEARCH_INDEX(navs)};
  output.write_metapack_jsonl(std::filesystem::path{"explorer"} /
                                  "search.jsonl",
                              // We don't want to compress this one so we can
                              // quickly skim through it while streaming it
                              sourcemeta::registry::MetaPackEncoding::Identity,
                              search_index.cbegin(), search_index.cend());

  const auto explorer_base{output.path() / "explorer" / "pages"};
  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{explorer_base}) {
    if (entry.is_directory() || entry.path().extension() != ".nav") {
      continue;
    }

    const auto meta{sourcemeta::registry::read_contents(entry.path())};
    assert(meta.has_value());
    const auto meta_json{sourcemeta::core::parse_json(meta.value().data)};
    auto relative_destination{
        std::filesystem::relative(entry.path(), output.path())};
    relative_destination.replace_extension(".html");
    if (meta_json.defines("entries")) {
      output.write_metapack_html(
          relative_destination, sourcemeta::registry::MetaPackEncoding::GZIP,
          sourcemeta::registry::GENERATE_EXPLORER_DIRECTORY_PAGE(configuration,
                                                                 entry.path()));
    } else {
      output.write_metapack_html(
          relative_destination, sourcemeta::registry::MetaPackEncoding::GZIP,
          sourcemeta::registry::GENERATE_EXPLORER_SCHEMA_PAGE(
              configuration, entry.path(),
              (output.path() / "schemas").string() +
                  meta_json.at("url").to_string() + ".schema",
              (output.path() / "schemas").string() +
                  meta_json.at("url").to_string() + ".dependencies"));
    }
  }

  output.write_metapack_html(
      std::filesystem::path{"explorer"} / "pages.html",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::registry::GENERATE_EXPLORER_INDEX(
          configuration,
          output.path() / std::filesystem::path{"explorer"} / "pages.nav"));

  output.write_metapack_html(
      std::filesystem::path{"explorer"} / "404.html",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::registry::GENERATE_EXPLORER_404(configuration));

  return EXIT_SUCCESS;
}

auto main(int argc, char *argv[]) noexcept -> int {
  try {
    const std::string_view program{argv[0]};
    const std::vector<std::string> arguments{argv + std::min(1, argc),
                                             argv + argc};
    if (!sourcemeta::registry::license_permitted()) {
      std::cerr << sourcemeta::registry::license_error();
      return EXIT_FAILURE;
    }

    return index_main(program, arguments);
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
    } else {
      std::cerr << "filesystem error: " << error.what() << "\n";
    }

    return EXIT_FAILURE;
  } catch (const std::exception &error) {
    std::cerr << "unexpected error: " << error.what() << "\n";
    return EXIT_FAILURE;
  }
}
