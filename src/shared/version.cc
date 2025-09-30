#include <sourcemeta/registry/shared_version.h>

#include <sourcemeta/core/uuid.h>

#include "configure.h"

namespace sourcemeta::registry {

auto stamp() noexcept -> std::string_view {
  static auto CACHE_STAMP{sourcemeta::core::uuidv4()};
  return CACHE_STAMP;
}

auto version() noexcept -> std::string_view { return PROJECT_VERSION; }

} // namespace sourcemeta::registry
