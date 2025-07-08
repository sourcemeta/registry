#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/time.h>

#include <sourcemeta/registry/generator.h>
#include <sourcemeta/registry/license.h>

#include "configure.h"
#include "explorer.h"
#include "toc.h"

#include <algorithm>   // std::sort
#include <cassert>     // assert
#include <cstdlib>     // EXIT_FAILURE, EXIT_SUCCESS
#include <exception>   // std::exception
#include <filesystem>  // std::filesystem
#include <iostream>    // std::cerr, std::cout
#include <span>        // std::span
#include <string>      // std::string
#include <string_view> // std::string_view
#include <utility>     // std::move
#include <vector>      // std::vector

static auto search_index_comparator(const sourcemeta::core::JSON &left,
                                    const sourcemeta::core::JSON &right)
    -> bool {
  assert(left.is_array() && left.size() == 3);
  assert(right.is_array() && right.size() == 3);

  // Prioritise entries that have more meta-data filled in
  const auto left_score =
      (!left.at(1).empty() ? 1 : 0) + (!left.at(2).empty() ? 1 : 0);
  const auto right_score =
      (!right.at(1).empty() ? 1 : 0) + (!right.at(2).empty() ? 1 : 0);
  if (left_score != right_score) {
    return left_score > right_score;
  }

  // Otherwise revert to lexicographic comparisons
  // TODO: Ideally we sort based on schema health too, given lint results
  if (left_score > 0) {
    return left.at(0).to_string() < right.at(0).to_string();
  }

  return false;
}

static auto
write_file_metadata(const std::filesystem::path &relative_path,
                    const sourcemeta::registry::Output &output,
                    const sourcemeta::registry::Output::Category category,
                    const std::string &mime) -> void {
  auto metadata{sourcemeta::core::JSON::make_object()};
  metadata.assign("md5",
                  sourcemeta::core::JSON{output.md5(category, relative_path)});
  metadata.assign("lastModified",
                  sourcemeta::core::JSON{sourcemeta::core::to_gmt(
                      output.last_modified(category, relative_path))});
  metadata.assign("mime", sourcemeta::core::JSON{mime});
  output.write_metadata(category, relative_path, metadata);
}

