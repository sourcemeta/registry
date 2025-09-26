#ifndef SOURCEMETA_REGISTRY_INDEX_EXPLORER_H_
#define SOURCEMETA_REGISTRY_INDEX_EXPLORER_H_

#include <sourcemeta/registry/configuration.h>
#include <sourcemeta/registry/resolver.h>
#include <sourcemeta/registry/shared.h>

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

static auto try_parse_version(const sourcemeta::core::JSON::String &name)
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

static auto
inflate_metadata(const sourcemeta::registry::Configuration &configuration,
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

namespace sourcemeta::registry {

struct GENERATE_EXPLORER_SCHEMA_METADATA {
  using Context =
      std::tuple<std::reference_wrapper<const sourcemeta::registry::Resolver>,
                 std::reference_wrapper<
                     const sourcemeta::registry::Configuration::Collection>,
                 std::filesystem::path>;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
              &callback,
          const Context &context) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    const auto schema{
        sourcemeta::registry::read_json_with_metadata(dependencies.front())};
    auto id{sourcemeta::core::identify(
        schema.data, [&callback, &context](const auto identifier) {
          return std::get<0>(context).get()(identifier, callback);
        })};
    assert(id.has_value());
    auto result{sourcemeta::core::JSON::make_object()};

    result.assign("bytes", sourcemeta::core::JSON{schema.bytes});
    result.assign("identifier", sourcemeta::core::JSON{std::move(id).value()});
    result.assign("path",
                  sourcemeta::core::JSON{"/" + std::get<2>(context).string()});
    const auto base_dialect{sourcemeta::core::base_dialect(
        schema.data, [&callback, &context](const auto identifier) {
          return std::get<0>(context).get()(identifier, callback);
        })};
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
        result.assign("description",
                      sourcemeta::core::JSON{description->trim()});
      }

      auto examples_array{sourcemeta::core::JSON::make_array()};
      const auto *examples{schema.data.try_at("examples")};
      if (examples && examples->is_array() && !examples->empty()) {
        const auto vocabularies{sourcemeta::core::vocabularies(
            [&callback, &context](const auto identifier) {
              return std::get<0>(context).get()(identifier, callback);
            },
            base_dialect.value(), dialect.value())};
        const auto walker_result{
            sourcemeta::core::schema_official_walker("examples", vocabularies)};
        if (walker_result.type ==
                sourcemeta::core::SchemaKeywordType::Annotation ||
            walker_result.type ==
                sourcemeta::core::SchemaKeywordType::Comment) {
          constexpr std::size_t EXAMPLES_MAXIMUM{10};
          for (std::size_t cursor = 0;
               cursor < std::min(EXAMPLES_MAXIMUM, examples->size());
               cursor++) {
            examples_array.push_back(examples->at(cursor));
          }
        }
      }

      result.assign("examples", std::move(examples_array));
    }

    const auto health{sourcemeta::registry::read_json(dependencies.at(1))};
    result.assign("health", health.at("score"));
    result.assign("protected", sourcemeta::core::JSON{dependencies.size() > 4});

    const auto &collection{std::get<1>(context).get()};
    if (collection.extra.defines("x-sourcemeta-registry:alert")) {
      assert(collection.extra.at("x-sourcemeta-registry:alert").is_string());
      result.assign("alert",
                    collection.extra.at("x-sourcemeta-registry:alert"));
    } else {
      result.assign("alert", sourcemeta::core::JSON{nullptr});
    }

    // Precompute the breadcrumb
    result.assign("breadcrumb", sourcemeta::core::JSON::make_array());
    std::filesystem::path current_path{"/"};
    auto copy = std::get<2>(context);
    for (const auto &part : copy) {
      current_path = current_path / part;
      auto breadcrumb_entry{sourcemeta::core::JSON::make_object()};
      breadcrumb_entry.assign("name", sourcemeta::core::JSON{part});
      breadcrumb_entry.assign("path", sourcemeta::core::JSON{current_path});
      result.at("breadcrumb").push_back(std::move(breadcrumb_entry));
    }
    const auto timestamp_end{std::chrono::steady_clock::now()};

    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, result, "application/json",
        sourcemeta::registry::Encoding::GZIP, sourcemeta::core::JSON{nullptr},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }
};

