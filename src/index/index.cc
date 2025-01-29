#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>
#include <sourcemeta/core/yaml.h>

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
#include <map>         // std::map
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

static auto is_yaml(const std::filesystem::path &path) -> bool {
  return path.extension() == ".yaml" || path.extension() == ".yml";
}

static auto is_schema_file(const std::filesystem::path &path) -> bool {
  return is_yaml(path) || path.extension() == ".json";
}

static auto schema_reader(const std::filesystem::path &path)
    -> sourcemeta::core::JSON {
  return is_yaml(path) ? sourcemeta::core::read_yaml(path)
                       : sourcemeta::core::read_json(path);
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
    std::filesystem::path current{result.str()};
    if (is_yaml(current)) {
      current.replace_extension(std::string{"."} + extension);
      return current.string();
    }

    result << '.';
    result << extension;
  }

  return result.str();
}

static auto
print_validation_output(const sourcemeta::blaze::ErrorOutput &output) -> void {
  for (const auto &entry : output) {
    std::cerr << entry.message << "\n";
    std::cerr << "  at instance location \"";
    sourcemeta::core::stringify(entry.instance_location, std::cerr);
    std::cerr << "\"\n";
    std::cerr << "  at evaluate path \"";
    sourcemeta::core::stringify(entry.evaluate_path, std::cerr);
    std::cerr << "\"\n";
  }
}

static auto
wrap_resolver(const sourcemeta::core::SchemaFlatFileResolver &resolver)
    -> sourcemeta::core::SchemaResolver {
  return [&resolver](const std::string_view identifier) {
    const auto result{resolver(identifier)};
    // Try with a `.json` extension as a fallback, as we do add this
    // extension when a schema doesn't have it by default
    if (!result.has_value() && !identifier.starts_with(".json")) {
      return resolver(std::string{identifier} + ".json");
    }

    return result;
  };
}

