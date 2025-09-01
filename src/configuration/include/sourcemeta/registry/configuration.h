#ifndef SOURCEMETA_REGISTRY_CONFIGURATION_H_
#define SOURCEMETA_REGISTRY_CONFIGURATION_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/schemaconfig.h>

#include <sourcemeta/registry/configuration_error.h>

#include <filesystem>    // std::filesystem::path
#include <optional>      // std::optional
#include <unordered_map> // std::unordered_map
#include <variant>       // std::variant

namespace sourcemeta::registry {

struct Configuration {
  static auto read(const std::filesystem::path &configuration_path,
                   const std::filesystem::path &collections_path)
      -> sourcemeta::core::JSON;
  static auto parse(const sourcemeta::core::JSON &data) -> Configuration;

  sourcemeta::core::JSON::String url;
  sourcemeta::core::JSON::Integer port;

  struct HTML {
    sourcemeta::core::JSON::String name;
    sourcemeta::core::JSON::String description;
    std::optional<sourcemeta::core::JSON::String> head;
    std::optional<sourcemeta::core::JSON::String> hero;

    struct Action {
      sourcemeta::core::JSON::String url;
      sourcemeta::core::JSON::String icon;
      sourcemeta::core::JSON::String title;
    };

    std::optional<Action> action;
  };

  std::optional<HTML> html;

  struct Page {
    std::optional<sourcemeta::core::JSON::String> title;
    std::optional<sourcemeta::core::JSON::String> description;
    std::optional<sourcemeta::core::JSON::String> email;
    std::optional<sourcemeta::core::JSON::String> github;
    std::optional<sourcemeta::core::JSON::String> website;
  };

  using Collection = sourcemeta::core::SchemaConfig;

  std::unordered_map<std::filesystem::path, std::variant<Page, Collection>>
      entries;
};

} // namespace sourcemeta::registry

#endif
