#include <sourcemeta/registry/configuration.h>

#include <cassert> // assert

namespace {

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

// TODO: We should be able to use `sourcemeta::core::from_json` here
auto parse_rebase(const sourcemeta::core::JSON &entry)
    -> std::vector<std::pair<sourcemeta::core::URI, sourcemeta::core::URI>> {
  std::vector<std::pair<sourcemeta::core::URI, sourcemeta::core::URI>> result;
  if (entry.defines("rebase")) {
    for (const auto &pair : entry.at("rebase").as_array()) {
      result.emplace_back(
          sourcemeta::core::URI{pair.at("from").to_string()}.canonicalize(),
          sourcemeta::core::URI{pair.at("to").to_string()}.canonicalize());
    }
  }

  return result;
}
} // namespace

namespace sourcemeta::registry {

// TODO: Try to use sourcemeta::core::from_json as much as possible

Configuration::Configuration(const std::filesystem::path &path,
                             const std::filesystem::path &collections)
    : data_{sourcemeta::core::read_json(path)} {
  // TODO: Polish this
  preprocess_configuration(collections, path.parent_path(), this->data_);

  this->data_.assign_if_missing("title", sourcemeta::core::JSON{"Sourcemeta"});
  this->data_.assign_if_missing(
      "description",
      sourcemeta::core::JSON{"The next-generation JSON Schema Registry"});

#define VALIDATE(condition, pointer, error)                                    \
  if (!(condition)) {                                                          \
    throw ConfigurationValidationError(                                        \
        path, sourcemeta::core::Pointer(pointer), (error));                    \
  }

  VALIDATE(this->data_.defines("url"), {}, "Missing 'url' required property");
  VALIDATE(this->data_.at("url").is_string(), {"url"},
           "The 'url' property must be a string");
  this->url = sourcemeta::core::URI{this->data_.at("url").to_string()}
                  .canonicalize()
                  .recompose();

  VALIDATE(this->data_.defines("title"), {},
           "Missing 'title' required property");
  VALIDATE(this->data_.at("title").is_string(), {"title"},
           "The 'title' property must be a string");
  this->title = this->data_.at("title").to_string();

  VALIDATE(this->data_.defines("description"), {},
           "Missing 'description' required property");
  VALIDATE(this->data_.at("description").is_string(), {"description"},
           "The 'description' property must be a string");
  this->description = this->data_.at("description").to_string();

  VALIDATE(this->data_.defines("port"), {}, "Missing 'port' required property");
  VALIDATE(this->data_.at("port").is_integer(), {"port"},
           "The 'description' property must be an integer");
  VALIDATE(this->data_.at("port").is_positive(), {"port"},
           "The 'description' property must be a positive integer");
  this->port = this->data_.at("port").to_integer();

  if (this->data_.defines("hero")) {
    VALIDATE(this->data_.at("hero").is_string(), {"hero"},
             "The 'hero' property must be a string");
    this->hero = this->data_.at("hero").to_string();
  }

  if (this->data_.defines("head")) {
    VALIDATE(this->data_.at("head").is_string(), {"head"},
             "The 'head' property must be a string");
    this->hero = this->data_.at("head").to_string();
  }

  if (this->data_.defines("action")) {
    VALIDATE(this->data_.at("action").is_object(), {},
             "The 'action' property must be an object");
    VALIDATE(this->data_.at("action").defines("url"), {},
             "The 'action' property must define a 'url' property");
    VALIDATE(this->data_.at("action").defines("icon"), {},
             "The 'action' property must define a 'icon' property");
    VALIDATE(this->data_.at("action").defines("title"), {},
             "The 'action' property must define a 'title' property");
    VALIDATE(this->data_.at("action").at("url").is_string(),
             sourcemeta::core::Pointer({"action", "url"}),
             "The 'action/url' property must be a string");
    VALIDATE(this->data_.at("action").at("icon").is_string(),
             sourcemeta::core::Pointer({"action", "icon"}),
             "The 'action/icon' property must be a string");
    VALIDATE(this->data_.at("action").at("title").is_string(),
             sourcemeta::core::Pointer({"action", "title"}),
             "The 'action/title' property must be a string");
    this->action = {.url = this->data_.at("action").at("url").to_string(),
                    .icon = this->data_.at("action").at("icon").to_string(),
                    .title = this->data_.at("action").at("title").to_string()};
  }

  VALIDATE(this->data_.defines("schemas"), {},
           "Missing 'schemas' required property");
  VALIDATE(this->data_.at("schemas").is_object(), {"schemas"},
           "The 'schemas' property must be an object");
  for (const auto &entry : this->data_.at("schemas").as_object()) {
    this->entries.emplace(
        entry.first,
        // TODO: Parse collections right here
        Collection{path.parent_path(), entry.first, entry.second});
  }

#undef VALIDATE
}

auto Configuration::inflate(const std::filesystem::path &path,
                            sourcemeta::core::JSON &target) const -> void {
  assert(path.is_relative());
  if (!this->data_.defines("pages") || !this->data_.at("pages").defines(path)) {
    return;
  }

  if (this->data_.at("pages").at(path).defines("title")) {
    target.assign_if_missing("title",
                             this->data_.at("pages").at(path).at("title"));
  }

  if (this->data_.at("pages").at(path).defines("description")) {
    target.assign_if_missing(
        "description", this->data_.at("pages").at(path).at("description"));
  }

  if (this->data_.at("pages").at(path).defines("email")) {
    target.assign_if_missing("email",
                             this->data_.at("pages").at(path).at("email"));
  }

  if (this->data_.at("pages").at(path).defines("github")) {
    target.assign_if_missing("github",
                             this->data_.at("pages").at(path).at("github"));
  }

  if (this->data_.at("pages").at(path).defines("website")) {
    target.assign_if_missing("website",
                             this->data_.at("pages").at(path).at("website"));
  }
}

Configuration::Collection::Collection(const std::filesystem::path &base_path,
                                      sourcemeta::core::JSON::String entry_name,
                                      const sourcemeta::core::JSON &entry)
    : path{std::filesystem::canonical(base_path /
                                      entry.at("path").to_string())},
      name{std::move(entry_name)},
      base_uri{
          sourcemeta::core::URI{entry.at("base").to_string()}.canonicalize()},
      default_dialect{
          entry.defines("defaultDialect")
              ? entry.at("defaultDialect").to_string()
              : static_cast<std::optional<sourcemeta::core::JSON::String>>(
                    std::nullopt)},
      rebase{parse_rebase(entry)},
      blaze_exhaustive{entry
                           .at_or("x-sourcemeta-registry:blaze-exhaustive",
                                  sourcemeta::core::JSON{true})
                           .to_boolean()} {}

auto Configuration::Collection::default_identifier(
    const std::filesystem::path &schema_path) const -> std::string {
  return sourcemeta::core::URI{this->base_uri}
      .append_path(std::filesystem::relative(schema_path, this->path).string())
      .canonicalize()
      .recompose();
}

} // namespace sourcemeta::registry
