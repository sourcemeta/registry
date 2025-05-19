#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>
#include <sourcemeta/core/yaml.h>

#include "configuration.h"
#include "configure.h"
#include "html.h"
#include "output.h"
#include "validator.h"

#include <algorithm>   // std::sort
#include <cassert>     // assert
#include <cctype>      // std::tolower
#include <cstdlib>     // EXIT_FAILURE, EXIT_SUCCESS
#include <exception>   // std::exception
#include <filesystem>  // std::filesystem
#include <fstream>     // std::ofstream
#include <functional>  // std::ref
#include <iostream>    // std::cerr, std::cout
#include <map>         // std::map
#include <regex>       // std::regex, std::smatch, std::regex_search
#include <span>        // std::span
#include <sstream>     // std::ostringstream
#include <string>      // std::string
#include <string_view> // std::string_view
#include <tuple>       // std::tuple, std::make_tuple
#include <utility>     // std::move
#include <vector>      // std::vector

template <typename T>
static auto write_lower_except_trailing(T &stream, const std::string &input,
                                        const char trailing) -> void {
  for (auto iterator = input.cbegin(); iterator != input.cend(); ++iterator) {
    if (std::next(iterator) != input.cend() || *iterator != trailing) {
      stream << static_cast<char>(std::tolower(*iterator));
    }
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

// TODO: Elevate to Core as a JSON string method
static auto trim(const std::string &input) -> std::string {
  auto copy = input;
  copy.erase(copy.find_last_not_of(' ') + 1);
  copy.erase(0, copy.find_first_not_of(' '));
  return copy;
}

static auto try_parse_version(const sourcemeta::core::JSON::String &name)
    -> std::optional<std::tuple<unsigned, unsigned, unsigned>> {
  std::regex version_regex(R"(v?(\d+)\.(\d+)\.(\d+))");
  std::smatch match;

  if (std::regex_search(name, match, version_regex)) {
    return std::make_tuple(std::stoul(match[1]), std::stoul(match[2]),
                           std::stoul(match[3]));
  }

  return std::nullopt;
}

static auto base_dialect_id(const std::string &base_dialect) -> std::string {
  if (base_dialect == "https://json-schema.org/draft/2020-12/schema" ||
      base_dialect == "https://json-schema.org/draft/2020-12/hyper-schema") {
    return "2020-12";
  }

  if (base_dialect == "https://json-schema.org/draft/2019-09/schema" ||
      base_dialect == "https://json-schema.org/draft/2019-09/hyper-schema") {
    return "2019-09";
  }

  if (base_dialect == "http://json-schema.org/draft-07/schema#" ||
      base_dialect == "http://json-schema.org/draft-07/hyper-schema#") {
    return "draft7";
  }

  if (base_dialect == "http://json-schema.org/draft-06/schema#" ||
      base_dialect == "http://json-schema.org/draft-06/hyper-schema#") {
    return "draft6";
  }

  if (base_dialect == "http://json-schema.org/draft-04/schema#" ||
      base_dialect == "http://json-schema.org/draft-04/hyper-schema#") {
    return "draft4";
  }

  if (base_dialect == "http://json-schema.org/draft-03/schema#" ||
      base_dialect == "http://json-schema.org/draft-03/hyper-schema#") {
    return "draft3";
  }

  if (base_dialect == "http://json-schema.org/draft-02/hyper-schema#") {
    return "draft2";
  }

  if (base_dialect == "http://json-schema.org/draft-01/hyper-schema#") {
    return "draft1";
  }

  if (base_dialect == "http://json-schema.org/draft-00/hyper-schema#") {
    return "draft0";
  }

  // We should never get here
  assert(false);
  return "Unknown";
}

auto generate_toc(RegistryOutput &output,
                  const sourcemeta::core::SchemaResolver &resolver,
                  const sourcemeta::core::URI &server_url,
                  const sourcemeta::core::JSON &configuration,
                  const std::filesystem::path &base,
                  const std::filesystem::path &directory,
                  std::vector<sourcemeta::core::JSON> &search_index) -> void {
  const auto server_url_string{server_url.recompose()};
  assert(directory.string().starts_with(base.string()));
  auto entries{sourcemeta::core::JSON::make_array()};

  for (const auto &entry : std::filesystem::directory_iterator{directory}) {
    auto entry_json{sourcemeta::core::JSON::make_object()};
    entry_json.assign("name", sourcemeta::core::JSON{entry.path().filename()});
    const auto entry_relative_path{
        entry.path().string().substr(base.string().size())};
    if (entry.is_directory()) {
      const auto collection_entry_name{entry_relative_path.substr(1)};
      if (configuration.defines("pages") &&
          configuration.at("pages").defines(collection_entry_name)) {
        for (const auto &page_entry :
             configuration.at("pages").at(collection_entry_name).as_object()) {
          entry_json.assign(page_entry.first, page_entry.second);
        }
      }

      entry_json.assign("type", sourcemeta::core::JSON{"directory"});
      entry_json.assign(
          "url", sourcemeta::core::JSON{
                     entry.path().string().substr(base.string().size())});

      entries.push_back(std::move(entry_json));
    } else if (entry.path().extension() == ".json" &&
               !entry.path().stem().string().starts_with(".")) {
      const auto schema{sourcemeta::core::read_json(entry.path())};
      entry_json.assign("type", sourcemeta::core::JSON{"schema"});
      if (schema.is_object() && schema.defines("title") &&
          schema.at("title").is_string()) {
        entry_json.assign("title", sourcemeta::core::JSON{
                                       trim(schema.at("title").to_string())});
      }

      if (schema.is_object() && schema.defines("description") &&
          schema.at("description").is_string()) {
        entry_json.assign(
            "description",
            sourcemeta::core::JSON{trim(schema.at("description").to_string())});
      }

      // Calculate base dialect
      std::ostringstream absolute_schema_url;
      absolute_schema_url << server_url_string;

      // TODO: We should have better utilities to avoid these
      // URL concatenation edge cases

      if (!server_url_string.ends_with('/')) {
        absolute_schema_url << '/';
      }

      if (entry_relative_path.starts_with('/')) {
        absolute_schema_url << entry_relative_path.substr(1);
      } else {
        absolute_schema_url << entry_relative_path;
      }

      const auto resolved_schema{resolver(absolute_schema_url.str())};
      assert(resolved_schema.has_value());
      const auto base_dialect{sourcemeta::core::base_dialect(schema, resolver)};
      assert(base_dialect.has_value());
      entry_json.assign("baseDialect", sourcemeta::core::JSON{base_dialect_id(
                                           base_dialect.value())});

      entry_json.assign("url", sourcemeta::core::JSON{entry_relative_path});

      // Collect schemas high-level metadata for searching purposes
      auto search_entry{sourcemeta::core::JSON::make_array()};
      search_entry.push_back(entry_json.at("url"));
      search_entry.push_back(entry_json.defines("title")
                                 ? entry_json.at("title")
                                 : sourcemeta::core::JSON{""});
      search_entry.push_back(entry_json.defines("description")
                                 ? entry_json.at("description")
                                 : sourcemeta::core::JSON{""});
      search_index.push_back(std::move(search_entry));

      entries.push_back(std::move(entry_json));
    }
  }

  std::sort(
      entries.as_array().begin(), entries.as_array().end(),
      [](const auto &left, const auto &right) {
        if (left.at("type") == right.at("type")) {
          const auto &left_name{left.at("name")};
          const auto &right_name{right.at("name")};

          // If the schema/directories represent SemVer versions, attempt to
          // parse them as such and provide better sorting
          const auto left_version{try_parse_version(left_name.to_string())};
          const auto right_version{try_parse_version(right_name.to_string())};
          if (left_version.has_value() && right_version.has_value()) {
            return left_version.value() > right_version.value();
          }

          return left_name > right_name;
        }

        return left.at("type") < right.at("type");
      });

  auto meta{sourcemeta::core::JSON::make_object()};
  const auto page_entry_name{
      std::filesystem::relative(directory, base).string()};

  // Precompute page metadata
  if (configuration.defines("pages") &&
      configuration.at("pages").defines(page_entry_name)) {
    for (const auto &entry :
         configuration.at("pages").at(page_entry_name).as_object()) {
      meta.assign(entry.first, entry.second);
    }
  }

  // Store entries
  meta.assign("entries", std::move(entries));

  // Precompute the breadcrumb
  const std::filesystem::path relative_path{directory.string().substr(
      std::min(base.string().size() + 1, directory.string().size()))};
  meta.assign("breadcrumb", sourcemeta::core::JSON::make_array());
  std::filesystem::path current_path{"/"};
  for (const auto &part : relative_path) {
    current_path = current_path / part;
    auto breadcrumb_entry{sourcemeta::core::JSON::make_object()};
    breadcrumb_entry.assign("name", sourcemeta::core::JSON{part});
    breadcrumb_entry.assign("url", sourcemeta::core::JSON{current_path});
    meta.at("breadcrumb").push_back(std::move(breadcrumb_entry));
  }

  const auto index_path{base.parent_path() / "generated" /
                        std::filesystem::relative(directory, base) /
                        "index.json"};
  std::cerr << "Saving into: " << index_path.string() << "\n";
  output.write_generated_json(
      std::filesystem::relative(directory, base) / "index.json", meta);

  if (directory == base) {
    std::cerr << "Generating HTML index page\n";
    std::ofstream html{index_path.parent_path() / "index.html"};
    assert(!html.fail());
    sourcemeta::registry::html::SafeOutput output_html{html};
    sourcemeta::registry::html_start(
        output_html, configuration,
        configuration.at("title").to_string() + " Schemas",
        configuration.at("description").to_string(), "");

    if (configuration.defines("hero")) {
      output_html.open("div", {{"class", "container-fluid px-4"}})
          .open("div",
                {{"class",
                  "bg-light border border-light-subtle mt-4 px-3 py-3"}});
      output_html.unsafe(configuration.at("hero").to_string());
      output_html.close("div").close("div");
    }

    sourcemeta::registry::html_file_manager(html, meta);
    sourcemeta::registry::html_end(output_html);
    html << "\n";
    html.close();
  } else {
    std::cerr << "Generating HTML directory page\n";
    const auto page_relative_path{std::string{'/'} + relative_path.string()};
    std::ofstream html{index_path.parent_path() / "index.html"};
    assert(!html.fail());
    sourcemeta::registry::html::SafeOutput output_html{html};
    sourcemeta::registry::html_start(
        output_html, configuration,
        meta.defines("title") ? meta.at("title").to_string()
                              : page_relative_path,
        meta.defines("description")
            ? meta.at("description").to_string()
            : ("Schemas located at " + page_relative_path),
        page_relative_path);
    sourcemeta::registry::html_file_manager(html, meta);
    sourcemeta::registry::html_end(output_html);
    html << "\n";
    html.close();
  }
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
  RegistryOutput output{output_path};
  std::cerr << "Writing output to: " << output_path.string() << "\n";

  // Read and validate the configuration file
  sourcemeta::core::SchemaFlatFileResolver resolver{
      sourcemeta::core::schema_official_resolver};
  RegistryValidator validator{resolver};
  const auto configuration_path{std::filesystem::canonical(arguments[0])};
  std::cerr << "Using configuration: " << configuration_path.string() << "\n";
  const RegistryConfiguration configuration{configuration_path};
  validator.validate_or_throw(configuration.schema(), configuration.get(),
                              "Invalid configuration");
  output.write_configuration(configuration);

  std::size_t count{0};

  // Populate flat file resolver
  for (const auto &schema_entry :
       configuration.get().at("schemas").as_object()) {
    const auto collection_path{
        configuration.path(schema_entry.second.at("path").to_string())};
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

      count += 1;
      std::cerr << "-- Found schema: " << entry.path().string() << " (#"
                << count << ")\n";

      // See https://github.com/sourcemeta/registry/blob/main/LICENSE
#if defined(SOURCEMETA_REGISTRY_PRO)
      constexpr auto SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_PRO{1000};
      if (count > SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_PRO) {
        std::cerr << "error: The Pro edition is restricted to "
                  << SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_PRO << " schemas\n";
        std::cerr << "Upgrade to the Enterprise edition to waive limits\n";
        std::cerr << "Buy a new license at https://www.sourcemeta.com\n";
        return EXIT_FAILURE;
      }
#elif defined(SOURCEMETA_REGISTRY_STARTER)
      constexpr auto SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_STARTER{100};
      if (count > SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_STARTER) {
        std::cerr << "error: The Starter edition is restricted to "
                  << SOURCEMETA_REGISTRY_SCHEMAS_LIMIT_STARTER << " schemas\n";
        std::cerr << "Buy a Pro or Enterprise license at "
                     "https://www.sourcemeta.com\n";
        return EXIT_FAILURE;
      }
#endif

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

      const auto &current_identifier{resolver.add(
          entry.path(), default_dialect, default_identifier.str(),
          schema_reader,
          [&schema_entry](sourcemeta::core::JSON &schema,
                          const sourcemeta::core::URI &base,
                          const sourcemeta::core::JSON::String &vocabulary,
                          const sourcemeta::core::JSON::String &keyword,
                          sourcemeta::core::URI &value) {
            sourcemeta::core::reference_visitor_relativize(
                schema, base, vocabulary, keyword, value);

            if (schema_entry.second.defines("rebase") && value.is_absolute()) {
              for (const auto &rebase :
                   schema_entry.second.at("rebase").as_array()) {
                const auto from{
                    sourcemeta::core::URI{rebase.at("from").to_string()}
                        .canonicalize()};
                auto value_copy = value;
                value_copy.relative_to(from);
                if (value_copy.is_relative()) {
                  value.rebase(
                      from, sourcemeta::core::URI{rebase.at("to").to_string()}
                                .canonicalize());
                  schema.assign(keyword,
                                sourcemeta::core::JSON{value.recompose()});
                }
              }
            }
          })};

      auto identifier_uri{
          sourcemeta::core::URI{current_identifier == collection_base_uri_string
                                    ? default_identifier.str()
                                    : current_identifier}
              .canonicalize()};
      std::cerr << identifier_uri.recompose();
      const auto current{identifier_uri.recompose()};
      identifier_uri.relative_to(collection_base_uri);
      if (identifier_uri.is_absolute()) {
        std::cerr << "\nerror: Cannot resolve the schema identifier ("
                  << current
                  << ") against "
                     "the collection base ("
                  << collection_base_uri_string << ")\n";
        return EXIT_FAILURE;
      }

      assert(!identifier_uri.recompose().empty());
      const auto new_identifier{
          url_join(configuration.url().recompose(), schema_entry.first,
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

  // TODO: Why do we need this?
  const auto wrapped_resolver{wrap_resolver(resolver)};
  for (const auto &schema : resolver) {
    std::cerr << "-- Processing schema: " << schema.first << "\n";
    sourcemeta::core::URI schema_uri{schema.first};
    schema_uri.relative_to(configuration.url());
    assert(schema_uri.is_relative());
    std::cerr << "Schema output: " << schema_uri.recompose() << "\n";
    const auto subresult{resolver(schema.first)};
    assert(subresult.has_value());
    const auto dialect_identifier{sourcemeta::core::dialect(subresult.value())};
    assert(dialect_identifier.has_value());
    const auto metaschema{wrapped_resolver(dialect_identifier.value())};
    assert(metaschema.has_value());
    std::cerr << "Validating against its metaschema: " << schema.first << "\n";
    validator.validate_or_throw(dialect_identifier.value(), metaschema.value(),
                                subresult.value(),
                                "The schema does not adhere to its metaschema");

    // Storing artefacts
    output.write_schema_single(schema_uri.recompose(), subresult.value());
    std::cerr << "Bundling: " << schema.first << "\n";
    auto bundled_schema{sourcemeta::core::bundle(
        subresult.value(), sourcemeta::core::schema_official_walker,
        wrapped_resolver)};
    output.write_schema_bundle(schema_uri.recompose(), bundled_schema);
    std::cerr << "Bundling without identifiers: " << schema.first << "\n";
    sourcemeta::core::unidentify(bundled_schema,
                                 sourcemeta::core::schema_official_walker,
                                 wrapped_resolver);
    output.write_schema_bundle_unidentified(schema_uri.recompose(),
                                            bundled_schema);
  }

  std::cerr << "-- Indexing directory: " << output_path.string() << "\n";
  const auto base{std::filesystem::canonical(output_path / "schemas")};
  std::vector<sourcemeta::core::JSON> search_index;
  generate_toc(output, wrapped_resolver, configuration.url(),
               configuration.get(), base, base, search_index);
  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{output_path / "schemas"}) {
    if (entry.is_directory()) {
      std::cerr << "-- Processing: " << entry.path().string() << "\n";
      generate_toc(output, wrapped_resolver, configuration.url(),
                   configuration.get(), base,
                   std::filesystem::canonical(entry.path()), search_index);
    }
  }

  // Make newer versions of schemas appear first
  std::sort(search_index.begin(), search_index.end(),
            [](const auto &left, const auto &right) {
              return left.at(0) > right.at(0);
            });

  output.write_generated_jsonl("search.jsonl", search_index.cbegin(),
                               search_index.cend());

  // Not found page
  std::ofstream stream_not_found{output_path / "generated" / "404.html"};
  assert(!stream_not_found.fail());
  sourcemeta::registry::html::SafeOutput output_html{stream_not_found};
  sourcemeta::registry::html_start(
      output_html, configuration.get(), "Not Found",
      "What you are looking for is not here", std::nullopt);
  output_html.open("div", {{"class", "container-fluid p-4"}})
      .open("h2", {{"class", "fw-bold"}})
      .text("Oops! What you are looking for is not here")
      .close("h2")
      .open("p", {{"class", "lead"}})
      .text("Are you sure the link you got is correct?")
      .close("p")
      .open("a", {{"href", "/"}})
      .text("Get back to the home page")
      .close("a")
      .close("div")
      .close("div");
  sourcemeta::registry::html_end(output_html);
  stream_not_found << "\n";
  stream_not_found.close();

  return EXIT_SUCCESS;
}

auto main(int argc, char *argv[]) noexcept -> int {
  try {
    const std::string_view program{argv[0]};
    const std::vector<std::string> arguments{argv + std::min(1, argc),
                                             argv + argc};
    return index_main(program, arguments);
  } catch (const RegistryValidatorError &error) {
    std::cerr << "error: " << error.what() << "\n" << error.stacktrace();
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
