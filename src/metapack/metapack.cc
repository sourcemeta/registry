#include <sourcemeta/registry/metapack.h>

#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/io.h>
#include <sourcemeta/core/md5.h>
#include <sourcemeta/core/time.h>

#include <cassert> // assert
#include <chrono>  // std::chrono::system_clock::time_point
#include <sstream> // std::ostringstream
#include <utility> // std::move

namespace sourcemeta::registry {

auto read_stream(const std::filesystem::path &path)
    -> std::optional<MetaPackFile<std::ifstream>> {
  assert(path.is_absolute());
  if (!std::filesystem::exists(path)) {
    return std::nullopt;
  }

  auto stream{sourcemeta::core::read_file(path)};
  auto metadata{sourcemeta::core::parse_json(stream)};
  assert(metadata.is_object());
  assert(metadata.defines("version"));
  assert(metadata.defines("checksum"));
  assert(metadata.defines("lastModified"));
  assert(metadata.defines("mime"));
  assert(metadata.defines("bytes"));
  assert(metadata.defines("encoding"));
  assert(metadata.at("version").is_integer());
  assert(metadata.at("version").is_positive());
  assert(metadata.at("checksum").is_string());
  assert(metadata.at("lastModified").is_string());
  assert(metadata.at("mime").is_string());
  assert(metadata.at("bytes").is_integer());
  assert(metadata.at("bytes").is_positive());
  assert(metadata.at("encoding").is_string());

  MetaPackEncoding encoding{MetaPackEncoding::Identity};
  if (metadata.at("encoding").to_string() == "gzip") {
    encoding = MetaPackEncoding::GZIP;
  } else if (metadata.at("encoding").to_string() != "identity") {
    assert(false);
  }

  return MetaPackFile{
      .data = std::move(stream),
      .version =
          static_cast<std::uint64_t>(metadata.at("version").to_integer()),
      .checksum = metadata.at("checksum").to_string(),
      .last_modified =
          sourcemeta::core::from_gmt(metadata.at("lastModified").to_string()),
      .mime = metadata.at("mime").to_string(),
      .bytes = static_cast<std::size_t>(metadata.at("bytes").to_integer()),
      .encoding = encoding,
      .extension = std::move(metadata).at_or("extension",
                                             sourcemeta::core::JSON{nullptr})};
}

auto write_stream(const std::filesystem::path &path,
                  const sourcemeta::core::JSON::String &mime,
                  const MetaPackEncoding encoding,
                  const sourcemeta::core::JSON &extension,
                  const std::function<void(std::ostream &)> &callback) -> void {
  // TODO: Ideally we wouldn't write the file all at once first
  std::stringstream buffer;
  callback(buffer);

  auto metadata{sourcemeta::core::JSON::make_object()};
  metadata.assign("version", sourcemeta::core::JSON{1});
  std::ostringstream md5;
  // TODO: Have a shorthand version that doesn't require an intermediary stream
  sourcemeta::core::md5(buffer.str(), md5);
  metadata.assign("checksum", sourcemeta::core::JSON{md5.str()});
  metadata.assign("lastModified",
                  sourcemeta::core::JSON{sourcemeta::core::to_gmt(
                      std::chrono::system_clock::now())});
  metadata.assign("mime", sourcemeta::core::JSON{mime});
  metadata.assign("bytes", sourcemeta::core::JSON{buffer.tellp()});

  switch (encoding) {
    case MetaPackEncoding::Identity:
      metadata.assign("encoding", sourcemeta::core::JSON{"identity"});
      break;
    case MetaPackEncoding::GZIP:
      metadata.assign("encoding", sourcemeta::core::JSON{"gzip"});
      break;
    default:
      assert(false);
      break;
  }

  if (!extension.is_null()) {
    metadata.assign("extension", extension);
  }

  std::ofstream output{path};
  assert(!output.fail());
  sourcemeta::core::stringify(metadata, output);
  if (encoding == MetaPackEncoding::GZIP) {
    sourcemeta::core::gzip(buffer, output);
  } else {
    output << buffer.str();
  }
}

auto read_contents(const std::filesystem::path &path)
    -> std::optional<MetaPackFile<sourcemeta::core::JSON::String>> {
  auto file{read_stream(path)};
  if (file.has_value()) {
    std::ostringstream buffer;
    if (file.value().encoding == MetaPackEncoding::GZIP) {
      sourcemeta::core::gunzip(file.value().data, buffer);
    } else {
      buffer << file.value().data.rdbuf();
    }

    return MetaPackFile{.data = std::move(buffer).str(),
                        .version = file.value().version,
                        .checksum = std::move(file.value().checksum),
                        .last_modified = file.value().last_modified,
                        .mime = std::move(file.value().mime),
                        .bytes = file.value().bytes,
                        .encoding = file.value().encoding,
                        .extension = std::move(file).value().extension};
  } else {
    return std::nullopt;
  }
}

} // namespace sourcemeta::registry
