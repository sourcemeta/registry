#ifndef SOURCEMETA_REGISTRY_GENERATOR_CONFIGURATION_H_
#define SOURCEMETA_REGISTRY_GENERATOR_CONFIGURATION_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/uri.h>

#include <filesystem> // std::filesystem

namespace sourcemeta::registry {

class Configuration {
public:
  Configuration(std::filesystem::path path,
                sourcemeta::core::JSON configuration_schema);

  // Just to prevent mistakes
  Configuration(const Configuration &) = delete;
  Configuration &operator=(const Configuration &) = delete;
  Configuration(Configuration &&) = delete;
  Configuration &operator=(Configuration &&) = delete;

  auto path() const noexcept -> const std::filesystem::path &;
  auto base() const noexcept -> const std::filesystem::path &;
  auto path(const std::filesystem::path &other) const -> std::filesystem::path;
  auto get() const noexcept -> const sourcemeta::core::JSON &;
  auto schema() const noexcept -> const sourcemeta::core::JSON &;
  auto url() const -> const sourcemeta::core::URI &;
  // For faster processing by the server component
  // TODO: Can we trim this down even more?
  auto summary() const -> sourcemeta::core::JSON;

private:
  const std::filesystem::path path_;
  const std::filesystem::path base_;
  sourcemeta::core::JSON data_;
  const sourcemeta::core::JSON schema_;
};

} // namespace sourcemeta::registry

#endif
