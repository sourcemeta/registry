#ifndef SOURCEMETA_REGISTRY_SHARED_METAPACK_H
#define SOURCEMETA_REGISTRY_SHARED_METAPACK_H

#include <sourcemeta/core/json.h>

#include <sourcemeta/registry/shared_encoding.h>

#include <chrono>     // std::chrono
#include <cstdint>    // std::uint64_t
#include <filesystem> // std::filesystem
#include <fstream>    // std::ifstream
#include <optional>   // std::optional
#include <vector>     // std::vector

namespace sourcemeta::registry {

template <typename T> struct File {
  T data;
  std::uint64_t version;
  sourcemeta::core::JSON::String checksum;
  std::chrono::system_clock::time_point last_modified;
  sourcemeta::core::JSON::String mime;
  std::size_t bytes;
  std::chrono::milliseconds duration;
  Encoding encoding;
  sourcemeta::core::JSON extension;
};

auto read_stream_raw(const std::filesystem::path &path)
    -> std::optional<File<std::ifstream>>;

auto read_json(const std::filesystem::path &path,
               const sourcemeta::core::JSON::ParseCallback &callback = nullptr)
    -> sourcemeta::core::JSON;

auto read_json_with_metadata(
    const std::filesystem::path &path,
    const sourcemeta::core::JSON::ParseCallback &callback = nullptr)
    -> File<sourcemeta::core::JSON>;

auto write_json(const std::filesystem::path &destination,
                const sourcemeta::core::JSON &document,
                const sourcemeta::core::JSON::String &mime,
                const Encoding encoding,
                const sourcemeta::core::JSON &extension,
                const std::chrono::milliseconds duration) -> void;

auto write_pretty_json(const std::filesystem::path &destination,
                       const sourcemeta::core::JSON &document,
                       const sourcemeta::core::JSON::String &mime,
                       const Encoding encoding,
                       const sourcemeta::core::JSON &extension,
                       const std::chrono::milliseconds duration) -> void;

auto write_text(const std::filesystem::path &destination,
                const std::string_view contents,
                const sourcemeta::core::JSON::String &mime,
                const Encoding encoding,
                const sourcemeta::core::JSON &extension,
                const std::chrono::milliseconds duration) -> void;

auto write_file(const std::filesystem::path &destination,
                const std::filesystem::path &source,
                const sourcemeta::core::JSON::String &mime,
                const Encoding encoding,
                const sourcemeta::core::JSON &extension,
                const std::chrono::milliseconds duration) -> void;

auto write_jsonl(const std::filesystem::path &destination,
                 const std::vector<sourcemeta::core::JSON> &entries,
                 const sourcemeta::core::JSON::String &mime,
                 const Encoding encoding,
                 const sourcemeta::core::JSON &extension,
                 const std::chrono::milliseconds duration) -> void;

} // namespace sourcemeta::registry

#endif