struct GENERATE_EXPLORER_SEARCH_INDEX {
  using Context = std::nullptr_t;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
          const Context &) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    std::vector<sourcemeta::core::JSON> result;
    result.reserve(dependencies.size());

    for (const auto &metadata_path : dependencies) {
      auto metadata_json{sourcemeta::registry::read_json(metadata_path)};
      if (!sourcemeta::core::is_schema(metadata_json)) {
        continue;
      }

      auto entry{sourcemeta::core::JSON::make_array()};
      entry.push_back(
          sourcemeta::core::JSON{metadata_json.at("path").to_string()});
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
                const auto left_score = (!left.at(1).empty() ? 1 : 0) +
                                        (!left.at(2).empty() ? 1 : 0);
                const auto right_score = (!right.at(1).empty() ? 1 : 0) +
                                         (!right.at(2).empty() ? 1 : 0);
                if (left_score != right_score) {
                  return left_score > right_score;
                }

                // Otherwise revert to lexicographic comparisons
                // TODO: Ideally we sort based on schema health too, given
                // lint results
                if (left_score > 0) {
                  return left.at(0).to_string() < right.at(0).to_string();
                }

                return false;
              });

    const auto timestamp_end{std::chrono::steady_clock::now()};

    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_jsonl(
        destination, result, "application/jsonl",
        // We don't want to compress this one so we can
        // quickly skim through it while streaming it
        sourcemeta::registry::Encoding::Identity,
        sourcemeta::core::JSON{nullptr},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }
};

struct GENERATE_EXPLORER_DIRECTORY_LIST {
  struct Context {
    const std::filesystem::path &directory;
    const sourcemeta::registry::Configuration &configuration;
    const sourcemeta::registry::Output &output;
    const std::filesystem::path &explorer_path;
    const std::filesystem::path &schemas_path;
  };

  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path> &,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
              &callback,
          const Context &context) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    assert(
        context.directory.string().starts_with(context.schemas_path.string()));
    auto entries{sourcemeta::core::JSON::make_array()};

    std::vector<sourcemeta::core::JSON::Integer> scores;

    if (std::filesystem::exists(context.directory)) {
      for (const auto &entry :
           std::filesystem::directory_iterator{context.directory}) {
        auto entry_json{sourcemeta::core::JSON::make_object()};
        const auto entry_relative_path{entry.path().string().substr(
            context.schemas_path.string().size() + 1)};
        assert(!entry_relative_path.starts_with('/'));
        if (entry.is_directory() && entry.path().filename() != "%" &&
            !std::filesystem::exists(entry.path() / "%" / "schema.metapack") &&
            !context.output.is_untracked_file(entry.path())) {
          const auto directory_nav_path{context.explorer_path /
                                        entry_relative_path / "%" /
                                        "directory.metapack"};
          callback(directory_nav_path);
          auto directory_nav_json{
              sourcemeta::registry::read_json(directory_nav_path)};
          assert(directory_nav_json.is_object());
          assert(directory_nav_json.defines("health"));
          assert(directory_nav_json.at("health").is_integer());
          scores.emplace_back(directory_nav_json.at("health").to_integer());
          entry_json.assign("health", directory_nav_json.at("health"));

          entry_json.assign("name",
                            sourcemeta::core::JSON{entry.path().filename()});
          inflate_metadata(context.configuration, entry_relative_path,
                           entry_json);

          entry_json.assign("type", sourcemeta::core::JSON{"directory"});
          entry_json.assign("path",
                            sourcemeta::core::JSON{entry.path().string().substr(
                                context.schemas_path.string().size())});
          entries.push_back(std::move(entry_json));

        } else if (entry.is_directory() &&
                   std::filesystem::exists(entry.path() / "%" /
                                           "schema.metapack")) {
          auto name{entry.path().filename()};
          entry_json.assign("name", sourcemeta::core::JSON{std::move(name)});
          auto schema_nav_path{context.explorer_path / entry_relative_path};
          schema_nav_path /= "%";
          schema_nav_path /= "schema.metapack";

          auto nav{sourcemeta::registry::read_json(schema_nav_path)};
          entry_json.merge(nav.as_object());
          assert(!entry_json.defines("entries"));
          // No need to show these on children
          entry_json.erase("breadcrumb");
          entry_json.erase("examples");
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

            // If the schema/directories represent SemVer versions,
            // attempt to parse them as such and provide better sorting
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

    const auto page_key{
        std::filesystem::relative(context.directory, context.schemas_path)};
    inflate_metadata(context.configuration, page_key, meta);

    const auto accumulated_health =
        static_cast<int>(std::lround(static_cast<double>(std::accumulate(
                                         scores.cbegin(), scores.cend(), 0LL)) /
                                     static_cast<double>(scores.size())));

    meta.assign("health", sourcemeta::core::JSON{accumulated_health});

    meta.assign("entries", std::move(entries));

    const std::filesystem::path relative_path{context.directory.string().substr(
        std::min(context.schemas_path.string().size() + 1,
                 context.directory.string().size()))};
    meta.assign("path", sourcemeta::core::JSON{std::string{"/"} +
                                               relative_path.string()});

    if (relative_path.string().empty()) {
      meta.assign("url", sourcemeta::core::JSON{context.configuration.url});
    } else {
      meta.assign("url", sourcemeta::core::JSON{context.configuration.url +
                                                "/" + relative_path.string()});
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
    const auto timestamp_end{std::chrono::steady_clock::now()};

    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, meta, "application/json",
        sourcemeta::registry::Encoding::GZIP, sourcemeta::core::JSON{nullptr},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }
};

} // namespace sourcemeta::registry

#endif
