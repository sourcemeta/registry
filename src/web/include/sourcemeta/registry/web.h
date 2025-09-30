#ifndef SOURCEMETA_REGISTRY_WEB_H_
#define SOURCEMETA_REGISTRY_WEB_H_

#include <sourcemeta/core/build.h>
#include <sourcemeta/registry/configuration.h>

#include <filesystem> // std::filesystem

namespace sourcemeta::registry {

struct GENERATE_WEB_DIRECTORY {
  using Context = Configuration;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
          const Context &configuration) -> void;
};

struct GENERATE_WEB_NOT_FOUND {
  using Context = Configuration;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path> &,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
          const Context &configuration) -> void;
};

struct GENERATE_WEB_INDEX {
  using Context = Configuration;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
          const Context &configuration) -> void;
};

struct GENERATE_WEB_SCHEMA {
  using Context = Configuration;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
          const Context &configuration) -> void;
};

} // namespace sourcemeta::registry

#endif
