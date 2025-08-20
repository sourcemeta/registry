#include <sourcemeta/registry/configuration.h>

#include <sourcemeta/core/uri.h>

#include <algorithm> // std::transform
#include <cassert>   // assert
#include <cctype>    // std::tolower

namespace {

auto to_lowercase(const std::string_view input) -> std::string {
  std::string result{input};
  std::ranges::transform(result, result.begin(), [](const auto character) {
    return static_cast<char>(std::tolower(character));
  });
  return result;
}

// TODO: Allow the configuration to read collection entries from separate files
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

      if (extension_json.defines("schemas")) {
        for (auto &schemas : extension_json.at("schemas").as_object()) {
          if (schemas.second.defines("path") &&
              schemas.second.at("path").is_string()) {
            std::filesystem::path schemas_path{
                schemas.second.at("path").to_string()};
            if (schemas_path.is_relative()) {
              // TODO: All object iterators are `const` so we can't directly
              // modify the value
              extension_json.at("schemas")
                  .at(schemas.first)
                  .assign("path",
                          sourcemeta::core::JSON{extension_path.parent_path() /
                                                 schemas_path});
            }
          }
        }
      }

      result.merge(extension_json.as_object());
    }
  }

  result.merge(configuration.as_object());
  configuration = std::move(result);
}

} // namespace

