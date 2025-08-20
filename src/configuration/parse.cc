#include <sourcemeta/registry/configuration.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>
#include <sourcemeta/core/uri.h>

#include "schema.h"

#include <algorithm> // std::transform
#include <cassert>   // assert
#include <cctype>    // std::tolower

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

// TODO: Move up and document in a common repository so that
// the CLI understands this as jsonschema.json
auto collection_from_json(const sourcemeta::core::JSON &input)
    -> sourcemeta::registry::Configuration::Collection {
  sourcemeta::registry::Configuration::Collection result;
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

  result.absolute_path = input.at("path").to_string();
  assert(result.absolute_path.is_absolute());

  if (input.defines("base")) {
    result.base =
        sourcemeta::core::URI::canonicalize(input.at("base").to_string());
  } else {
    // Otherwise the base is the directory
    result.base =
        sourcemeta::core::URI::from_path(result.absolute_path).recompose();
  }

  result.default_dialect =
      from_json<decltype(result.default_dialect)::value_type>(
          input.at_or("defaultDialect", JSON{nullptr}));

  if (input.defines("resolve") && input.at("resolve").is_object()) {
    for (const auto &pair : input.at("resolve").as_object()) {
      if (pair.second.is_string()) {
        auto destination{pair.second.to_string()};
        std::ranges::transform(
            destination, destination.begin(), [](const auto character) {
              return static_cast<char>(std::tolower(character));
            });
        result.resolve.emplace(
            pair.first, sourcemeta::core::URI::canonicalize(destination));
      }
    }
  }

  for (const auto &subentry : input.as_object()) {
    if (subentry.first.starts_with("x-") && subentry.second.is_boolean() &&
        subentry.second.to_boolean()) {
      result.attributes.emplace(subentry.first);
    }
  }

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
      result.emplace(location, collection_from_json(input));
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

  result.title = data.at("title").to_string();
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
