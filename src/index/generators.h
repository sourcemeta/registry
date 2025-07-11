#ifndef SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_
#define SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>

#include <algorithm>  // std::sort
#include <cassert>    // assert
#include <chrono>     // std::chrono::system_clock::time_point
#include <filesystem> // std::filesystem
#include <fstream>    // std::ifstream
#include <optional>   // std::optional
#include <regex>      // std::regex, std::regex_search, std::smatch
#include <sstream>    // std::ostringstream
#include <vector>     // std::vector

namespace sourcemeta::registry {

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
auto GENERATE_NAV_SCHEMA(const sourcemeta::registry::Resolver &resolver,
                         const std::filesystem::path &absolute_path,
                         const std::filesystem::path &relative_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::core::read_json(absolute_path)};
  auto id{sourcemeta::core::identify(schema, resolver)};
  assert(id.has_value());
  auto result{sourcemeta::core::JSON::make_object()};
  result.assign("id", sourcemeta::core::JSON{std::move(id).value()});
  result.assign("url", sourcemeta::core::JSON{"/" + relative_path.string()});
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

} // namespace sourcemeta::registry

#endif