static auto
write_schema_metadata(const std::filesystem::path &relative_path,
                      const sourcemeta::registry::Resolver &resolver,
                      const sourcemeta::registry::Resolver::Entry &entry,
                      const sourcemeta::registry::Output &output,
                      const sourcemeta::registry::Output::Category category,
                      const std::string &identifier,
                      const sourcemeta::core::JSON &schema) -> void {
  auto other{resolver.metadata(identifier, schema, entry)};

  auto metadata{sourcemeta::core::JSON::make_object()};
  metadata.assign("dialect", other.at("dialect"));
  metadata.assign("mime", sourcemeta::core::JSON{"application/schema+json"});
  metadata.assign("md5",
                  sourcemeta::core::JSON{output.md5(category, relative_path)});
  metadata.assign("lastModified",
                  sourcemeta::core::JSON{sourcemeta::core::to_gmt(
                      output.last_modified(category, relative_path))});
  output.write_metadata(category, relative_path, metadata);
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
  const auto output_path{std::filesystem::weakly_canonical(arguments[1])};
  sourcemeta::registry::Output output{output_path};
  std::cerr << "Writing output to: " << output_path.string() << "\n";

  // --------------------------------------------
  // (1) Process the configuration file
  // --------------------------------------------

  // Read and validate the configuration file
  sourcemeta::registry::Resolver resolver;
  sourcemeta::registry::Validator validator{resolver};
  const auto configuration_path{std::filesystem::canonical(arguments[0])};
  std::cerr << "Using configuration: " << configuration_path.string() << "\n";
  const sourcemeta::registry::Configuration configuration{
      configuration_path, sourcemeta::core::parse_json(std::string{
                              sourcemeta::registry::SCHEMA_CONFIGURATION})};
  validator.validate_or_throw(configuration.schema(), configuration.get(),
                              "Invalid configuration");
  output.write_configuration(configuration);

  // --------------------------------------------
  // (2) Populate the schema resolver
  // --------------------------------------------

  for (const auto &schema_entry :
       configuration.get().at("schemas").as_object()) {
    const sourcemeta::registry::Collection collection{
        configuration.base(), schema_entry.first, schema_entry.second};
    for (const auto &entry :
         std::filesystem::recursive_directory_iterator{collection.path}) {
      const auto is_schema_file{entry.path().extension() == ".yaml" ||
                                entry.path().extension() == ".yml" ||
                                entry.path().extension() == ".json"};
      if (!entry.is_regular_file() || !is_schema_file ||
          entry.path().stem().string().starts_with(".")) {
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

      resolver.add(configuration, collection, entry.path());
    }
  }

  // --------------------------------------------
  // (3) Generate schema artefacts
  // --------------------------------------------

  // TODO: We could parallelize this loop
  for (const auto &schema : resolver) {
    std::cerr << "Ingesting: " << schema.first << "\n";
    const auto subresult{resolver(schema.first)};
    assert(subresult.has_value());
    const auto dialect_identifier{sourcemeta::core::dialect(subresult.value())};
    assert(dialect_identifier.has_value());
    const auto metaschema{resolver(dialect_identifier.value())};
    assert(metaschema.has_value());
    validator.validate_or_throw(dialect_identifier.value(), metaschema.value(),
                                subresult.value(),
                                "The schema does not adhere to its metaschema");
    const auto destination{output.write_schema_single(
        schema.second.relative_path.string() + ".schema", subresult.value())};
    resolver.materialise(schema.first, destination);
    write_schema_metadata(
        std::filesystem::path{"schemas"} /
            (schema.second.relative_path.string() + ".schema"),
        resolver, schema.second, output,
        sourcemeta::registry::Output::Category::Explorer, schema.first,
        subresult.value());

    // Storing artefacts

    auto bundled_schema{sourcemeta::core::bundle(
        subresult.value(), sourcemeta::core::schema_official_walker, resolver)};
    output.write_schema_bundle(schema.second.relative_path.string() + ".bundle",
                               bundled_schema);
    write_schema_metadata(
        std::filesystem::path{"schemas"} /
            (schema.second.relative_path.string() + ".bundle"),
        resolver, schema.second, output,
        sourcemeta::registry::Output::Category::Explorer, schema.first,
        subresult.value());

    sourcemeta::core::SchemaFrame frame{
        sourcemeta::core::SchemaFrame::Mode::References};
    frame.analyse(bundled_schema, sourcemeta::core::schema_official_walker,
                  resolver);

    const auto template_exhasutive{sourcemeta::blaze::compile(
        bundled_schema, sourcemeta::core::schema_official_walker, resolver,
        sourcemeta::blaze::default_schema_compiler, frame,
        sourcemeta::blaze::Mode::Exhaustive)};
    output.write_schema_template_exhaustive(
        schema.second.relative_path.string() + ".blaze-exhaustive",
        template_exhasutive);
    write_file_metadata(
        std::filesystem::path{"schemas"} /
            (schema.second.relative_path.string() + ".blaze-exhaustive"),
        output, sourcemeta::registry::Output::Category::Explorer,
        "application/json");

    // TODO: Can we re-use the frame here?
    sourcemeta::core::unidentify(
        bundled_schema, sourcemeta::core::schema_official_walker, resolver);
    output.write_schema_bundle_unidentified(
        schema.second.relative_path.string() + ".unidentified", bundled_schema);
    write_schema_metadata(
        std::filesystem::path{"schemas"} /
            (schema.second.relative_path.string() + ".unidentified"),
        resolver, schema.second, output,
        sourcemeta::registry::Output::Category::Explorer, schema.first,
        subresult.value());
  }

  // --------------------------------------------
  // (4) Generate schema search index
  // --------------------------------------------

  std::cerr << "Generating registry navigation...\n";

  for (const auto &schema : resolver) {
    auto schema_nav_path{std::filesystem::path{"explorer"} / "pages" /
                         schema.second.relative_path};
    schema_nav_path.replace_extension("nav");
    const auto subresult{resolver(schema.first)};
    assert(subresult.has_value());
    // TODO: Put breadcrumb inside this metadata
    const auto metadata{
        resolver.metadata(schema.first, subresult.value(), schema.second)};
    output.internal_write_json(schema_nav_path, metadata);
    write_file_metadata(schema_nav_path, output,
                        sourcemeta::registry::Output::Category::Explorer,
                        "application/json");
  }

  const auto base{
      output.absolute_path(sourcemeta::registry::Output::Category::Explorer) /
      "schemas"};
  const auto navigation_base{
      output.absolute_path(sourcemeta::registry::Output::Category::Navigation)};
  output.write_explorer_json(
      "pages.nav",
      sourcemeta::registry::toc(configuration, navigation_base, base, base));
  write_file_metadata("pages.nav", output,
                      sourcemeta::registry::Output::Category::Navigation,
                      "application/json");
  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{base}) {
    if (entry.is_directory()) {
      auto toc{sourcemeta::registry::toc(configuration, navigation_base, base,
                                         entry.path())};
      auto relative_path{
          std::filesystem::path{"pages"} /
          (std::filesystem::relative(entry.path(), base).string() + ".nav")};
      output.write_explorer_json(relative_path, std::move(toc));
      write_file_metadata(relative_path, output,
                          sourcemeta::registry::Output::Category::Navigation,
                          "application/json");
    }
  }

  std::cerr << "Generating registry search index...\n";

  // TODO: We could parallelize this loop
  std::vector<sourcemeta::core::JSON> search_index;
  search_index.reserve(resolver.size());
  for (const auto &schema : resolver) {
    auto schema_nav_path{std::filesystem::path{"explorer"} / "pages" /
                         schema.second.relative_path};
    schema_nav_path.replace_extension("nav");
    const auto metadata{output.read_metadata(
        sourcemeta::registry::Output::Category::Navigation, schema_nav_path)};
    auto entry{sourcemeta::core::JSON::make_array()};
    entry.push_back(metadata.at("url"));
    entry.push_back(metadata.at_or("title", sourcemeta::core::JSON{""}));
    entry.push_back(metadata.at_or("description", sourcemeta::core::JSON{""}));
    search_index.push_back(std::move(entry));
  }

  // Make sure more relevant entries get prioritised
  std::sort(search_index.begin(), search_index.end(), search_index_comparator);
  output.write_search(search_index.cbegin(), search_index.cend());
  write_file_metadata("search.jsonl", output,
                      sourcemeta::registry::Output::Category::Navigation,
                      "application/jsonl");

  // --------------------------------------------
  // (6) Generate schema explorer
  // --------------------------------------------

  std::cerr << "Generating registry explorer...\n";

  // TODO: Make the explorer generator use the Output class to writing files
  sourcemeta::registry::explorer(
      configuration.get(),
      output.absolute_path(sourcemeta::registry::Output::Category::Navigation));

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
