#ifndef SOURCEMETA_REGISTRY_SERVER_SEARCH_H
#define SOURCEMETA_REGISTRY_SERVER_SEARCH_H

#include <sourcemeta/core/json.h>

#include <sourcemeta/registry/shared.h>

#include <algorithm>   // std::search
#include <cassert>     // assert
#include <filesystem>  // std::filesystem
#include <string>      // std::string, std::getline
#include <string_view> // std::string_view

namespace sourcemeta::registry {

static auto search(const std::filesystem::path &search_index,
                   const std::string_view query) -> sourcemeta::core::JSON {
  assert(std::filesystem::exists(search_index));
  assert(search_index.is_absolute());
  auto file{read_stream_raw(search_index)};
  assert(file.has_value());

  auto result{sourcemeta::core::JSON::make_array()};
  // TODO: Extend the Core JSONL iterators to be able
  // to access the stringified contents of the current entry
  // BEFORE parsing it as JSON, letting the client decide
  // whether to parse or not.
  std::string line;
  while (std::getline(file.value().data, line)) {
    if (std::search(line.cbegin(), line.cend(), query.begin(), query.end(),
                    [](const auto left, const auto right) {
                      return std::tolower(left) == std::tolower(right);
                    }) == line.cend()) {
      continue;
    }

    auto entry{sourcemeta::core::JSON::make_object()};
    auto line_json{sourcemeta::core::parse_json(line)};
    entry.assign("url", std::move(line_json.at(0)));
    entry.assign("title", std::move(line_json.at(1)));
    entry.assign("description", std::move(line_json.at(2)));
    result.push_back(std::move(entry));

    constexpr auto MAXIMUM_SEARCH_COUNT{10};
    if (result.array_size() >= MAXIMUM_SEARCH_COUNT) {
      break;
    }
  }

  return result;
}

} // namespace sourcemeta::registry

#endif
