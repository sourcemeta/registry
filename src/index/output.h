#ifndef SOURCEMETA_REGISTRY_INDEX_OUTPUT_H_
#define SOURCEMETA_REGISTRY_INDEX_OUTPUT_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/registry/metapack.h>

#include <cassert>       // assert
#include <filesystem>    // std::filesystem
#include <iostream>      // std::cerr
#include <string_view>   // std::string_view
#include <unordered_map> // std::unordered_map

namespace sourcemeta::registry {

class Output {
public:
  Output(std::filesystem::path path)
      : path_{std::filesystem::weakly_canonical(path)} {
    std::filesystem::create_directories(this->path_);
    for (const auto &entry :
         std::filesystem::recursive_directory_iterator(this->path_)) {
      this->tracker.emplace(entry.path(), false);
    }
  }

  auto remove_unknown_files() const {
    for (const auto &entry : this->tracker) {
      if (!entry.second) {
        std::cerr << "Removing unknown file: " << entry.first.string() << "\n";
        std::filesystem::remove_all(entry.first);
      }
    }
  }

  // Just to prevent mistakes
  Output(const Output &) = delete;
  Output &operator=(const Output &) = delete;
  Output(Output &&) = delete;
  Output &operator=(Output &&) = delete;

  auto path() const -> const std::filesystem::path & { return this->path_; }

  auto write_json(const std::filesystem::path &path,
                  const sourcemeta::core::JSON &document)
      -> const std::filesystem::path & {
    const auto absolute_path{this->resolve(path)};
    std::filesystem::create_directories(absolute_path.parent_path());
    std::ofstream stream{absolute_path};
    assert(!stream.fail());
    sourcemeta::core::stringify(document, stream);
    return this->track(absolute_path);
  }

  auto
  write_metapack_json(const std::filesystem::path &path,
                      const sourcemeta::registry::MetaPackEncoding encoding,
                      const sourcemeta::core::JSON &document)
      -> const std::filesystem::path & {
    const auto absolute_path{this->resolve(path)};
    std::filesystem::create_directories(absolute_path.parent_path());
    sourcemeta::registry::write_stream(
        absolute_path, "application/json", encoding,
        sourcemeta::core::JSON{nullptr}, [&document](auto &stream) {
          sourcemeta::core::stringify(document, stream);
        });

    return this->track(absolute_path);
  }

  template <typename Iterator>
  auto
  write_metapack_jsonl(const std::filesystem::path &path,
                       const sourcemeta::registry::MetaPackEncoding encoding,
                       Iterator begin, Iterator end)
      -> const std::filesystem::path & {
    const auto absolute_path{this->resolve(path)};
    std::filesystem::create_directories(absolute_path.parent_path());
    sourcemeta::registry::write_stream(
        absolute_path, "application/jsonl", encoding,
        sourcemeta::core::JSON{nullptr}, [&begin, &end](auto &stream) {
          for (auto iterator = begin; iterator != end; ++iterator) {
            sourcemeta::core::stringify(*iterator, stream);
            stream << "\n";
          }
        });

    return this->track(absolute_path);
  }

  auto
  write_metapack_html(const std::filesystem::path &path,
                      const sourcemeta::registry::MetaPackEncoding encoding,
                      const std::string_view contents)
      -> const std::filesystem::path & {
    const auto absolute_path{this->resolve(path)};
    std::filesystem::create_directories(absolute_path.parent_path());
    sourcemeta::registry::write_stream(absolute_path, "text/html", encoding,
                                       sourcemeta::core::JSON{nullptr},
                                       [&contents](auto &stream) {
                                         stream << contents;
                                         stream << "\n";
                                       });

    return this->track(absolute_path);
  }

  auto track(const std::filesystem::path &path)
      -> const std::filesystem::path & {
    assert(path.is_absolute());
    assert(std::filesystem::exists(path));
    std::lock_guard<std::mutex> lock(this->tracker_mutex);
    // Otherwise it means we wrote to the same place twice
    assert(!this->tracker.contains(path) || !this->tracker.at(path));
    const auto &result{this->tracker.insert_or_assign(path, true).first->first};
    // Track parent directories too
    for (auto current = path; !current.empty() && current != this->path_;
         current = current.parent_path()) {
      this->tracker.insert_or_assign(current, true);
    }

    return result;
  }

  auto is_untracked_file(const std::filesystem::path &path) const {
    const auto match{this->tracker.find(path)};
    return match == this->tracker.cend() || !match->second;
  }

private:
  auto resolve(const std::filesystem::path &relative_path) const
      -> std::filesystem::path {
    if (relative_path.is_absolute()) {
      return relative_path;
    }

    assert(relative_path.is_relative());
    // TODO: We need to have a "safe" path concat function that does not allow
    // the path to escape the parent. Make it part of Core
    return this->path_ / relative_path;
  }

  const std::filesystem::path path_;
  std::unordered_map<std::filesystem::path, bool> tracker;
  std::mutex tracker_mutex;
};

} // namespace sourcemeta::registry

#endif
