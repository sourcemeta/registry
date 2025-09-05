#ifndef SOURCEMETA_REGISTRY_RESOLVER_H_
#define SOURCEMETA_REGISTRY_RESOLVER_H_

#include <sourcemeta/core/json.h>

#include <sourcemeta/registry/configuration.h>

#include <sourcemeta/registry/resolver_error.h>

#include <filesystem>    // std::filesystem
#include <functional>    // std::reference_wrapper
#include <optional>      // std::optional
#include <shared_mutex>  // std::shared_mutex
#include <string_view>   // std::string_view
#include <unordered_map> // std::unordered_map
#include <utility>       // std::pair

namespace sourcemeta::registry {

class Resolver {
public:
  Resolver() = default;
  // Just to prevent mistakes
  Resolver(const Resolver &) = delete;
  Resolver &operator=(const Resolver &) = delete;
  Resolver(Resolver &&) = delete;
  Resolver &operator=(Resolver &&) = delete;

  using Callback = std::function<void(const std::filesystem::path &)>;

  auto operator()(std::string_view identifier,
                  const Callback &callback = nullptr) const
      -> std::optional<sourcemeta::core::JSON>;

  // Returns the original identifier and the new identifier
  auto add(const sourcemeta::core::JSON::String &server_url,
           const std::filesystem::path &collection_relative_path,
           const Configuration::Collection &collection,
           const std::filesystem::path &path)
      -> std::pair<
          std::reference_wrapper<const sourcemeta::core::JSON::String>,
          std::reference_wrapper<const sourcemeta::core::JSON::String>>;

  auto cache_path(const sourcemeta::core::JSON::String &uri,
                  const std::filesystem::path &path) -> void;

  auto begin() const -> auto { return this->views.begin(); }
  auto end() const -> auto { return this->views.end(); }
  auto size() const -> auto { return this->views.size(); }

  struct Entry {
    std::optional<std::filesystem::path> cache_path;
    std::filesystem::path path;
    sourcemeta::core::JSON::String dialect;
    // This is the collection name plus the final schema path component
    std::filesystem::path relative_path;
    sourcemeta::core::JSON::String original_identifier;
    std::reference_wrapper<const Configuration::Collection> collection;
  };

private:
  std::unordered_map<sourcemeta::core::JSON::String, Entry> views;
  std::shared_mutex mutex;
};

} // namespace sourcemeta::registry

#endif