namespace sourcemeta::registry {

// TODO: Try to use sourcemeta::core::from_json as much as possible
auto Configuration::parse(const std::filesystem::path &path,
                          const std::filesystem::path &collections)
    -> Configuration {
  Configuration result;
  // TODO: Move as much data as possible out of this object
  auto data{sourcemeta::core::read_json(path)};
  // TODO: Polish this
  preprocess_configuration(collections, path.parent_path(), data);

  data.assign_if_missing("title", sourcemeta::core::JSON{"Sourcemeta"});
  data.assign_if_missing(
      "description",
      sourcemeta::core::JSON{"The next-generation JSON Schema Registry"});

#define VALIDATE(condition, pointer, error)                                    \
  if (!(condition)) {                                                          \
    throw ConfigurationValidationError(                                        \
        path, sourcemeta::core::Pointer(pointer), (error));                    \
  }

  VALIDATE(data.defines("url"), {}, "Missing 'url' required property");
  VALIDATE(data.at("url").is_string(), {"url"},
           "The 'url' property must be a string");
  result.url = sourcemeta::core::URI{data.at("url").to_string()}
                   .canonicalize()
                   .recompose();

  VALIDATE(data.defines("title"), {}, "Missing 'title' required property");
  VALIDATE(data.at("title").is_string(), {"title"},
           "The 'title' property must be a string");
  result.title = data.at("title").to_string();

  VALIDATE(data.defines("description"), {},
           "Missing 'description' required property");
  VALIDATE(data.at("description").is_string(), {"description"},
           "The 'description' property must be a string");
  result.description = data.at("description").to_string();

  VALIDATE(data.defines("port"), {}, "Missing 'port' required property");
  VALIDATE(data.at("port").is_integer(), {"port"},
           "The 'description' property must be an integer");
  VALIDATE(data.at("port").is_positive(), {"port"},
           "The 'description' property must be a positive integer");
  result.port = data.at("port").to_integer();

  if (data.defines("hero")) {
    VALIDATE(data.at("hero").is_string(), {"hero"},
             "The 'hero' property must be a string");
    result.hero = data.at("hero").to_string();
  }

  if (data.defines("head")) {
    VALIDATE(data.at("head").is_string(), {"head"},
             "The 'head' property must be a string");
    result.head = data.at("head").to_string();
  }

  if (data.defines("action")) {
    VALIDATE(data.at("action").is_object(), {},
             "The 'action' property must be an object");
    VALIDATE(data.at("action").defines("url"), {},
             "The 'action' property must define a 'url' property");
    VALIDATE(data.at("action").defines("icon"), {},
             "The 'action' property must define a 'icon' property");
    VALIDATE(data.at("action").defines("title"), {},
             "The 'action' property must define a 'title' property");
    VALIDATE(data.at("action").at("url").is_string(),
             sourcemeta::core::Pointer({"action", "url"}),
             "The 'action/url' property must be a string");
    VALIDATE(data.at("action").at("icon").is_string(),
             sourcemeta::core::Pointer({"action", "icon"}),
             "The 'action/icon' property must be a string");
    VALIDATE(data.at("action").at("title").is_string(),
             sourcemeta::core::Pointer({"action", "title"}),
             "The 'action/title' property must be a string");
    result.action = {.url = data.at("action").at("url").to_string(),
                     .icon = data.at("action").at("icon").to_string(),
                     .title = data.at("action").at("title").to_string()};
  }

  VALIDATE(data.defines("schemas"), {}, "Missing 'schemas' required property");
  VALIDATE(data.at("schemas").is_object(), {"schemas"},
           "The 'schemas' property must be an object");
  for (const auto &entry : data.at("schemas").as_object()) {
    if (entry.second.defines("path")) {
      Collection collection;

      if (entry.second.defines("title")) {
        VALIDATE(entry.second.at("title").is_string(),
                 sourcemeta::core::Pointer({"schemas", entry.first, "title"}),
                 "The 'title' property must be a string");
        collection.title = entry.second.at("title").to_string();
      }

      if (entry.second.defines("description")) {
        VALIDATE(
            entry.second.at("description").is_string(),
            sourcemeta::core::Pointer({"schemas", entry.first, "description"}),
            "The 'description' property must be a string");
        collection.description = entry.second.at("description").to_string();
      }

      if (entry.second.defines("email")) {
        VALIDATE(entry.second.at("email").is_string(),
                 sourcemeta::core::Pointer({"schemas", entry.first, "email"}),
                 "The 'email' property must be a string");
        collection.email = entry.second.at("email").to_string();
      }

      if (entry.second.defines("github")) {
        VALIDATE(entry.second.at("github").is_string(),
                 sourcemeta::core::Pointer({"schemas", entry.first, "github"}),
                 "The 'github' property must be a string");
        collection.github = entry.second.at("github").to_string();
      }

      if (entry.second.defines("website")) {
        VALIDATE(entry.second.at("website").is_string(),
                 sourcemeta::core::Pointer({"schemas", entry.first, "website"}),
                 "The 'website' property must be a string");
        collection.website = entry.second.at("website").to_string();
      }

      // TODO: Add more validation macros for this
      collection.absolute_path = std::filesystem::weakly_canonical(
          path.parent_path() / entry.second.at("path").to_string());
      assert(collection.absolute_path.is_absolute());
      collection.base = entry.second.at("base").to_string();
      collection.default_dialect =
          entry.second.defines("defaultDialect")
              ? entry.second.at("defaultDialect").to_string()
              : static_cast<std::optional<sourcemeta::core::JSON::String>>(
                    std::nullopt);

      if (entry.second.defines("resolve")) {
        for (const auto &pair : entry.second.at("resolve").as_object()) {
          collection.resolve.emplace(
              pair.first, sourcemeta::core::URI::canonicalize(
                              to_lowercase(pair.second.to_string())));
        }
      }

      for (const auto &subentry : entry.second.as_object()) {
        if (subentry.first.starts_with("x-") && subentry.second.is_boolean() &&
            subentry.second.to_boolean()) {
          collection.attributes.emplace(subentry.first);
        }
      }

      result.entries.emplace(entry.first, std::move(collection));
    } else {
      Page page;

      if (entry.second.defines("title")) {
        VALIDATE(entry.second.at("title").is_string(),
                 sourcemeta::core::Pointer({"schemas", entry.first, "title"}),
                 "The 'title' property must be a string");
        page.title = entry.second.at("title").to_string();
      }

      if (entry.second.defines("description")) {
        VALIDATE(
            entry.second.at("description").is_string(),
            sourcemeta::core::Pointer({"schemas", entry.first, "description"}),
            "The 'description' property must be a string");
        page.description = entry.second.at("description").to_string();
      }

      if (entry.second.defines("email")) {
        VALIDATE(entry.second.at("email").is_string(),
                 sourcemeta::core::Pointer({"schemas", entry.first, "email"}),
                 "The 'email' property must be a string");
        page.email = entry.second.at("email").to_string();
      }

      if (entry.second.defines("github")) {
        VALIDATE(entry.second.at("github").is_string(),
                 sourcemeta::core::Pointer({"schemas", entry.first, "github"}),
                 "The 'github' property must be a string");
        page.github = entry.second.at("github").to_string();
      }

      if (entry.second.defines("website")) {
        VALIDATE(entry.second.at("website").is_string(),
                 sourcemeta::core::Pointer({"schemas", entry.first, "website"}),
                 "The 'website' property must be a string");
        page.website = entry.second.at("website").to_string();
      }

      result.entries.emplace(entry.first, std::move(page));
    }
  }

#undef VALIDATE
  return result;
}

} // namespace sourcemeta::registry
