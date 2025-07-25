#ifndef SOURCEMETA_REGISTRY_SERVER_READER_H
#define SOURCEMETA_REGISTRY_SERVER_READER_H

#include <sourcemeta/core/json.h>

#include <cassert>    // assert
#include <filesystem> // std::filesystem
#include <fstream>    // std::ifstream
#include <optional>   // std::optional
#include <utility>    // std::pair, std::make_pair

// TODO: Move into its own module that defines how to write and read
// data + ".meta" files for both server and indexer generators

// TODO: Once all read/write operations are encapsulated here, concat the meta
// and the data into a single file

namespace sourcemeta::registry {

template <typename T> struct File {
  T data;
  const sourcemeta::core::JSON meta;
};

auto read_meta(const std::filesystem::path &absolute_path)
    -> std::optional<sourcemeta::core::JSON> {
  // TODO: How can avoid a copy here?
  auto metadata_path = absolute_path;
  metadata_path += ".meta";
  if (!std::filesystem::exists(metadata_path)) {
    return std::nullopt;
  }

  auto metadata{sourcemeta::core::read_json(metadata_path)};
  assert(metadata.is_object());
  assert(metadata.defines("md5"));
  assert(metadata.defines("lastModified"));
  assert(metadata.at("md5").is_string());
  assert(metadata.at("lastModified").is_string());
  return metadata;
}

auto read_stream(const std::filesystem::path &absolute_path)
    -> std::optional<File<std::ifstream>> {
  assert(absolute_path.is_absolute());
  if (!std::filesystem::exists(absolute_path)) {
    return std::nullopt;
  }

  auto metadata{read_meta(absolute_path)};
  if (!metadata.has_value()) {
    return std::nullopt;
  }

  assert(std::filesystem::is_regular_file(absolute_path));
  std::ifstream stream{absolute_path};
  stream.exceptions(std::ifstream::badbit);
  assert(!stream.fail());
  assert(stream.is_open());

  return File{.data = std::move(stream), .meta = std::move(metadata).value()};
}

auto read_json(const std::filesystem::path &absolute_path)
    -> std::optional<File<sourcemeta::core::JSON>> {
  auto file{read_stream(absolute_path)};
  if (!file.has_value()) {
    return std::nullopt;
  }

  auto data{sourcemeta::core::parse_json(file.value().data)};
  return File{.data = std::move(data), .meta = std::move(file).value().meta};
}

} // namespace sourcemeta::registry

#endif
