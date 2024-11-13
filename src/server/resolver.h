#ifndef SOURCEMETA_REGISTRY_SERVER_RESOLVER_H_
#define SOURCEMETA_REGISTRY_SERVER_RESOLVER_H_

#include <sourcemeta/jsontoolkit/json.h>
#include <sourcemeta/jsontoolkit/jsonschema.h>
#include <sourcemeta/jsontoolkit/uri.h>

#include <cassert>     // assert
#include <cctype>      // std::tolower
#include <filesystem>  // std::filesystem
#include <optional>    // std::optional, std::nullopt
#include <sstream>     // std::ostringstream
#include <string>      // std::string
#include <string_view> // std::string_view

namespace sourcemeta::registry {

// TODO: Turn this into a "safe" path join that prevents going out of the base
auto path_join(const std::filesystem::path &base,
               const std::filesystem::path &path) -> std::filesystem::path {
  if (path.is_absolute()) {
    return (base / path.string().substr(1)).lexically_normal();
  }

  return (base / path).lexically_normal();
}

auto request_path_to_schema_uri(const std::string &server_base_url,
                                const std::string &request_path)
    -> std::string {
  assert(request_path.starts_with('/'));
  assert(!server_base_url.ends_with('/'));
  std::ostringstream schema_identifier;
  schema_identifier << server_base_url;
  // TODO: Can we avoid this copy?
  auto path_copy{request_path};
  path_copy.erase(path_copy.find_last_not_of('/') + 1);
  for (const auto character : path_copy) {
    schema_identifier << static_cast<char>(std::tolower(character));
  }

  if (request_path != "/" && !schema_identifier.str().ends_with(".json")) {
    schema_identifier << ".json";
  }

  return schema_identifier.str();
}

auto resolver(const sourcemeta::jsontoolkit::URI &server_base_url,
              const std::filesystem::path &schema_base_directory,
              std::string_view identifier)
    -> std::optional<sourcemeta::jsontoolkit::JSON> {
  sourcemeta::jsontoolkit::URI uri{std::string{identifier}};
  uri.canonicalize().relative_to(server_base_url);

  // If so, this URI doesn't belong to us
  // TODO: Have a more efficient way of checking that a URI is blank
  if (uri.is_absolute() || uri.recompose().empty()) {
    return sourcemeta::jsontoolkit::official_resolver(identifier);
  }

  assert(uri.path().has_value());
  // TODO: Prevent a malicious client from requesting a JSON file outside
  // the schema directory by using relative paths
  const auto schema_path{path_join(schema_base_directory, uri.path().value())};
  if (!std::filesystem::exists(schema_path) ||
      // Dot files are not permitted to be schemas, as we use them
      // for internal purposes
      schema_path.stem().string().starts_with('.')) {
    return std::nullopt;
  }

  auto schema{sourcemeta::jsontoolkit::from_file(schema_path)};
  sourcemeta::jsontoolkit::reidentify(
      schema, std::string{identifier},
      [&server_base_url, &schema_base_directory](const auto &subidentifier) {
        return resolver(server_base_url, schema_base_directory, subidentifier);
      });

  return schema;
}

} // namespace sourcemeta::registry

#endif
