#ifndef SOURCEMETA_REGISTRY_RESOLVER_H_
#define SOURCEMETA_REGISTRY_RESOLVER_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>

#include <sourcemeta/registry/configuration.h>
#include <sourcemeta/registry/resolver_error.h>

#include <filesystem>    // std::filesystem
#include <mutex>         // std::mutex, std::lock_guard
#include <optional>      // std::optional
#include <string>        // std::string
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

  auto operator()(std::string_view identifier,
                  const std::function<void(const std::filesystem::path &)>
                      &callback = nullptr) const
      -> std::optional<sourcemeta::core::JSON>;

  auto add(const sourcemeta::core::URI &server_url,
           const std::filesystem::path &relative_path,
           const Configuration::Collection &collection,
           const std::filesystem::path &path)
      -> std::pair<std::string, std::string>;

  auto materialise(const std::string &uri, const std::filesystem::path &path)
      -> void;

  auto begin() const -> auto { return this->views.begin(); }
  auto end() const -> auto { return this->views.end(); }
  auto size() const -> auto { return this->count_; }

  struct Entry {
    std::optional<std::filesystem::path> cache_path;
    std::optional<std::filesystem::path> path;
    std::optional<std::string> dialect;
    std::filesystem::path relative_path;
    // TODO: Do we really need this member?
    std::string original_identifier;
    std::string collection_name;
    bool blaze_exhaustive;
    sourcemeta::core::SchemaVisitorReference reference_visitor;
  };

private:
  std::unordered_map<std::string, Entry> views;
  std::size_t count_{0};
  std::mutex mutex;
};

} // namespace sourcemeta::registry

#endif
