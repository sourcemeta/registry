#ifndef SOURCEMETA_REGISTRY_SHARED_VERSION_H_
#define SOURCEMETA_REGISTRY_SHARED_VERSION_H_

#include <string_view> // std::string_view

namespace sourcemeta::registry {

auto version() noexcept -> std::string_view;

} // namespace sourcemeta::registry

#endif
