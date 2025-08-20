#include <sourcemeta/registry/configuration.h>

#include <sourcemeta/core/uri.h>

#include <algorithm> // std::transform
#include <cassert>   // assert
#include <cctype>    // std::tolower

namespace {

auto fix_paths(const std::filesystem::path &extension_path,
               sourcemeta::core::JSON &extension_json) -> void {
  if (extension_json.defines("contents")) {
    for (auto &contents : extension_json.at("contents").as_object()) {
      if (contents.second.defines("contents")) {
        for (auto &entry : contents.second.at("contents").as_object()) {
          if (entry.second.defines("path") &&
              entry.second.at("path").is_string()) {
            std::filesystem::path schemas_path{
                entry.second.at("path").to_string()};
            if (schemas_path.is_relative()) {
              // TODO: All object iterators are `const` so we can't directly
              // modify the value
              extension_json.at("contents")
                  .at(contents.first)
                  .at("contents")
                  .at(entry.first)
                  .assign("path",
                          sourcemeta::core::JSON{extension_path.parent_path() /
                                                 schemas_path});
            }
          }
        }
      }
    }
  }
}

// TODO: Allow the configuration to read collection entries from separate files
// TODO: Polish this
auto preprocess_configuration(
    const std::filesystem::path &collections_directory,
    const std::filesystem::path &directory,
    sourcemeta::core::JSON &configuration) -> void {
  assert(collections_directory.is_absolute());
  assert(configuration.is_object());
  auto result{sourcemeta::core::JSON::make_object()};
  if (configuration.defines("extends")) {
    for (const auto &extension : configuration.at("extends").as_array()) {
      std::filesystem::path extension_path{extension.to_string()};
      if (extension_path.is_relative() &&
          extension_path.string().starts_with("@")) {
        extension_path = collections_directory /
                         extension_path.string().substr(1) / "registry.json";
      } else {
        extension_path = directory / extension_path / "registry.json";
      }

      auto extension_json{sourcemeta::core::read_json(extension_path)};
      // To handle recursive requirements
      preprocess_configuration(collections_directory,
                               extension_path.parent_path(), extension_json);
      fix_paths(extension_path, extension_json);
      result.merge(extension_json.as_object());
    }
  }

  result.merge(configuration.as_object());
  configuration = std::move(result);
}

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

// TODO: Try to use sourcemeta::core::from_json as much as possible
auto Configuration::parse(const std::filesystem::path &path,
                          const std::filesystem::path &collections)
    -> Configuration {
#define VALIDATE(condition, path, pointer, error)                              \
  if (!(condition)) {                                                          \
    throw sourcemeta::registry::ConfigurationValidationError(                  \
        path, sourcemeta::core::Pointer(pointer), (error));                    \
  }

  Configuration result;
  auto data{sourcemeta::core::read_json(path)};
  preprocess_configuration(collections, path.parent_path(), data);

  data.assign_if_missing("title", sourcemeta::core::JSON{"Sourcemeta"});
  data.assign_if_missing(
      "description",
      sourcemeta::core::JSON{"The next-generation JSON Schema Registry"});

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
    VALIDATE(data.at("hero").is_string(), path, {"hero"},
             "The 'hero' property must be a string");
    result.hero = data.at("hero").to_string();
  }

  if (data.defines("head")) {
    VALIDATE(data.at("head").is_string(), path, {"head"},
             "The 'head' property must be a string");
    result.head = data.at("head").to_string();
  }

  if (data.defines("action")) {
    VALIDATE(data.at("action").is_object(), path, {},
             "The 'action' property must be an object");
    VALIDATE(data.at("action").defines("url"), path, {},
             "The 'action' property must define a 'url' property");
    VALIDATE(data.at("action").defines("icon"), path, {},
             "The 'action' property must define a 'icon' property");
    VALIDATE(data.at("action").defines("title"), path, {},
             "The 'action' property must define a 'title' property");
    VALIDATE(data.at("action").at("url").is_string(), path,
             sourcemeta::core::Pointer({"action", "url"}),
             "The 'action/url' property must be a string");
    VALIDATE(data.at("action").at("icon").is_string(), path,
             sourcemeta::core::Pointer({"action", "icon"}),
             "The 'action/icon' property must be a string");
    VALIDATE(data.at("action").at("title").is_string(), path,
             sourcemeta::core::Pointer({"action", "title"}),
             "The 'action/title' property must be a string");
    result.action = {.url = data.at("action").at("url").to_string(),
                     .icon = data.at("action").at("icon").to_string(),
                     .title = data.at("action").at("title").to_string()};
  }

  entries_from_json(result.entries, path, "", data);

  return result;
#undef VALIDATE
}

} // namespace sourcemeta::registry
