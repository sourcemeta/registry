#ifndef SOURCEMETA_REGISTRY_INDEX_TOC_H_
#define SOURCEMETA_REGISTRY_INDEX_TOC_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>

#include <algorithm>  // std::sort
#include <cassert>    // assert
#include <filesystem> // std::filesystem
#include <regex>      // std::regex, std::smatch, std::regex_search
#include <string>     // std::string
#include <tuple>      // std::tuple, std::make_tuple
#include <utility>    // std::move

namespace {

// TODO: We need a SemVer module in Core
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

} // namespace

namespace sourcemeta::registry {

auto toc(const Configuration &configuration,
         const std::filesystem::path &navigation_base,
         const std::filesystem::path &base,
         const std::filesystem::path &directory) -> sourcemeta::core::JSON {
  const auto server_url_string{configuration.url().recompose()};
  assert(directory.string().starts_with(base.string()));
  auto entries{sourcemeta::core::JSON::make_array()};

  for (const auto &entry : std::filesystem::directory_iterator{directory}) {
    auto entry_json{sourcemeta::core::JSON::make_object()};
    const auto entry_relative_path{
        entry.path().string().substr(base.string().size() + 1)};
    assert(!entry_relative_path.starts_with('/'));
    if (entry.is_directory()) {
      entry_json.assign("name",
                        sourcemeta::core::JSON{entry.path().filename()});
      entry_json.merge(configuration.page(entry_relative_path));
      entry_json.assign("type", sourcemeta::core::JSON{"directory"});
      entry_json.assign(
          "url", sourcemeta::core::JSON{
                     entry.path().string().substr(base.string().size())});
      entries.push_back(std::move(entry_json));
    } else if (entry.path().extension() == ".schema" &&
               !entry.path().stem().string().starts_with(".")) {
      entry_json.assign("name", sourcemeta::core::JSON{
                                    entry.path().stem().replace_extension("")});

      auto schema_meta_path{navigation_base / "pages" / entry_relative_path};
      schema_meta_path.replace_extension("");
      schema_meta_path.replace_extension("nav");

      entry_json.merge(
          sourcemeta::core::read_json(schema_meta_path).as_object());
      entry_json.assign("type", sourcemeta::core::JSON{"schema"});
      entries.push_back(std::move(entry_json));
    }
  }

  std::sort(
      entries.as_array().begin(), entries.as_array().end(),
      [](const auto &left, const auto &right) {
        if (left.at("type") == right.at("type")) {
          const auto &left_name{left.at("name")};
          const auto &right_name{right.at("name")};

          // If the schema/directories represent SemVer versions, attempt to
          // parse them as such and provide better sorting
          const auto left_version{try_parse_version(left_name.to_string())};
          const auto right_version{try_parse_version(right_name.to_string())};
          if (left_version.has_value() && right_version.has_value()) {
            return left_version.value() > right_version.value();
          }

          return left_name > right_name;
        }

        return left.at("type") < right.at("type");
      });

  auto meta{sourcemeta::core::JSON::make_object()};
  meta.merge(
      configuration.page(std::filesystem::relative(directory, base).string()));
  meta.assign("entries", std::move(entries));

  // Precompute the breadcrumb
  const std::filesystem::path relative_path{directory.string().substr(
      std::min(base.string().size() + 1, directory.string().size()))};
  meta.assign("breadcrumb", sourcemeta::core::JSON::make_array());
  std::filesystem::path current_path{"/"};
  for (const auto &part : relative_path) {
    current_path = current_path / part;
    auto breadcrumb_entry{sourcemeta::core::JSON::make_object()};
    breadcrumb_entry.assign("name", sourcemeta::core::JSON{part});
    breadcrumb_entry.assign("url", sourcemeta::core::JSON{current_path});
    meta.at("breadcrumb").push_back(std::move(breadcrumb_entry));
  }

  return meta;
}

} // namespace sourcemeta::registry

#endif
