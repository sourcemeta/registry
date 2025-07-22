#ifndef SOURCEMETA_REGISTRY_RESOLVER_COLLECTION_H_
#define SOURCEMETA_REGISTRY_RESOLVER_COLLECTION_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/uri.h>

#include <filesystem> // std::filesystem
#include <optional>   // std::optional
#include <utility>    // std::pair
#include <vector>     // std::vector

namespace sourcemeta::registry {

struct ResolverCollection {
  ResolverCollection(const std::filesystem::path &base_path,
                     sourcemeta::core::JSON::String entry_name,
                     const sourcemeta::core::JSON &entry);

  // Just to prevent mistakes
  ResolverCollection(const ResolverCollection &) = delete;
  ResolverCollection &operator=(const ResolverCollection &) = delete;
  ResolverCollection(ResolverCollection &&) = delete;
  ResolverCollection &operator=(ResolverCollection &&) = delete;

  auto default_identifier(const std::filesystem::path &schema_path) const
      -> std::string;

  const std::filesystem::path path;
  const sourcemeta::core::JSON::String name;
  const sourcemeta::core::URI base_uri;
  const std::optional<sourcemeta::core::JSON::String> default_dialect;
  const std::vector<std::pair<sourcemeta::core::URI, sourcemeta::core::URI>>
      rebase;
};

} // namespace sourcemeta::registry

#endif
