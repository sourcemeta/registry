#ifndef SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_
#define SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/md5.h>
#include <sourcemeta/core/time.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>

#include "html_partials.h"
#include "html_safe.h"
#include "semver.h"

#include <algorithm>  // std::sort
#include <cassert>    // assert
#include <chrono>     // std::chrono::system_clock::time_point
#include <filesystem> // std::filesystem
#include <fstream>    // std::ifstream
#include <optional>   // std::optional
#include <regex>      // std::regex, std::regex_search, std::smatch
#include <sstream>    // std::ostringstream
#include <string>     // std::string
#include <utility>    // std::move
#include <vector>     // std::vector

namespace sourcemeta::registry {

auto GENERATE_SERVER_CONFIGURATION(const sourcemeta::core::JSON &configuration)
    -> sourcemeta::core::JSON {
  auto summary{sourcemeta::core::JSON::make_object()};
  summary.assign("port", configuration.at("port"));
  return summary;
}

auto GENERATE_META(const std::filesystem::path &absolute_path,
                   const std::string &mime) -> sourcemeta::core::JSON {
  auto metadata{sourcemeta::core::JSON::make_object()};
  std::ifstream stream{absolute_path};
  stream.exceptions(std::ifstream::failbit | std::ifstream::badbit);
  assert(!stream.fail());
  assert(stream.is_open());
  std::ostringstream contents;
  contents << stream.rdbuf();
  std::ostringstream md5;
  sourcemeta::core::md5(contents.str(), md5);
  metadata.assign("md5", sourcemeta::core::JSON{md5.str()});
  const auto last_write_time{std::filesystem::last_write_time(absolute_path)};
  const auto last_modified{
      std::chrono::time_point_cast<std::chrono::system_clock::duration>(
          last_write_time - std::filesystem::file_time_type::clock::now() +
          std::chrono::system_clock::now())};
  metadata.assign("lastModified", sourcemeta::core::JSON{
                                      sourcemeta::core::to_gmt(last_modified)});
  metadata.assign("mime", sourcemeta::core::JSON{mime});
  return metadata;
}

auto GENERATE_SCHEMA_META(const std::filesystem::path &absolute_path,
                          const std::filesystem::path &canonical_schema_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::core::read_json(canonical_schema_path)};
  const auto dialect_identifier{sourcemeta::core::dialect(schema)};
  assert(dialect_identifier.has_value());
  auto metadata{GENERATE_META(absolute_path, "application/schema+json")};
  metadata.assign("dialect",
                  sourcemeta::core::JSON{dialect_identifier.value()});
  return metadata;
}

auto GENERATE_BUNDLE(const sourcemeta::core::SchemaResolver &resolver,
                     const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::core::read_json(absolute_path)};
  return sourcemeta::core::bundle(
      schema, sourcemeta::core::schema_official_walker, resolver);
}

auto GENERATE_UNIDENTIFIED(const sourcemeta::core::SchemaResolver &resolver,
                           const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  auto schema{sourcemeta::core::read_json(absolute_path)};
  sourcemeta::core::unidentify(schema, sourcemeta::core::schema_official_walker,
                               resolver);
  return schema;
}

auto GENERATE_BLAZE_TEMPLATE(const sourcemeta::core::SchemaResolver &resolver,
                             const std::filesystem::path &absolute_path,
                             const sourcemeta::blaze::Mode mode)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::core::read_json(absolute_path)};
  // TODO: Ideally we can store the frame and load it back as needed
  sourcemeta::core::SchemaFrame frame{
      sourcemeta::core::SchemaFrame::Mode::References};
  frame.analyse(schema, sourcemeta::core::schema_official_walker, resolver);
  const auto schema_template{sourcemeta::blaze::compile(
      schema, sourcemeta::core::schema_official_walker, resolver,
      sourcemeta::blaze::default_schema_compiler, frame, mode)};
  return sourcemeta::blaze::to_json(schema_template);
}

