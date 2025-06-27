#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>

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
              << " <configuration.json> <path/to/output/directory>\n";
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
    std::cerr << "Discovering schemas at: " << collection.path.string() << "\n";
    std::cerr << "Default dialect: "
              << collection.default_dialect.value_or("<NONE>") << "\n";

    for (const auto &entry :
         std::filesystem::recursive_directory_iterator{collection.path}) {
      const auto is_schema_file{entry.path().extension() == ".yaml" ||
                                entry.path().extension() == ".yml" ||
                                entry.path().extension() == ".json"};
      if (!entry.is_regular_file() || !is_schema_file ||
          entry.path().stem().string().starts_with(".")) {
        continue;
      }

      std::cerr << "-- Found schema: " << entry.path().string() << " (#"
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

      const auto result{resolver.add(configuration, collection, entry.path())};
      std::cerr << result.first << " => " << result.second << "\n";
    }
  }

  // --------------------------------------------
  // (3) Validate and materialise schemas
  // --------------------------------------------

  // TODO: We could parallelize this loop
  for (const auto &schema : resolver) {
    std::cerr << "Materialising: " << schema.first << "\n";
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
        schema.second.relative_path, subresult.value())};
    resolver.materialise(schema.first, destination);
  }

  // --------------------------------------------
  // (4) Generate schema artefacts
  // --------------------------------------------

  // TODO: We could parallelize this loop
  for (const auto &schema : resolver) {
    const auto subresult{resolver(schema.first)};
    assert(subresult.has_value());

    // Storing artefacts

    std::cerr << "Bundling: " << schema.first << "\n";
    auto bundled_schema{sourcemeta::core::bundle(
        subresult.value(), sourcemeta::core::schema_official_walker, resolver)};
    output.write_schema_bundle(schema.second.relative_path, bundled_schema);

    std::cerr << "Framing bundle: " << schema.first << "\n";
    sourcemeta::core::SchemaFrame frame{
        sourcemeta::core::SchemaFrame::Mode::References};
    frame.analyse(bundled_schema, sourcemeta::core::schema_official_walker,
                  resolver);

    std::cerr << "Compiling in fast mode: " << schema.first << "\n";
    const auto template_fast{sourcemeta::blaze::compile(
        bundled_schema, sourcemeta::core::schema_official_walker, resolver,
        sourcemeta::blaze::default_schema_compiler, frame,
        sourcemeta::blaze::Mode::FastValidation)};
    output.write_schema_template_fast(schema.second.relative_path,
                                      template_fast);

    // TODO: Can we re-use the frame here?
    std::cerr << "Bundling without identifiers: " << schema.first << "\n";
    sourcemeta::core::unidentify(
        bundled_schema, sourcemeta::core::schema_official_walker, resolver);
    output.write_schema_bundle_unidentified(schema.second.relative_path,
                                            bundled_schema);
  }

  // --------------------------------------------
  // (5) Generate schema search index
  // --------------------------------------------

  // TODO: We could parallelize this loop
  std::vector<sourcemeta::core::JSON> search_index;
  search_index.reserve(resolver.size());
  for (const auto &schema : resolver) {
    std::cerr << "Generating search index: " << schema.first << "\n";
    auto entry{sourcemeta::core::JSON::make_array()};
    entry.push_back(
        sourcemeta::core::JSON{"/" + schema.second.relative_path.string()});
    const auto result{resolver(schema.first)};
    assert(result.has_value());
    if (result.value().is_object()) {
      entry.push_back(sourcemeta::core::JSON{
          result.value().at_or("title", sourcemeta::core::JSON{""}).trim()});
      entry.push_back(sourcemeta::core::JSON{
          result.value()
              .at_or("description", sourcemeta::core::JSON{""})
              .trim()});
    } else {
      entry.push_back(sourcemeta::core::JSON{""});
      entry.push_back(sourcemeta::core::JSON{""});
    }

    search_index.push_back(std::move(entry));
  }

  // Make sure more relevant entries get prioritised
  std::sort(search_index.begin(), search_index.end(), search_index_comparator);
  output.write_search(search_index.cbegin(), search_index.cend());

  // --------------------------------------------
  // (6) Generate schema navigation indexes
  // --------------------------------------------

  const auto base{
      output.absolute_path(sourcemeta::registry::Output::Category::Schemas)};
  std::cerr << "Indexing: " << base.string() << "\n";
  output.write_generated_json(
      "index.json",
      sourcemeta::registry::toc(configuration, resolver, base, base));
  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{base}) {
    if (entry.is_directory()) {
      std::cerr << "Indexing: " << entry.path().string() << "\n";
      auto toc{sourcemeta::registry::toc(configuration, resolver, base,
                                         entry.path())};
      output.write_generated_json(
          std::filesystem::relative(entry.path(), base) / "index.json",
          std::move(toc));
    }
  }

  // --------------------------------------------
  // (7) Generate schema explorer
  // --------------------------------------------

  // TODO: Make the explorer generator use the Output class to writing files
  sourcemeta::registry::explorer(
      configuration.get(),
      output.absolute_path(sourcemeta::registry::Output::Category::Generated),
      [](const auto &path) {
        std::cerr << "Generating HTML: " << path.string() << "\n";
      });

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
    std::cerr << "error: " << error.what() << "\n  at " << error.id() << "\n";
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
