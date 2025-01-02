#include <sourcemeta/jsontoolkit/json.h>
#include <sourcemeta/jsontoolkit/jsonschema.h>
#include <sourcemeta/jsontoolkit/uri.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>

#include "configure.h"

#include <algorithm>   // std::transform
#include <cassert>     // assert
#include <cctype>      // std::tolower
#include <cstdlib>     // EXIT_FAILURE, EXIT_SUCCESS
#include <exception>   // std::exception
#include <filesystem>  // std::filesystem
#include <fstream>     // std::ofstream
#include <functional>  // std::ref
#include <iostream>    // std::cerr, std::cout
#include <span>        // std::span
#include <string>      // std::string
#include <string_view> // std::string_view
#include <vector>      // std::vector

#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
#include "enterprise_index.h"
#endif

static auto index(const sourcemeta::jsontoolkit::JSON &configuration,
                  const std::filesystem::path &base,
                  const std::filesystem::path &output) -> int {
  assert(std::filesystem::exists(base));
  assert(std::filesystem::exists(output));
  assert(configuration.is_object());
  assert(configuration.defines("schemas"));
  assert(configuration.at("schemas").is_object());

  for (const auto &schema_entry : configuration.at("schemas").as_object()) {
    assert(schema_entry.second.is_object());
    assert(schema_entry.second.defines("path"));
    assert(schema_entry.second.at("path").is_string());
    const auto collection_path{std::filesystem::canonical(
        base / schema_entry.second.at("path").to_string())};
    assert(schema_entry.second.defines("base"));
    assert(schema_entry.second.at("base").is_string());
    const auto collection_base_uri{
        sourcemeta::jsontoolkit::URI{schema_entry.second.at("base").to_string()}
            .canonicalize()};

    std::cerr << "-- Processing collection: " << schema_entry.first << "\n";
    std::cerr << "Base directory: " << collection_path.string() << "\n";
    std::cerr << "Base URI: " << collection_base_uri.recompose() << "\n";
    for (const auto &entry :
         std::filesystem::recursive_directory_iterator{collection_path}) {
      if (!entry.is_regular_file() || entry.path().extension() != ".json" ||
          entry.path().stem().string().starts_with(".")) {
        continue;
      }

      std::cerr << "Found schema: " << entry.path().string() << "\n";

      const auto schema{sourcemeta::jsontoolkit::from_file(entry.path())};
      const auto identifier{sourcemeta::jsontoolkit::identify(
          schema, sourcemeta::jsontoolkit::official_resolver,
          sourcemeta::jsontoolkit::IdentificationStrategy::Loose)};
      if (!identifier.has_value()) {
        std::cout << "Could not determine schema identifier\n";
        return EXIT_FAILURE;
      }

      auto identifier_uri{
          sourcemeta::jsontoolkit::URI{identifier.value()}.canonicalize()};
      std::cerr << "Schema identifier: " << identifier_uri.recompose() << "\n";
      identifier_uri.relative_to(collection_base_uri);
      if (identifier_uri.is_absolute()) {
        std::cout << "Cannot resolve the schema identifier against the "
                     "collection base\n";
        return EXIT_FAILURE;
      }

      auto schema_directory{schema_entry.first};
      std::transform(schema_directory.begin(), schema_directory.end(),
                     schema_directory.begin(), [](const auto character) {
                       return std::tolower(character);
                     });

      auto schema_basename{identifier_uri.recompose()};
      std::transform(schema_basename.begin(), schema_basename.end(),
                     schema_basename.begin(), [](const auto character) {
                       return std::tolower(character);
                     });

      const auto schema_output{std::filesystem::weakly_canonical(
          output / "schemas" / schema_directory / schema_basename)};
      std::cerr << "Schema output: " << schema_output.string() << "\n";

      // Note we copy as-is and we rebase IDs at runtime to correctly
      // handle meta-schemas that can only be resolved at runtime
      std::filesystem::create_directories(schema_output.parent_path());
      std::ofstream stream{schema_output};
      sourcemeta::jsontoolkit::prettify(
          schema, stream, sourcemeta::jsontoolkit::schema_format_compare);
      stream << "\n";
    }
  }

  return EXIT_SUCCESS;
}

