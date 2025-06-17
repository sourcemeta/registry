#ifndef SOURCEMETA_REGISTRY_LICENSE_H_
#define SOURCEMETA_REGISTRY_LICENSE_H_

#include <string_view> // std::string_view

namespace sourcemeta::registry {
auto license_permitted() -> bool;
auto license_error() -> std::string_view;
} // namespace sourcemeta::registry

#endif
