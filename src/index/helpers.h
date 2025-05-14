#ifndef SOURCEMETA_REGISTRY_INDEX_HELPERS_H_
#define SOURCEMETA_REGISTRY_INDEX_HELPERS_H_

#include <sourcemeta/core/json.h>

#include <filesystem> // std::filesystem
#include <fstream>    // std::ofstream

static auto prettify_to_file(const sourcemeta::core::JSON &document,
                             const std::filesystem::path &output) -> void {
  std::ofstream stream{output};
  sourcemeta::core::prettify(document, stream);
  stream << "\n";
}

#endif