// TODO: Put breadcrumb inside this metadata
auto GENERATE_NAV_SCHEMA(const sourcemeta::core::JSON &configuration,
                         const sourcemeta::core::SchemaResolver &resolver,
                         const std::filesystem::path &absolute_path,
                         // TODO: Compute this argument instead
                         const std::filesystem::path &relative_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::core::read_json(absolute_path)};
  auto id{sourcemeta::core::identify(schema, resolver)};
  assert(id.has_value());
  auto result{sourcemeta::core::JSON::make_object()};
  result.assign("id", sourcemeta::core::JSON{std::move(id).value()});
  result.assign("url", sourcemeta::core::JSON{"/" + relative_path.string()});
  result.assign("canonical",
                sourcemeta::core::JSON{configuration.at("url").to_string() +
                                       "/" + relative_path.string()});
  const auto base_dialect{sourcemeta::core::base_dialect(schema, resolver)};
  assert(base_dialect.has_value());
  // The idea is to match the URLs from https://www.learnjsonschema.com
  // so we can provide links to it
  const std::regex MODERN(R"(^https://json-schema\.org/draft/(\d{4}-\d{2})/)");
  const std::regex LEGACY(R"(^http://json-schema\.org/draft-0?(\d+)/)");
  std::smatch match;
  if (std::regex_search(base_dialect.value(), match, MODERN)) {
    result.assign("baseDialect", sourcemeta::core::JSON{match[1].str()});
  } else if (std::regex_search(base_dialect.value(), match, LEGACY)) {
    result.assign("baseDialect",
                  sourcemeta::core::JSON{"draft" + match[1].str()});
  } else {
    // We should never get here
    assert(false);
    result.assign("baseDialect", sourcemeta::core::JSON{"unknown"});
  }

  const auto dialect{sourcemeta::core::dialect(schema, base_dialect)};
  assert(dialect.has_value());
  result.assign("dialect", sourcemeta::core::JSON{dialect.value()});
  if (schema.is_object()) {
    const auto title{schema.try_at("title")};
    if (title && title->is_string()) {
      result.assign("title", sourcemeta::core::JSON{title->trim()});
    }
    const auto description{schema.try_at("description")};
    if (description && description->is_string()) {
      result.assign("description", sourcemeta::core::JSON{description->trim()});
    }
  }

  return result;
}

// TODO: We should simplify this signature somehow
auto GENERATE_NAV_DIRECTORY(const sourcemeta::core::JSON &configuration,
                            const std::filesystem::path &navigation_base,
                            const std::filesystem::path &base,
                            const std::filesystem::path &directory)
    -> sourcemeta::core::JSON {
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
      if (configuration.defines("pages") &&
          configuration.at("pages").defines(entry_relative_path)) {
        entry_json.merge(
            configuration.at("pages").at(entry_relative_path).as_object());
      }

      entry_json.assign("type", sourcemeta::core::JSON{"directory"});
      entry_json.assign(
          "url", sourcemeta::core::JSON{
                     entry.path().string().substr(base.string().size())});
      entries.push_back(std::move(entry_json));
    } else if (entry.path().extension() == ".schema" &&
               !entry.path().stem().string().starts_with(".")) {
      entry_json.assign("name", sourcemeta::core::JSON{
                                    entry.path().stem().replace_extension("")});

      auto schema_nav_path{navigation_base / entry_relative_path};
      schema_nav_path.replace_extension("");
      // TODO: This generator should not be aware of the fact that
      // we use a .nav extension on the actual file?
      schema_nav_path.replace_extension("nav");

      entry_json.merge(
          sourcemeta::core::read_json(schema_nav_path).as_object());
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
          const auto left_version{
              sourcemeta::registry::try_parse_version(left_name.to_string())};
          const auto right_version{
              sourcemeta::registry::try_parse_version(right_name.to_string())};
          if (left_version.has_value() && right_version.has_value()) {
            return left_version.value() > right_version.value();
          }

          return left_name > right_name;
        }

        return left.at("type") < right.at("type");
      });

  auto meta{sourcemeta::core::JSON::make_object()};

  const auto page_key{std::filesystem::relative(directory, base)};
  if (configuration.defines("pages") &&
      configuration.at("pages").defines(page_key)) {
    meta.merge(configuration.at("pages").at(page_key).as_object());
  }

  meta.assign("entries", std::move(entries));

  // Precompute the breadcrumb
  const std::filesystem::path relative_path{directory.string().substr(
      std::min(base.string().size() + 1, directory.string().size()))};
  meta.assign(
      "url", sourcemeta::core::JSON{std::string{"/"} + relative_path.string()});

  if (relative_path.string().empty()) {
    meta.assign("canonical", configuration.at("url"));
  } else {
    meta.assign("canonical",
                sourcemeta::core::JSON{configuration.at("url").to_string() +
                                       "/" + relative_path.string()});
  }

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

