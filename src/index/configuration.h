#ifndef SOURCEMETA_REGISTRY_INDEX_CONFIGURATION_H_
#define SOURCEMETA_REGISTRY_INDEX_CONFIGURATION_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/uri.h>

#include "configure.h"

#include <filesystem> // std::filesystem

class RegistryConfiguration {
public:
  RegistryConfiguration(std::filesystem::path path);

  auto path() const noexcept -> const std::filesystem::path &;
  auto path(const std::filesystem::path &other) const -> std::filesystem::path;
  auto get() const noexcept -> const sourcemeta::core::JSON &;
  auto schema() const noexcept -> const sourcemeta::core::JSON &;
  auto url() const -> const sourcemeta::core::URI &;
  // For faster processing by the server component
  auto summary() const -> sourcemeta::core::JSON;

private:
  const std::filesystem::path path_;
  const std::filesystem::path base_;
  sourcemeta::core::JSON data_;
  const sourcemeta::core::JSON schema_{sourcemeta::core::parse_json(
      std::string{sourcemeta::registry::SCHEMA_CONFIGURATION})};
};

#endif
