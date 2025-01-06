#include <sourcemeta/jsontoolkit/json.h>
#include <sourcemeta/jsontoolkit/jsonschema.h>
#include <sourcemeta/jsontoolkit/uri.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>

#include "configure.h"

#include <cassert>     // assert
#include <cctype>      // std::tolower
#include <cstdlib>     // EXIT_FAILURE, EXIT_SUCCESS
#include <exception>   // std::exception
#include <filesystem>  // std::filesystem
#include <fstream>     // std::ofstream
#include <functional>  // std::ref
#include <iostream>    // std::cerr, std::cout
#include <span>        // std::span
#include <sstream>     // std::ostringstream
#include <string>      // std::string
#include <string_view> // std::string_view
#include <vector>      // std::vector

#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
#include "enterprise_index.h"
#endif

template <typename T>
static auto write_lower_except_trailing(T &stream, const std::string &input,
                                        const char trailing) -> void {
  for (auto iterator = input.cbegin(); iterator != input.cend(); ++iterator) {
    if (std::next(iterator) == input.cend() && *iterator == trailing) {
      continue;
    }

    stream << static_cast<char>(std::tolower(*iterator));
  }
}

static auto url_join(const std::string &first, const std::string &second,
                     const std::string &third, const std::string &extension)
    -> std::string {
  std::ostringstream result;
  write_lower_except_trailing(result, first, '/');
  result << '/';
  write_lower_except_trailing(result, second, '/');
  result << '/';
  write_lower_except_trailing(result, third, '.');
  if (!result.str().ends_with(extension)) {
    result << '.';
    result << extension;
  }

  return result.str();
}

static auto index(sourcemeta::jsontoolkit::FlatFileSchemaResolver &resolver,
                  const sourcemeta::jsontoolkit::URI &server_url,
                  const sourcemeta::jsontoolkit::JSON &configuration,
                  const std::filesystem::path &base,
                  const std::filesystem::path &output) -> int {
  assert(std::filesystem::exists(base));
  assert(std::filesystem::exists(output));

  // Populate flat file resolver
  for (const auto &schema_entry : configuration.at("schemas").as_object()) {
    const auto collection_path{std::filesystem::canonical(
        base / schema_entry.second.at("path").to_string())};
    const auto collection_base_uri{
        sourcemeta::jsontoolkit::URI{schema_entry.second.at("base").to_string()}
            .canonicalize()};
    const auto collection_base_uri_string{collection_base_uri.recompose()};

    std::cerr << "-- Processing collection: " << schema_entry.first << "\n";
    std::cerr << "Base directory: " << collection_path.string() << "\n";
    std::cerr << "Base URI: " << collection_base_uri_string << "\n";

    const std::optional<std::string> default_dialect{
        schema_entry.second.defines("defaultDialect")
            ? schema_entry.second.at("defaultDialect").to_string()
            : static_cast<std::optional<std::string>>(std::nullopt)};
    if (default_dialect.has_value()) {
      std::cerr << "Default dialect: " << default_dialect.value() << "\n";
    }

    for (const auto &entry :
         std::filesystem::recursive_directory_iterator{collection_path}) {
      if (!entry.is_regular_file() || entry.path().extension() != ".json" ||
          entry.path().stem().string().starts_with(".")) {
        continue;
      }

      std::cerr << "Found schema: " << entry.path().string() << "\n";

      // Calculate a default identifier for the schema through their file system
      // location, to accomodate for schema collections that purely rely on
      // paths and never set `$id`.
      const auto relative_path{
          std::filesystem::relative(entry.path(), collection_path).string()};
      assert(!relative_path.starts_with('/'));
      std::ostringstream default_identifier;
      default_identifier << collection_base_uri_string;
      if (!collection_base_uri_string.ends_with('/')) {
        default_identifier << '/';
      }

      default_identifier << relative_path;

      const auto &current_identifier{resolver.add(entry.path(), default_dialect,
                                                  default_identifier.str())};
      auto identifier_uri{
          sourcemeta::jsontoolkit::URI{current_identifier}.canonicalize()};
      std::cerr << "Current identifier: " << identifier_uri.recompose() << "\n";
      identifier_uri.relative_to(collection_base_uri);
      if (identifier_uri.is_absolute()) {
        std::cout << "Cannot resolve the schema identifier against the "
                     "collection base\n";
        return EXIT_FAILURE;
      }

      const auto new_identifier{
          url_join(server_url.recompose(), schema_entry.first,
                   identifier_uri.recompose(),
                   // We want to guarantee identifiers end with a JSON
                   // extension, as we want to use the non-extension URI to
                   // potentially metadata about schemas, etc
                   "json")};
      std::cerr << "Rebased identifier: " << new_identifier << "\n";
      resolver.reidentify(current_identifier, new_identifier);
    }
  }

  for (const auto &schema : resolver) {
    std::cerr << "-- Processing schema: " << schema.first << "\n";
    sourcemeta::jsontoolkit::URI schema_uri{schema.first};
    schema_uri.relative_to(server_url);
    assert(schema_uri.is_relative());
    const auto schema_output{std::filesystem::weakly_canonical(
        output / "schemas" / schema_uri.recompose())};
    std::cerr << "Schema output: " << schema_output.string() << "\n";
    std::filesystem::create_directories(schema_output.parent_path());
    std::ofstream stream{schema_output};
    const auto result{resolver(schema.first)};
    if (!result.has_value()) {
      std::cout << "Cannot resolve the schema with identifier " << schema.first
                << "\n";
      return EXIT_FAILURE;
    }

    sourcemeta::jsontoolkit::prettify(
        result.value(), stream, sourcemeta::jsontoolkit::schema_format_compare);
    stream << "\n";
  }

  return EXIT_SUCCESS;
}

static auto index_main(const std::string_view &program,
                       const std::span<const std::string> &arguments) -> int {
  std::cout << "Sourcemeta Registry v" << sourcemeta::registry::PROJECT_VERSION;
#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
  std::cout << " Enterprise ";
#else
  std::cout << " Community ";
#endif
  std::cout << "Edition\n";

  if (arguments.size() < 2) {
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
  configuration_copy.erase("pages");

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

  sourcemeta::jsontoolkit::FlatFileSchemaResolver resolver{
      sourcemeta::jsontoolkit::official_resolver};
  const auto server_url{
      sourcemeta::jsontoolkit::URI{configuration.at("url").to_string()}
          .canonicalize()};
  const auto code{index(resolver, server_url, configuration,
                        configuration_path.parent_path(), output)};

#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
  if (code == EXIT_SUCCESS) {
    return sourcemeta::registry::enterprise::attach(
        resolver, server_url, configuration, configuration_path.parent_path(),
        output);
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
