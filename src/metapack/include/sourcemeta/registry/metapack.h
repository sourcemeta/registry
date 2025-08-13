#ifndef SOURCEMETA_REGISTRY_METAPACK_H
#define SOURCEMETA_REGISTRY_METAPACK_H

#include <sourcemeta/core/json.h>

#include <chrono>     // std::chrono
#include <cstdint>    // std::uint64_t
#include <filesystem> // std::filesystem
#include <fstream>    // std::ifstream
#include <functional> // std::functional
#include <optional>   // std::optional
#include <ostream>    // std::ostream

namespace sourcemeta::registry {

enum class MetaPackEncoding { Identity, GZIP };

template <typename T> struct MetaPackFile {
  T data;
  std::uint64_t version;
  sourcemeta::core::JSON::String checksum;
  std::chrono::system_clock::time_point last_modified;
  sourcemeta::core::JSON::String mime;
  std::size_t bytes;
  MetaPackEncoding encoding;
  sourcemeta::core::JSON extension;
};

auto read_stream(const std::filesystem::path &path)
    -> std::optional<MetaPackFile<std::ifstream>>;

auto write_stream(const std::filesystem::path &path,
                  const sourcemeta::core::JSON::String &mime,
                  const MetaPackEncoding encoding,
                  const sourcemeta::core::JSON &extension,
                  const std::function<void(std::ostream &)> &callback) -> void;

auto read_contents(MetaPackFile<std::ifstream> &stream)
    -> MetaPackFile<sourcemeta::core::JSON::String>;

auto read_contents(const std::filesystem::path &path)
    -> std::optional<MetaPackFile<sourcemeta::core::JSON::String>>;

} // namespace sourcemeta::registry

#endif
