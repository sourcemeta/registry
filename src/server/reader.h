#ifndef SOURCEMETA_REGISTRY_SERVER_READER_H
#define SOURCEMETA_REGISTRY_SERVER_READER_H

#include <sourcemeta/core/json.h>

#include <cassert>    // assert
#include <filesystem> // std::filesystem
#include <fstream>    // std::ifstream
#include <optional>   // std::optional

namespace sourcemeta::registry {

struct File {
  std::ifstream stream;
  const sourcemeta::core::JSON meta;
};

auto read_file(const std::filesystem::path &absolute_path)
    -> std::optional<File> {
  assert(absolute_path.is_absolute());
  if (!std::filesystem::exists(absolute_path) ||
      // Don't allow reading meta files directly
      absolute_path.extension() == ".meta") {
    return std::nullopt;
  }

  // TODO: How can avoid a copy here?
  auto metadata_path = absolute_path;
  metadata_path += ".meta";
  assert(std::filesystem::exists(metadata_path));

  auto metadata{sourcemeta::core::read_json(metadata_path)};
  assert(metadata.is_object());
  assert(metadata.defines("md5"));
  assert(metadata.defines("lastModified"));
  assert(metadata.at("md5").is_string());
  assert(metadata.at("lastModified").is_string());

  assert(std::filesystem::is_regular_file(absolute_path));
  std::ifstream stream{absolute_path};
  stream.exceptions(std::ifstream::badbit);
  assert(!stream.fail());
  assert(stream.is_open());

  return File{.stream = std::move(stream), .meta = std::move(metadata)};
}

} // namespace sourcemeta::registry

#endif
