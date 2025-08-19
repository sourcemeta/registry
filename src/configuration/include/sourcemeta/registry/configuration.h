#ifndef SOURCEMETA_REGISTRY_CONFIGURATION_H_
#define SOURCEMETA_REGISTRY_CONFIGURATION_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/uri.h>

#include <sourcemeta/registry/configuration_error.h>

#include <filesystem> // std::filesystem::path
#include <functional> // std::function
#include <optional>   // std::optional
#include <utility>    // std::pair
#include <vector>     // std::vector

namespace sourcemeta::registry {

class Configuration {
public:
  Configuration(const std::filesystem::path &path,
                const std::filesystem::path &collections);

  struct Action {
    sourcemeta::core::JSON::String url;
    sourcemeta::core::JSON::String icon;
    sourcemeta::core::JSON::String title;
  };

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
  };

  auto base() const -> const std::filesystem::path &;

  auto url() const -> const sourcemeta::core::JSON::String &;
  auto title() const -> const sourcemeta::core::JSON::String &;
  auto description() const -> const sourcemeta::core::JSON::String &;
  auto hero() const -> std::optional<sourcemeta::core::JSON::String>;
  auto head() const -> std::optional<sourcemeta::core::JSON::String>;
  auto port() const -> sourcemeta::core::JSON::Integer;
  auto action() const -> std::optional<Action>;

  auto inflate(const std::filesystem::path &path,
               sourcemeta::core::JSON &target) const -> void;
  auto attribute(const std::filesystem::path &path,
                 const sourcemeta::core::JSON::String &name) const -> bool;
  auto collection(const std::filesystem::path &path) const
      -> std::optional<Collection>;
  auto collections() const -> std::vector<Collection>;

private:
  std::filesystem::path base_;
  sourcemeta::core::JSON data_;
};

} // namespace sourcemeta::registry

#endif
