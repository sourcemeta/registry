#include <sourcemeta/registry/configuration.h>

#include <sourcemeta/core/uri.h>

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

auto collection_from_json(const std::filesystem::path &path,
                          const sourcemeta::core::JSON &input)
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

  // TODO: Add more validation macros for this
  result.absolute_path = std::filesystem::weakly_canonical(
      path.parent_path() / input.at("path").to_string());
  assert(result.absolute_path.is_absolute());

  result.base = from_json<decltype(result.base)::value_type>(
      input.at_or("base", JSON{nullptr}));
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
auto entries_from_json(T &result,
                       const std::filesystem::path &configuration_path,
                       const std::filesystem::path &location,
                       const sourcemeta::core::JSON &input) -> void {
  if (!input.defines("url")) {
    assert(!result.contains(location));
    if (input.defines("path")) {
      result.emplace(location, collection_from_json(configuration_path, input));
    } else {
      result.emplace(location, page_from_json(input));
    }
  }

  if (input.defines("contents")) {
    for (const auto &entry : input.at("contents").as_object()) {
      entries_from_json<T>(result, configuration_path, location / entry.first,
                           entry.second);
    }
  }
}

} // namespace

namespace sourcemeta::registry {

auto Configuration::parse(const std::filesystem::path &path,
                          const sourcemeta::core::JSON &data) -> Configuration {
#define VALIDATE(condition, path, pointer, error)                              \
  if (!(condition)) {                                                          \
    throw sourcemeta::registry::ConfigurationValidationError(                  \
        path, sourcemeta::core::Pointer(pointer), (error));                    \
  }

  Configuration result;
  VALIDATE(data.defines("url"), path, {}, "Missing 'url' required property");
  VALIDATE(data.at("url").is_string(), path, {"url"},
           "The 'url' property must be a string");
  result.url = sourcemeta::core::URI{data.at("url").to_string()}
                   .canonicalize()
                   .recompose();

  VALIDATE(data.defines("title"), path, {},
           "Missing 'title' required property");
  VALIDATE(data.at("title").is_string(), path, {"title"},
           "The 'title' property must be a string");
  result.title = data.at("title").to_string();

  VALIDATE(data.defines("description"), path, {},
           "Missing 'description' required property");
  VALIDATE(data.at("description").is_string(), path, {"description"},
           "The 'description' property must be a string");
  result.description = data.at("description").to_string();

  VALIDATE(data.defines("port"), path, {}, "Missing 'port' required property");
  VALIDATE(data.at("port").is_integer(), path, {"port"},
           "The 'description' property must be an integer");
  VALIDATE(data.at("port").is_positive(), path, {"port"},
           "The 'description' property must be a positive integer");
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

  entries_from_json(result.entries, path, "", data);

  return result;
#undef VALIDATE
}

} // namespace sourcemeta::registry
