#ifndef SOURCEMETA_REGISTRY_INDEX_SEMVER_H_
#define SOURCEMETA_REGISTRY_INDEX_SEMVER_H_

#include <sourcemeta/core/json.h>

#include <optional> // std::optional, std::nullopt
#include <regex>    // std::regex, std::smatch, std::regex_search
#include <string>   // std::stoul
#include <tuple>    // std::tuple, std::make_tuple

// TODO: We need a SemVer module in Core

namespace sourcemeta::registry {

auto try_parse_version(const sourcemeta::core::JSON::String &name)
    -> std::optional<std::tuple<unsigned, unsigned, unsigned>> {
  std::regex version_regex(R"(v?(\d+)\.(\d+)\.(\d+))");
  std::smatch match;
  if (std::regex_search(name, match, version_regex)) {
    return std::make_tuple(std::stoul(match[1]), std::stoul(match[2]),
                           std::stoul(match[3]));
  } else {
    return std::nullopt;
  }
}

} // namespace sourcemeta::registry

#endif