static auto index(sourcemeta::core::SchemaFlatFileResolver &resolver,
                  const sourcemeta::core::URI &server_url,
                  const sourcemeta::core::JSON &configuration,
                  const std::filesystem::path &base,
                  const std::filesystem::path &output) -> int {
  assert(std::filesystem::exists(base));
  assert(std::filesystem::exists(output));

  // Populate flat file resolver
  for (const auto &schema_entry : configuration.at("schemas").as_object()) {
    const auto collection_path{std::filesystem::canonical(
        base / schema_entry.second.at("path").to_string())};
    const auto collection_base_uri{
        sourcemeta::core::URI{schema_entry.second.at("base").to_string()}
            .canonicalize()};
    const auto collection_base_uri_string{collection_base_uri.recompose()};

    std::cerr << "Discovering schemas at: " << collection_path.string() << "\n";

    const std::optional<std::string> default_dialect{
        schema_entry.second.defines("defaultDialect")
            ? schema_entry.second.at("defaultDialect").to_string()
            : static_cast<std::optional<std::string>>(std::nullopt)};
    if (default_dialect.has_value()) {
      std::cerr << "Default dialect: " << default_dialect.value() << "\n";
    }

    for (const auto &entry :
         std::filesystem::recursive_directory_iterator{collection_path}) {
      if (!entry.is_regular_file() || !is_schema_file(entry.path()) ||
          entry.path().stem().string().starts_with(".")) {
        continue;
      }

      std::cerr << "-- Found schema: " << entry.path().string() << "\n";

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
                                                  default_identifier.str(),
                                                  schema_reader)};

      auto identifier_uri{
          sourcemeta::core::URI{current_identifier == collection_base_uri_string
                                    ? default_identifier.str()
                                    : current_identifier}
              .canonicalize()};
      std::cerr << identifier_uri.recompose();
      identifier_uri.relative_to(collection_base_uri);
      if (identifier_uri.is_absolute()) {
        std::cout << "\nerror: Cannot resolve the schema identifier against "
                     "the collection base\n";
        return EXIT_FAILURE;
      }

      assert(!identifier_uri.recompose().empty());
      const auto new_identifier{
          url_join(server_url.recompose(), schema_entry.first,
                   identifier_uri.recompose(),
                   // We want to guarantee identifiers end with a JSON
                   // extension, as we want to use the non-extension URI to
                   // potentially metadata about schemas, etc
                   "json")};
      std::cerr << " => " << new_identifier << "\n";
      // Otherwise we have things like "../" that should not be there
      assert(new_identifier.find("..") == std::string::npos);
      resolver.reidentify(current_identifier, new_identifier);
    }
  }

  std::map<std::string, sourcemeta::blaze::Template> compiled_schemas;
  for (const auto &schema : resolver) {
    std::cerr << "-- Processing schema: " << schema.first << "\n";
    sourcemeta::core::URI schema_uri{schema.first};
    schema_uri.relative_to(server_url);
    assert(schema_uri.is_relative());
    const auto schema_output{std::filesystem::weakly_canonical(
        output / "schemas" / schema_uri.recompose())};
    std::cerr << "Schema output: " << schema_output.string() << "\n";
    const auto result{resolver(schema.first)};
    if (!result.has_value()) {
      std::cout << "Cannot resolve the schema with identifier " << schema.first
                << "\n";
      return EXIT_FAILURE;
    }

    const auto dialect_identifier{sourcemeta::core::dialect(result.value())};
    assert(dialect_identifier.has_value());
    if (!compiled_schemas.contains(dialect_identifier.value())) {
      const auto metaschema{
          wrap_resolver(resolver)(dialect_identifier.value())};
      assert(metaschema.has_value());
      std::cerr << "Compiling metaschema: " << dialect_identifier.value()
                << "\n";
      compiled_schemas.emplace(
          dialect_identifier.value(),
          sourcemeta::blaze::compile(metaschema.value(),
                                     sourcemeta::core::schema_official_walker,
                                     wrap_resolver(resolver),
                                     sourcemeta::blaze::default_schema_compiler,
                                     sourcemeta::blaze::Mode::FastValidation));
    }

    sourcemeta::blaze::ErrorOutput validation_output{result.value()};
    sourcemeta::blaze::Evaluator evaluator;
    std::cerr << "Validating against its metaschema: " << schema.first << "\n";
    const auto metaschema_validation_result{
        evaluator.validate(compiled_schemas.at(dialect_identifier.value()),
                           result.value(), std::ref(validation_output))};
    if (!metaschema_validation_result) {
      std::cerr << "error: The schema does not adhere to its metaschema\n";
      print_validation_output(validation_output);
      return EXIT_FAILURE;
    }

    std::filesystem::create_directories(schema_output.parent_path());
    std::ofstream stream{schema_output};
    sourcemeta::core::prettify(result.value(), stream,
                               sourcemeta::core::schema_format_compare);
    stream << "\n";

    auto bundle_path{
        output / "bundles" /
        std::filesystem::relative(schema_output, output / "schemas")};
    std::filesystem::create_directories(bundle_path.parent_path());
    std::cerr << "Bundling: " << schema.first << "\n";
    auto bundled_schema{sourcemeta::core::bundle(
        result.value(), sourcemeta::core::schema_official_walker,
        wrap_resolver(resolver))};
    std::ofstream bundle_stream{bundle_path};
    sourcemeta::core::prettify(bundled_schema, bundle_stream,
                               sourcemeta::core::schema_format_compare);
    bundle_stream << "\n";

    auto unidentified_path{
        output / "unidentified" /
        std::filesystem::relative(schema_output, output / "schemas")};
    std::filesystem::create_directories(unidentified_path.parent_path());
    std::cerr << "Bundling without identifiers: " << schema.first << "\n";
    sourcemeta::core::unidentify(bundled_schema,
                                 sourcemeta::core::schema_official_walker,
                                 wrap_resolver(resolver));
    std::ofstream unidentified_stream{unidentified_path};
    sourcemeta::core::prettify(bundled_schema, unidentified_stream,
                               sourcemeta::core::schema_format_compare);
    unidentified_stream << "\n";
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

  std::cerr << "Using configuration: " << configuration_path.string() << "\n";
  std::cerr << "Writing output to: " << output.string() << "\n";

  const auto configuration_schema{sourcemeta::core::parse_json(
      std::string{sourcemeta::registry::SCHEMA_CONFIGURATION})};
  const auto compiled_configuration_schema{sourcemeta::blaze::compile(
      configuration_schema, sourcemeta::core::schema_official_walker,
      sourcemeta::core::official_resolver,
      sourcemeta::blaze::default_schema_compiler,
      sourcemeta::blaze::Mode::Exhaustive)};

  const auto configuration{sourcemeta::core::read_json(configuration_path)};
  sourcemeta::blaze::ErrorOutput validation_output{configuration};
  sourcemeta::blaze::Evaluator evaluator;
  const auto result{evaluator.validate(compiled_configuration_schema,
                                       configuration,
                                       std::ref(validation_output))};
  if (!result) {
    std::cerr << "error: Invalid configuration\n";
    print_validation_output(validation_output);
    return EXIT_FAILURE;
  }

  std::filesystem::create_directories(output);

  auto configuration_with_defaults = configuration;

  // TODO: Perform these with a Blaze helper function that applies schema
  // "default"s to an instance

  if (!configuration_with_defaults.defines("title")) {
    configuration_with_defaults.assign("title",
                                       sourcemeta::core::JSON{"Sourcemeta"});
  }

  if (!configuration_with_defaults.defines("description")) {
    configuration_with_defaults.assign(
        "description",
        sourcemeta::core::JSON{"The next-generation JSON Schema Registry"});
  }

  // Save the configuration file too
  auto configuration_copy = configuration_with_defaults;
  configuration_copy.erase("schemas");
  configuration_copy.erase("pages");

  std::ofstream stream{output / "configuration.json"};
  sourcemeta::core::prettify(configuration_copy, stream);
  stream << "\n";

  sourcemeta::core::SchemaFlatFileResolver resolver{
      sourcemeta::core::official_resolver};
  const auto server_url{
      sourcemeta::core::URI{configuration.at("url").to_string()}
          .canonicalize()};
  const auto code{index(resolver, server_url, configuration_with_defaults,
                        configuration_path.parent_path(), output)};

#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
  if (code == EXIT_SUCCESS) {
    return sourcemeta::registry::enterprise::attach(
        wrap_resolver(resolver), server_url, configuration_with_defaults,
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
  } catch (const sourcemeta::core::SchemaResolutionError &error) {
    std::cerr << "error: " << error.what() << "\n  at " << error.id() << "\n";
    return EXIT_FAILURE;
  } catch (const std::exception &error) {
    std::cerr << "unexpected error: " << error.what() << "\n";
    return EXIT_FAILURE;
  }
}