static auto index_main(const std::string_view &program,
                       const std::span<const std::string> &arguments) -> int {
  if (arguments.size() < 2) {
    std::cout << "Sourcemeta Registry v"
              << sourcemeta::registry::PROJECT_VERSION;
#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
    std::cout << " Enterprise ";
#else
    std::cout << " Community ";
#endif
    std::cout << "Edition\n";
    std::cout << "Usage: " << std::filesystem::path{program}.filename().string()
              << " <configuration.json> <path/to/output/directory>\n";
    return EXIT_FAILURE;
  }

  const auto configuration_path{std::filesystem::canonical(arguments[0])};
  const auto output{std::filesystem::weakly_canonical(arguments[1])};

  std::cerr << "-- Using configuration: " << configuration_path.string()
            << "\n";
  std::cerr << "-- Writing output to: " << output.string() << "\n";

  const auto configuration_schema{sourcemeta::jsontoolkit::parse(
      std::string{sourcemeta::registry::SCHEMA_CONFIGURATION})};
  const auto compiled_configuration_schema{sourcemeta::blaze::compile(
      configuration_schema, sourcemeta::jsontoolkit::default_schema_walker,
      sourcemeta::jsontoolkit::official_resolver,
      sourcemeta::blaze::default_schema_compiler)};

  const auto configuration{
      sourcemeta::jsontoolkit::from_file(configuration_path)};
  sourcemeta::blaze::ErrorOutput validation_output{configuration};
  sourcemeta::blaze::Evaluator evaluator;
  const auto result{evaluator.validate(compiled_configuration_schema,
                                       configuration,
                                       std::ref(validation_output))};
  if (!result) {
    std::cerr << "error: Invalid configuration\n";
    for (const auto &entry : validation_output) {
      std::cerr << entry.message << "\n";
      std::cerr << "  at instance location \"";
      sourcemeta::jsontoolkit::stringify(entry.instance_location, std::cerr);
      std::cerr << "\"\n";
      std::cerr << "  at evaluate path \"";
      sourcemeta::jsontoolkit::stringify(entry.evaluate_path, std::cerr);
      std::cerr << "\"\n";
    }

    return EXIT_FAILURE;
  }

  std::filesystem::create_directories(output);

  // Save the configuration file too
  auto configuration_copy = configuration;
  configuration_copy.erase("schemas");

  // TODO: Perform these with a Blaze helper function that applies schema
  // "default"s to an instance

  if (!configuration_copy.defines("title")) {
    configuration_copy.assign("title",
                              sourcemeta::jsontoolkit::JSON{"Sourcemeta"});
  }

  if (!configuration_copy.defines("description")) {
    configuration_copy.assign("description",
                              sourcemeta::jsontoolkit::JSON{
                                  "The next-generation JSON Schema Registry"});
  }

  std::ofstream stream{output / "configuration.json"};
  sourcemeta::jsontoolkit::prettify(configuration_copy, stream);
  stream << "\n";

  const auto code{
      index(configuration, configuration_path.parent_path(), output)};

#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
  if (code == EXIT_SUCCESS) {
    return sourcemeta::registry::enterprise::attach(
        configuration, configuration_path.parent_path(), output);
  }
#endif

  return code;
}

auto main(int argc, char *argv[]) noexcept -> int {
  try {
    const std::string_view program{argv[0]};
    const std::vector<std::string> arguments{argv + std::min(1, argc),
                                             argv + argc};
    return index_main(program, arguments);
  } catch (const std::exception &error) {
    std::cerr << "unexpected error: " << error.what() << "\n";
    return EXIT_FAILURE;
  }
}
