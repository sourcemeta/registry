#include <sourcemeta/registry/gzip.h>
#include <sourcemeta/registry/shared_metapack.h>

#include <sourcemeta/core/io.h>
#include <sourcemeta/core/md5.h>
#include <sourcemeta/core/time.h>

#include <cassert>    // assert
#include <chrono>     // std::chrono::system_clock::time_point
#include <functional> // std::functional
#include <ostream>    // std::ostream
#include <sstream>    // std::ostringstream
#include <utility>    // std::move

// TODO: There are lots of opportunities to optimise this file
// and avoid temporary buffers, etc

namespace {

auto write_stream(const std::filesystem::path &path,
                  const sourcemeta::core::JSON::String &mime,
                  const sourcemeta::registry::Encoding encoding,
                  const sourcemeta::core::JSON &extension,
                  const std::chrono::milliseconds duration,
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
  metadata.assign("duration", sourcemeta::core::JSON{duration.count()});

  switch (encoding) {
    case sourcemeta::registry::Encoding::Identity:
      metadata.assign("encoding", sourcemeta::core::JSON{"identity"});
      break;
    case sourcemeta::registry::Encoding::GZIP:
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
  if (encoding == sourcemeta::registry::Encoding::GZIP) {
    sourcemeta::registry::gzip(buffer, output);
  } else {
    output << buffer.str();
  }

  output.flush();
}

} // namespace

namespace sourcemeta::registry {

auto read_stream_raw(const std::filesystem::path &path)
    -> std::optional<File<std::ifstream>> {
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
  assert(metadata.defines("duration"));
  assert(metadata.defines("encoding"));
  assert(metadata.at("version").is_integer());
  assert(metadata.at("version").is_positive());
  assert(metadata.at("checksum").is_string());
  assert(metadata.at("lastModified").is_string());
  assert(metadata.at("mime").is_string());
  assert(metadata.at("bytes").is_integer());
  assert(metadata.at("bytes").is_positive());
  assert(metadata.at("duration").is_integer());
  assert(metadata.at("duration").is_positive());
  assert(metadata.at("encoding").is_string());

  Encoding encoding{Encoding::Identity};
  if (metadata.at("encoding").to_string() == "gzip") {
    encoding = Encoding::GZIP;
  } else if (metadata.at("encoding").to_string() != "identity") {
    assert(false);
  }

  return File{
      .data = std::move(stream),
      .version =
          static_cast<std::uint64_t>(metadata.at("version").to_integer()),
      .checksum = metadata.at("checksum").to_string(),
      .last_modified =
          sourcemeta::core::from_gmt(metadata.at("lastModified").to_string()),
      .mime = metadata.at("mime").to_string(),
      .bytes = static_cast<std::size_t>(metadata.at("bytes").to_integer()),
      .duration = static_cast<std::chrono::milliseconds>(
          metadata.at("duration").to_integer()),
      .encoding = encoding,
      .extension = std::move(metadata).at_or("extension",
                                             sourcemeta::core::JSON{nullptr})};
}

auto read_json(const std::filesystem::path &path,
               const sourcemeta::core::JSON::ParseCallback &callback)
    -> sourcemeta::core::JSON {
  return read_json_with_metadata(path, callback).data;
}

auto read_json_with_metadata(
    const std::filesystem::path &path,
    const sourcemeta::core::JSON::ParseCallback &callback)
    -> File<sourcemeta::core::JSON> {
  auto file{read_stream_raw(path)};
  assert(file.has_value());
  std::ostringstream buffer;
  if (file.value().encoding == Encoding::GZIP) {
    sourcemeta::registry::gunzip(file.value().data, buffer);
  } else {
    buffer << file.value().data.rdbuf();
  }

  return File{.data = sourcemeta::core::parse_json(buffer.str(), callback),
              .version = file.value().version,
              .checksum = file.value().checksum,
              .last_modified = file.value().last_modified,
              .mime = std::move(file.value().mime),
              .bytes = file.value().bytes,
              .duration = file.value().duration,
              .encoding = file.value().encoding,
              .extension = file.value().extension};
}

auto write_json(const std::filesystem::path &destination,
                const sourcemeta::core::JSON &document,
                const sourcemeta::core::JSON::String &mime,
                const Encoding encoding,
                const sourcemeta::core::JSON &extension,
                const std::chrono::milliseconds duration) -> void {
  write_stream(destination, mime, encoding, extension, duration,
               [&document](auto &stream) {
                 sourcemeta::core::stringify(document, stream);
               });
}

auto write_pretty_json(const std::filesystem::path &destination,
                       const sourcemeta::core::JSON &document,
                       const sourcemeta::core::JSON::String &mime,
                       const Encoding encoding,
                       const sourcemeta::core::JSON &extension,
                       const std::chrono::milliseconds duration,
                       const sourcemeta::core::JSON::KeyComparison &compare)
    -> void {
  write_stream(destination, mime, encoding, extension, duration,
               [&document, &compare](auto &stream) {
                 sourcemeta::core::prettify(document, stream, compare);
               });
}

auto write_text(const std::filesystem::path &destination,
                const std::string_view contents,
                const sourcemeta::core::JSON::String &mime,
                const Encoding encoding,
                const sourcemeta::core::JSON &extension,
                const std::chrono::milliseconds duration) -> void {
  write_stream(destination, mime, encoding, extension, duration,
               [&contents](auto &stream) {
                 stream << contents;
                 stream << "\n";
               });
}

auto write_file(const std::filesystem::path &destination,
                const std::filesystem::path &source,
                const sourcemeta::core::JSON::String &mime,
                const Encoding encoding,
                const sourcemeta::core::JSON &extension,
                const std::chrono::milliseconds duration) -> void {
  auto stream{sourcemeta::core::read_file(source)};
  write_stream(destination, mime, encoding, extension, duration,
               [&stream](auto &target) { target << stream.rdbuf(); });
}

auto write_jsonl(const std::filesystem::path &destination,
                 const std::vector<sourcemeta::core::JSON> &entries,
                 const sourcemeta::core::JSON::String &mime,
                 const Encoding encoding,
                 const sourcemeta::core::JSON &extension,
                 const std::chrono::milliseconds duration) -> void {
  write_stream(destination, mime, encoding, extension, duration,
               [&entries](auto &stream) {
                 for (const auto &entry : entries) {
                   sourcemeta::core::stringify(entry, stream);
                   stream << "\n";
                 }
               });
}

} // namespace sourcemeta::registry
