#include <sourcemeta/registry/metapack.h>

#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/io.h>
#include <sourcemeta/core/md5.h>
#include <sourcemeta/core/time.h>

#include <cassert> // assert
#include <chrono>  // std::chrono::system_clock::time_point
#include <sstream> // std::ostringstream
#include <utility> // std::move

namespace {
auto read_meta(const std::filesystem::path &path)
    -> std::optional<sourcemeta::core::JSON> {
  // TODO: How can avoid a copy here?
  auto metadata_path = path;
  metadata_path += ".meta";
  if (!std::filesystem::exists(metadata_path)) {
    return std::nullopt;
  }

  auto metadata{sourcemeta::core::read_json(metadata_path)};
  assert(metadata.is_object());
  assert(metadata.defines("md5"));
  assert(metadata.defines("lastModified"));
  assert(metadata.defines("encoding"));
  assert(metadata.at("md5").is_string());
  assert(metadata.at("lastModified").is_string());
  assert(metadata.at("encoding").is_string());
  return metadata;
}
} // namespace

namespace sourcemeta::registry {

auto read_stream(const std::filesystem::path &path)
    -> std::optional<MetaPackFile<std::ifstream>> {
  assert(path.is_absolute());
  if (!std::filesystem::exists(path)) {
    return std::nullopt;
  }

  auto metadata{read_meta(path)};
  if (!metadata.has_value()) {
    return std::nullopt;
  }

  assert(std::filesystem::is_regular_file(path));
  std::ifstream stream{path};
  stream.exceptions(std::ifstream::badbit);
  assert(!stream.fail());
  assert(stream.is_open());

  return MetaPackFile{.data = std::move(stream),
                      .meta = std::move(metadata).value()};
}

auto write_stream(const std::filesystem::path &path,
                  const sourcemeta::core::JSON::String &mime,
                  const MetaPackEncoding encoding,
                  const sourcemeta::core::JSON &extension,
                  const std::function<void(std::ostream &)> &callback) -> void {
  std::ofstream output{path};
  assert(!output.fail());
  std::size_t size{0};
  if (encoding == MetaPackEncoding::GZIP) {
    std::stringstream input;
    callback(input);
    size = input.str().size();
    sourcemeta::core::gzip(input, output);
  } else {
    callback(output);
    size = static_cast<std::size_t>(output.tellp());
  }

  auto metadata{sourcemeta::core::JSON::make_object()};
  auto stream{sourcemeta::core::read_file(path)};
  std::ostringstream contents;
  contents << stream.rdbuf();
  std::ostringstream md5;
  sourcemeta::core::md5(contents.str(), md5);
  metadata.assign("md5", sourcemeta::core::JSON{md5.str()});
  const auto last_write_time{std::filesystem::last_write_time(path)};
  const auto last_modified{
      std::chrono::time_point_cast<std::chrono::system_clock::duration>(
          last_write_time - std::filesystem::file_time_type::clock::now() +
          std::chrono::system_clock::now())};
  metadata.assign("lastModified", sourcemeta::core::JSON{
                                      sourcemeta::core::to_gmt(last_modified)});
  metadata.assign("mime", sourcemeta::core::JSON{mime});
  metadata.assign("bytes", sourcemeta::core::JSON{size});

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

  std::ofstream metadata_stream{path.string() + ".meta"};
  assert(!metadata_stream.fail());
  sourcemeta::core::stringify(metadata, metadata_stream);
  metadata_stream << "\n";
}

auto read_json(const std::filesystem::path &path)
    -> std::optional<MetaPackFile<sourcemeta::core::JSON>> {
  auto file{read_stream(path)};
  if (file.has_value()) {
    if (file.value().meta.at("encoding").to_string() == "gzip") {
      std::stringstream buffer;
      sourcemeta::core::gunzip(file.value().data, buffer);
      auto data{sourcemeta::core::parse_json(buffer)};
      return MetaPackFile{.data = std::move(data),
                          .meta = std::move(file).value().meta};
    } else {
      auto data{sourcemeta::core::parse_json(file.value().data)};
      return MetaPackFile{.data = std::move(data),
                          .meta = std::move(file).value().meta};
    }
  } else {
    return std::nullopt;
  }
}

auto write_json(const std::filesystem::path &path,
                const sourcemeta::core::JSON &document,
                const MetaPackEncoding encoding,
                const sourcemeta::core::JSON &extension) -> void {
  write_stream(path, "application/json", encoding, extension,
               [&document](auto &stream) {
                 sourcemeta::core::stringify(document, stream);
               });
}

} // namespace sourcemeta::registry
