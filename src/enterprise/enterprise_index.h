#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_INDEX_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_INDEX_H_

#include <sourcemeta/jsontoolkit/json.h>

#include <cstdlib>    // EXIT_SUCCESS
#include <filesystem> // std::filesystem

namespace sourcemeta::registry::enterprise {

auto attach(const sourcemeta::jsontoolkit::JSON &,
            const std::filesystem::path &, const std::filesystem::path &)
    -> int {
  return EXIT_SUCCESS;
}

} // namespace sourcemeta::registry::enterprise

#endif
