#ifndef SOURCEMETA_REGISTRY_INDEX_EXPLORER_H_
#define SOURCEMETA_REGISTRY_INDEX_EXPLORER_H_

#include <sourcemeta/registry/configuration.h>
#include <sourcemeta/registry/resolver.h>
#include <sourcemeta/registry/shared.h>

#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>

#include "output.h"

#include <algorithm>  // std::sort
#include <cassert>    // assert
#include <cmath>      // std::lround
#include <filesystem> // std::filesystem
#include <numeric>    // std::accumulate
#include <optional>   // std::optional
#include <regex>      // std::regex, std::regex_search, std::smatch
#include <string>     // std::string, std::stoul
#include <tuple>      // std::tuple, std::make_tuple
#include <utility>    // std::move
#include <vector>     // std::vector

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

namespace sourcemeta::registry {

auto GENERATE_NAV_SCHEMA(
    const sourcemeta::core::JSON::String &,
    const sourcemeta::registry::Resolver &resolver,
    const std::filesystem::path &absolute_path,
    const std::filesystem::path &health_path,
    const std::filesystem::path &protected_path,
    const sourcemeta::registry::Configuration::Collection &collection,
    // TODO: Compute this argument instead
    const std::filesystem::path &relative_path) -> sourcemeta::core::JSON {
  const auto schema{
      sourcemeta::registry::read_json_with_metadata(absolute_path)};
  auto id{sourcemeta::core::identify(
      schema.data,
      [&resolver](const auto identifier) { return resolver(identifier); })};
  assert(id.has_value());
  auto result{sourcemeta::core::JSON::make_object()};

  result.assign("bytes", sourcemeta::core::JSON{schema.bytes});
  result.assign("identifier", sourcemeta::core::JSON{std::move(id).value()});
  result.assign("path", sourcemeta::core::JSON{"/" + relative_path.string()});
  const auto base_dialect{sourcemeta::core::base_dialect(
      schema.data,
      [&resolver](const auto identifier) { return resolver(identifier); })};
  assert(base_dialect.has_value());
  result.assign("baseDialect", sourcemeta::core::JSON{base_dialect.value()});

  const auto dialect{sourcemeta::core::dialect(schema.data, base_dialect)};
  assert(dialect.has_value());
  result.assign("dialect", sourcemeta::core::JSON{dialect.value()});
  if (schema.data.is_object()) {
    const auto title{schema.data.try_at("title")};
    if (title && title->is_string()) {
      result.assign("title", sourcemeta::core::JSON{title->trim()});
    }
    const auto description{schema.data.try_at("description")};
    if (description && description->is_string()) {
      result.assign("description", sourcemeta::core::JSON{description->trim()});
    }
  }

  const auto health{sourcemeta::registry::read_json(health_path)};
  result.assign("health", health.at("score"));

  result.assign("protected", sourcemeta::core::JSON{
                                 std::filesystem::exists(protected_path)});

  // TODO: This means we need this target to depend on the config file or the
  // relevant include!
  if (collection.extra.defines("x-sourcemeta-registry:alert")) {
    assert(collection.extra.at("x-sourcemeta-registry:alert").is_string());
    result.assign("alert", collection.extra.at("x-sourcemeta-registry:alert"));
  } else {
    result.assign("alert", sourcemeta::core::JSON{nullptr});
  }

  // Precompute the breadcrumb
  result.assign("breadcrumb", sourcemeta::core::JSON::make_array());
  std::filesystem::path current_path{"/"};
  auto copy = relative_path;
  for (const auto &part : copy) {
    current_path = current_path / part;
    auto breadcrumb_entry{sourcemeta::core::JSON::make_object()};
    breadcrumb_entry.assign("name", sourcemeta::core::JSON{part});
    breadcrumb_entry.assign("path", sourcemeta::core::JSON{current_path});
    result.at("breadcrumb").push_back(std::move(breadcrumb_entry));
  }

  return result;
}

auto inflate_metadata(const sourcemeta::registry::Configuration &configuration,
                      const std::filesystem::path &path,
                      sourcemeta::core::JSON &target) -> void {
  const auto match{configuration.entries.find(path)};
  if (match == configuration.entries.cend()) {
    return;
  }

  std::visit(
      [&target](const auto &entry) {
        if (entry.title.has_value()) {
          target.assign_if_missing(
              "title", sourcemeta::core::to_json(entry.title.value()));
        }

        if (entry.description.has_value()) {
          target.assign_if_missing(
              "description",
              sourcemeta::core::to_json(entry.description.value()));
        }

        if (entry.email.has_value()) {
          target.assign_if_missing(
              "email", sourcemeta::core::to_json(entry.email.value()));
        }

        if (entry.github.has_value()) {
          target.assign_if_missing(
              "github", sourcemeta::core::to_json(entry.github.value()));
        }

        if (entry.website.has_value()) {
          target.assign_if_missing(
              "website", sourcemeta::core::to_json(entry.website.value()));
        }
      },
      match->second);
}

auto GENERATE_NAV_DIRECTORY(
    const sourcemeta::registry::Configuration &configuration,
    const std::filesystem::path &navigation_base,
    const std::filesystem::path &base, const std::filesystem::path &directory,
    const sourcemeta::registry::Output &output) -> sourcemeta::core::JSON {
  assert(directory.string().starts_with(base.string()));
  auto entries{sourcemeta::core::JSON::make_array()};

  std::vector<sourcemeta::core::JSON::Integer> scores;
  if (std::filesystem::exists(directory)) {
    for (const auto &entry : std::filesystem::directory_iterator{directory}) {
      auto entry_json{sourcemeta::core::JSON::make_object()};
      const auto entry_relative_path{
          entry.path().string().substr(base.string().size() + 1)};
      assert(!entry_relative_path.starts_with('/'));
      if (entry.is_directory() && entry.path().filename() != "%" &&
          !std::filesystem::exists(entry.path() / "%" / "schema.metapack") &&
          !output.is_untracked_file(entry.path())) {
        const auto directory_nav_path{navigation_base / entry_relative_path /
                                      "%" / "directory.metapack"};
        auto directory_nav_json{
            sourcemeta::registry::read_json(directory_nav_path)};
        assert(directory_nav_json.is_object());
        assert(directory_nav_json.defines("health"));
        assert(directory_nav_json.at("health").is_integer());
        scores.emplace_back(directory_nav_json.at("health").to_integer());
        entry_json.assign("health", directory_nav_json.at("health"));

        entry_json.assign("name",
                          sourcemeta::core::JSON{entry.path().filename()});
        inflate_metadata(configuration, entry_relative_path, entry_json);

        entry_json.assign("type", sourcemeta::core::JSON{"directory"});
        entry_json.assign(
            "path", sourcemeta::core::JSON{
                        entry.path().string().substr(base.string().size())});
        entries.push_back(std::move(entry_json));

      } else if (entry.is_directory() &&
                 std::filesystem::exists(entry.path() / "%" /
                                         "schema.metapack")) {
        auto name{entry.path().filename()};
        entry_json.assign("name", sourcemeta::core::JSON{std::move(name)});
        auto schema_nav_path{navigation_base / entry_relative_path};
        schema_nav_path /= "%";
        schema_nav_path /= "schema.metapack";

        auto nav{sourcemeta::registry::read_json(schema_nav_path)};
        entry_json.merge(nav.as_object());
        assert(!entry_json.defines("entries"));
        // No need to show breadcrumbs of children
        entry_json.erase("breadcrumb");
        entry_json.assign("type", sourcemeta::core::JSON{"schema"});

        assert(entry_json.defines("path"));
        std::filesystem::path url{entry_json.at("path").to_string()};
        entry_json.at("path").into(sourcemeta::core::JSON{url});

        assert(entry_json.defines("health"));
        assert(entry_json.at("health").is_integer());
        scores.emplace_back(entry_json.at("health").to_integer());
        entries.push_back(std::move(entry_json));
      }
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

  const auto page_key{std::filesystem::relative(directory, base)};
  inflate_metadata(configuration, page_key, meta);

  const auto accumulated_health =
      static_cast<int>(std::lround(static_cast<double>(std::accumulate(
                                       scores.cbegin(), scores.cend(), 0LL)) /
                                   static_cast<double>(scores.size())));

  meta.assign("health", sourcemeta::core::JSON{accumulated_health});

  meta.assign("entries", std::move(entries));

  const std::filesystem::path relative_path{directory.string().substr(
      std::min(base.string().size() + 1, directory.string().size()))};
  meta.assign("path", sourcemeta::core::JSON{std::string{"/"} +
                                             relative_path.string()});

  if (relative_path.string().empty()) {
    meta.assign("url", sourcemeta::core::JSON{configuration.url});
  } else {
    meta.assign("url", sourcemeta::core::JSON{configuration.url + "/" +
                                              relative_path.string()});
  }

  // Precompute the breadcrumb
  meta.assign("breadcrumb", sourcemeta::core::JSON::make_array());
  std::filesystem::path current_path{"/"};
  for (const auto &part : relative_path) {
    current_path = current_path / part;
    auto breadcrumb_entry{sourcemeta::core::JSON::make_object()};
    breadcrumb_entry.assign("name", sourcemeta::core::JSON{part});
    breadcrumb_entry.assign("path", sourcemeta::core::JSON{current_path});
    meta.at("breadcrumb").push_back(std::move(breadcrumb_entry));
  }

  return meta;
}

auto GENERATE_SEARCH_INDEX(
    const std::vector<std::filesystem::path> &absolute_paths)
    -> std::vector<sourcemeta::core::JSON> {
  std::vector<sourcemeta::core::JSON> result;
  result.reserve(absolute_paths.size());
  for (const auto &absolute_path : absolute_paths) {
    auto metadata_json{sourcemeta::registry::read_json(absolute_path)};
    auto entry{sourcemeta::core::JSON::make_array()};
    std::filesystem::path url = metadata_json.at("path").to_string();
    entry.push_back(sourcemeta::core::JSON{url});
    // TODO: Can we move these?
    entry.push_back(metadata_json.at_or("title", sourcemeta::core::JSON{""}));
    entry.push_back(
        metadata_json.at_or("description", sourcemeta::core::JSON{""}));
    result.push_back(std::move(entry));
  }

  std::sort(result.begin(), result.end(),
            [](const sourcemeta::core::JSON &left,
               const sourcemeta::core::JSON &right) {
              assert(left.is_array() && left.size() == 3);
              assert(right.is_array() && right.size() == 3);

              // Prioritise entries that have more meta-data filled in
              const auto left_score =
                  (!left.at(1).empty() ? 1 : 0) + (!left.at(2).empty() ? 1 : 0);
              const auto right_score = (!right.at(1).empty() ? 1 : 0) +
                                       (!right.at(2).empty() ? 1 : 0);
              if (left_score != right_score) {
                return left_score > right_score;
              }

              // Otherwise revert to lexicographic comparisons
              // TODO: Ideally we sort based on schema health too, given lint
              // results
              if (left_score > 0) {
                return left.at(0).to_string() < right.at(0).to_string();
              }

              return false;
            });

  return result;
}

} // namespace sourcemeta::registry

#endif
