#ifndef SOURCEMETA_REGISTRY_METAPACK_H
#define SOURCEMETA_REGISTRY_METAPACK_H

#include <sourcemeta/core/json.h>

#include <filesystem> // std::filesystem
#include <fstream>    // std::ifstream, std::ofstream
#include <functional> // std::functional
#include <optional>   // std::optional

// TODO: Eventually use JSON BinPack for the meta section and move this entire
// module as a contrib library of JSON BinPack

// TODO: Once all read/write operations are encapsulated here, concat the meta
// and the data into a single file

namespace sourcemeta::registry {

// TODO: Support GZIP
enum class MetaPackEncoding { Identity };

template <typename T> struct MetaPackFile {
  T data;
  const sourcemeta::core::JSON meta;
};

auto read_stream(const std::filesystem::path &path)
    -> std::optional<MetaPackFile<std::ifstream>>;

auto write_stream(const std::filesystem::path &path,
                  const sourcemeta::core::JSON::String &mime,
                  const MetaPackEncoding encoding,
                  const sourcemeta::core::JSON &extension,
                  const std::function<void(std::ofstream &)> &callback) -> void;

// Just for convenience

auto write_json(const std::filesystem::path &path,
                const sourcemeta::core::JSON &document,
                const MetaPackEncoding encoding,
                const sourcemeta::core::JSON &extension) -> void;

auto read_json(const std::filesystem::path &path)
    -> std::optional<MetaPackFile<sourcemeta::core::JSON>>;

} // namespace sourcemeta::registry

#endif
