#include <sourcemeta/registry/configuration.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>
#include <sourcemeta/blaze/output.h>
#include <sourcemeta/core/uri.h>

#include "schema.h"

#include <cassert> // assert

namespace {

auto page_from_json(const sourcemeta::core::JSON &input)
    -> sourcemeta::registry::Configuration::Page {
  sourcemeta::registry::Configuration::Page result;
  using namespace sourcemeta::core;
  result.title = from_json<decltype(result.title)::value_type>(
      input.at_or("title", JSON{nullptr}));
  result.description = from_json<decltype(result.description)::value_type>(
      input.at_or("description", JSON{nullptr}));
  result.email = from_json<decltype(result.email)::value_type>(
      input.at_or("email", JSON{nullptr}));
  result.github = from_json<decltype(result.github)::value_type>(
      input.at_or("github", JSON{nullptr}));
  result.website = from_json<decltype(result.website)::value_type>(
      input.at_or("website", JSON{nullptr}));
  return result;
}

template <typename T>
auto entries_from_json(T &result, const std::filesystem::path &location,
                       const sourcemeta::core::JSON &input) -> void {
  // A heuristic to check if we are at the root or not
  if (input.defines("url")) {
    if (input.defines("contents")) {
      for (const auto &entry : input.at("contents").as_object()) {
        entries_from_json<T>(result, location / entry.first, entry.second);
      }
    }
  } else {
    assert(!result.contains(location));
    if (input.defines("path")) {
      result.emplace(location,
                     sourcemeta::core::SchemaConfig::from_json(
                         input,
                         // This path doesn't matter much here, as by now we
                         // have converted all paths to their absolute forms
                         std::filesystem::current_path()));
    } else {
      result.emplace(location, page_from_json(input));
      // Only pages may have children
      if (input.defines("contents")) {
        for (const auto &entry : input.at("contents").as_object()) {
          entries_from_json<T>(result, location / entry.first, entry.second);
        }
      }
    }
  }
}

} // namespace

namespace sourcemeta::registry {

auto Configuration::parse(const sourcemeta::core::JSON &data) -> Configuration {
  const auto compiled_schema{sourcemeta::blaze::compile(
      sourcemeta::core::parse_json(std::string{CONFIGURATION_SCHEMA}),
      sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::blaze::default_schema_compiler,
      sourcemeta::blaze::Mode::Exhaustive)};
  sourcemeta::blaze::Evaluator evaluator;
  sourcemeta::blaze::SimpleOutput output{data};
  if (!evaluator.validate(compiled_schema, data, std::ref(output))) {
    throw ConfigurationValidationError(output);
  }

  Configuration result;
  result.url = sourcemeta::core::URI{data.at("url").to_string()}
                   .canonicalize()
                   .recompose();

  result.name = data.at("name").to_string();
  result.description = data.at("description").to_string();
  result.port = data.at("port").to_integer();

  if (data.defines("hero")) {
    result.hero = data.at("hero").to_string();
  }

  if (data.defines("head")) {
    result.head = data.at("head").to_string();
  }

  if (data.defines("action")) {
    result.action = {.url = data.at("action").at("url").to_string(),
                     .icon = data.at("action").at("icon").to_string(),
                     .title = data.at("action").at("title").to_string()};
  }

  entries_from_json(result.entries, "", data);

  return result;
}

} // namespace sourcemeta::registry
