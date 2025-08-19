#ifndef SOURCEMETA_REGISTRY_CONFIGURATION_H_
#define SOURCEMETA_REGISTRY_CONFIGURATION_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/uri.h>

#include <sourcemeta/registry/configuration_error.h>

#include <filesystem>    // std::filesystem::path
#include <optional>      // std::optional
#include <unordered_map> // std::unordered_map
#include <utility>       // std::pair
#include <variant>       // std::variant
#include <vector>        // std::vector

namespace sourcemeta::registry {

// TODO: Move this to Core as a SchemConfig module
class Configuration {
public:
  Configuration(const std::filesystem::path &path,
                const std::filesystem::path &collections);

  struct Collection {
    Collection(const std::filesystem::path &base_path,
               sourcemeta::core::JSON::String entry_name,
               const sourcemeta::core::JSON &entry);

    auto default_identifier(const std::filesystem::path &schema_path) const
        -> std::string;

    std::filesystem::path path;
    sourcemeta::core::JSON::String name;
    sourcemeta::core::URI base_uri;
    std::optional<sourcemeta::core::JSON::String> default_dialect;
    std::vector<std::pair<sourcemeta::core::URI, sourcemeta::core::URI>> rebase;
    bool blaze_exhaustive;
  };

  auto inflate(const std::filesystem::path &path,
               sourcemeta::core::JSON &target) const -> void;

private:
  sourcemeta::core::JSON data_;

public:
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
  std::unordered_map<std::filesystem::path,
                     // TODO: Turn the JSON variant here into Page or something
                     // like that
                     std::variant<Collection, sourcemeta::core::JSON>>
      entries;
};

} // namespace sourcemeta::registry

#endif
