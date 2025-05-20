#ifndef SOURCEMETA_REGISTRY_INDEX_COLLECTION_H_
#define SOURCEMETA_REGISTRY_INDEX_COLLECTION_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/uri.h>

#include <filesystem> // std::filesystem
#include <optional>   // std::optional
#include <utility>    // std::pair
#include <vector>     // std::vector

struct RegistryCollection {
  RegistryCollection(const std::filesystem::path &base_path,
                     const sourcemeta::core::JSON::String &entry_name,
                     const sourcemeta::core::JSON &entry);

  // Just to prevent mistakes
  RegistryCollection(const RegistryCollection &) = delete;
  RegistryCollection &operator=(const RegistryCollection &) = delete;
  RegistryCollection(RegistryCollection &&) = delete;
  RegistryCollection &operator=(RegistryCollection &&) = delete;

  auto default_identifier(const std::filesystem::path &schema_path) const
      -> std::string;

  const std::filesystem::path path;
  const sourcemeta::core::JSON::String name;
  const sourcemeta::core::URI base_uri;
  // TODO: Turn this into a reference so we don't copy lots of dialect URIs
  const std::optional<sourcemeta::core::JSON::String> default_dialect;
  std::vector<std::pair<sourcemeta::core::URI, sourcemeta::core::URI>> rebase;
};

#endif
