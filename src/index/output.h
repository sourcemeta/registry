#ifndef SOURCEMETA_REGISTRY_INDEX_OUTPUT_H_
#define SOURCEMETA_REGISTRY_INDEX_OUTPUT_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>

#include <sourcemeta/registry/shared.h>

#include <cassert>       // assert
#include <filesystem>    // std::filesystem
#include <iostream>      // std::cerr
#include <shared_mutex>  // std::shared_mutex, std::shared_lock
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

  auto write_json_if_different(const std::filesystem::path &path,
                               const sourcemeta::core::JSON &document) -> void {
    if (std::filesystem::exists(path)) {
      const auto current{sourcemeta::core::read_json(path)};
      if (current != document) {
        this->write_json(path, document);
      } else {
        this->track(path);
      }
    } else {
      this->write_json(path, document);
    }
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
  auto write_json(const std::filesystem::path &path,
                  const sourcemeta::core::JSON &document)
      -> const std::filesystem::path & {
    assert(path.is_absolute());
    std::filesystem::create_directories(path.parent_path());
    std::ofstream stream{path};
    assert(!stream.fail());
    sourcemeta::core::stringify(document, stream);
    return this->track(path);
  }

  const std::filesystem::path path_;
  std::unordered_map<std::filesystem::path, bool> tracker;
  mutable std::shared_mutex tracker_mutex;
};

} // namespace sourcemeta::registry

#endif