auto GENERATE_SEARCH_INDEX(
    const std::vector<std::filesystem::path> &absolute_paths)
    -> std::vector<sourcemeta::core::JSON> {
  std::vector<sourcemeta::core::JSON> result;
  result.reserve(absolute_paths.size());
  for (const auto &absolute_path : absolute_paths) {
    auto metadata{sourcemeta::core::read_json(absolute_path)};
    auto entry{sourcemeta::core::JSON::make_array()};
    // TODO: Can we move all of these?
    entry.push_back(metadata.at("url"));
    entry.push_back(metadata.at_or("title", sourcemeta::core::JSON{""}));
    entry.push_back(metadata.at_or("description", sourcemeta::core::JSON{""}));
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

// TODO: HTML generators should not depend on the config file, as
// all the necessary information should be present in the nav file
auto GENERATE_EXPLORER_404(const sourcemeta::core::JSON &configuration)
    -> std::string {
  std::ostringstream stream;
  assert(!stream.fail());
  sourcemeta::registry::html::SafeOutput output_html{stream};

  const auto head{
      configuration.at_or("head", sourcemeta::core::JSON{""}).to_string()};

  sourcemeta::registry::html::partials::html_start(
      output_html, configuration.at("url").to_string(), head, configuration,
      "Not Found", "What you are looking for is not here", std::nullopt);
  output_html.open("div", {{"class", "container-fluid p-4"}})
      .open("h2", {{"class", "fw-bold"}})
      .text("Oops! What you are looking for is not here")
      .close("h2")
      .open("p", {{"class", "lead"}})
      .text("Are you sure the link you got is correct?")
      .close("p")
      .open("a", {{"href", "/"}})
      .text("Get back to the home page")
      .close("a")
      .close("div")
      .close("div");
  sourcemeta::registry::html::partials::html_end(
      output_html, sourcemeta::registry::PROJECT_VERSION);
  return stream.str();
}

// TODO: HTML generators should not depend on the config file, as
// all the necessary information should be present in the nav file
auto GENERATE_EXPLORER_INDEX(const sourcemeta::core::JSON &configuration,
                             const std::filesystem::path &navigation_path)
    -> std::string {
  const auto meta{sourcemeta::core::read_json(navigation_path)};
  std::ostringstream html;
  sourcemeta::registry::html::SafeOutput output_html{html};

  const auto head{
      configuration.at_or("head", sourcemeta::core::JSON{""}).to_string()};

  sourcemeta::registry::html::partials::html_start(
      output_html, meta.at("canonical").to_string(), head, configuration,
      configuration.at("title").to_string() + " Schemas",
      configuration.at("description").to_string(), "");

  if (configuration.defines("hero")) {
    output_html.open("div", {{"class", "container-fluid px-4"}})
        .open("div", {{"class",
                       "bg-light border border-light-subtle mt-4 px-3 py-3"}});
    output_html.unsafe(configuration.at("hero").to_string());
    output_html.close("div").close("div");
  }

  sourcemeta::registry::html::partials::html_file_manager(html, meta);
  sourcemeta::registry::html::partials::html_end(
      output_html, sourcemeta::registry::PROJECT_VERSION);
  return html.str();
}

// TODO: HTML generators should not depend on the config file, as
// all the necessary information should be present in the nav file
auto GENERATE_EXPLORER_DIRECTORY_PAGE(
    const sourcemeta::core::JSON &configuration,
    const std::filesystem::path &navigation_path) -> std::string {
  const auto meta{sourcemeta::core::read_json(navigation_path)};
  std::ostringstream html;

  sourcemeta::registry::html::SafeOutput output_html{html};
  const auto head{
      configuration.at_or("head", sourcemeta::core::JSON{""}).to_string()};
  sourcemeta::registry::html::partials::html_start(
      output_html, meta.at("canonical").to_string(), head, configuration,
      meta.defines("title") ? meta.at("title").to_string()
                            : meta.at("url").to_string(),
      meta.defines("description")
          ? meta.at("description").to_string()
          : ("Schemas located at " + meta.at("url").to_string()),
      meta.at("url").to_string());
  sourcemeta::registry::html::partials::html_file_manager(html, meta);
  sourcemeta::registry::html::partials::html_end(
      output_html, sourcemeta::registry::PROJECT_VERSION);
  return html.str();
}

} // namespace sourcemeta::registry

#endif
