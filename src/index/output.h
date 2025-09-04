#ifndef SOURCEMETA_REGISTRY_INDEX_OUTPUT_H_
#define SOURCEMETA_REGISTRY_INDEX_OUTPUT_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/registry/metapack.h>

#include <cassert>       // assert
#include <filesystem>    // std::filesystem
#include <iostream>      // std::cerr
#include <shared_mutex>  // std::shared_mutex
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

  auto write_metapack_json(const std::filesystem::path &path,
                           const sourcemeta::registry::Encoding encoding,
                           const sourcemeta::core::JSON &document)
      -> const std::filesystem::path & {
    const auto absolute_path{this->resolve(path)};
    std::filesystem::create_directories(absolute_path.parent_path());
    sourcemeta::registry::write_pretty_json(absolute_path, document,
                                            "application/json", encoding,
                                            sourcemeta::core::JSON{nullptr});
    return this->track(absolute_path);
  }

  auto write_metapack_jsonl(const std::filesystem::path &path,
                            const sourcemeta::registry::Encoding encoding,
                            const std::vector<sourcemeta::core::JSON> &entries)
      -> const std::filesystem::path & {
    const auto absolute_path{this->resolve(path)};
    std::filesystem::create_directories(absolute_path.parent_path());
    sourcemeta::registry::write_jsonl(absolute_path, entries,
                                      "application/jsonl", encoding,
                                      sourcemeta::core::JSON{nullptr});
    return this->track(absolute_path);
  }

  auto write_metapack_html(const std::filesystem::path &path,
                           const sourcemeta::registry::Encoding encoding,
                           const std::string_view contents)
      -> const std::filesystem::path & {
    const auto absolute_path{this->resolve(path)};
    std::filesystem::create_directories(absolute_path.parent_path());
    sourcemeta::registry::write_text(absolute_path, contents, "text/html",
                                     encoding, sourcemeta::core::JSON{nullptr});
    return this->track(absolute_path);
  }

  auto track(const std::filesystem::path &path)
      -> const std::filesystem::path & {
    assert(path.is_absolute());
    assert(std::filesystem::exists(path));
    std::unique_lock lock{this->tracker_mutex};
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
    // Because reading from a hash map while writing to it is undefined
    // behaviour
    std::shared_lock lock{this->tracker_mutex};
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
  mutable std::shared_mutex tracker_mutex;
};

} // namespace sourcemeta::registry

#endif
