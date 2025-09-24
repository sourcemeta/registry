#include <sourcemeta/registry/shared_version.h>

#include "configure.h"

namespace sourcemeta::registry {

auto version() noexcept -> std::string_view { return PROJECT_VERSION; }

} // namespace sourcemeta::registry
