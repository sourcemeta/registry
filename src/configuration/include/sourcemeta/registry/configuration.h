#ifndef SOURCEMETA_REGISTRY_CONFIGURATION_H_
#define SOURCEMETA_REGISTRY_CONFIGURATION_H_

#include <sourcemeta/core/json.h>

#include <sourcemeta/registry/configuration_error.h>

#include <filesystem>    // std::filesystem::path
#include <optional>      // std::optional
#include <unordered_map> // std::unordered_map
#include <unordered_set> // std::unordered_set
#include <variant>       // std::variant

namespace sourcemeta::registry {

struct Configuration {
  static auto read(const std::filesystem::path &configuration_path,
                   const std::filesystem::path &collections_path)
      -> sourcemeta::core::JSON;
  static auto parse(const sourcemeta::core::JSON &data) -> Configuration;

  sourcemeta::core::JSON::String url;
  sourcemeta::core::JSON::String title;
  sourcemeta::core::JSON::String description;
  sourcemeta::core::JSON::Integer port;
  std::optional<sourcemeta::core::JSON::String> head;
  std::optional<sourcemeta::core::JSON::String> hero;

  struct Action {
    sourcemeta::core::JSON::String url;
    sourcemeta::core::JSON::String icon;
    sourcemeta::core::JSON::String title;
  };

  std::optional<Action> action;

  struct Metadata {
    std::optional<sourcemeta::core::JSON::String> title;
    std::optional<sourcemeta::core::JSON::String> description;
    std::optional<sourcemeta::core::JSON::String> email;
    std::optional<sourcemeta::core::JSON::String> github;
    std::optional<sourcemeta::core::JSON::String> website;
  };

  struct Page : public Metadata {};

  struct Collection : public Metadata {
    std::filesystem::path absolute_path;
    sourcemeta::core::JSON::String base;
    std::optional<sourcemeta::core::JSON::String> default_dialect;
    std::unordered_map<sourcemeta::core::JSON::String,
                       sourcemeta::core::JSON::String>
        resolve;
    sourcemeta::core::JSON extra = sourcemeta::core::JSON::make_object();
  };

  std::unordered_map<std::filesystem::path, std::variant<Page, Collection>>
      entries;
};

} // namespace sourcemeta::registry

#endif
