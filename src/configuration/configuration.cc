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

  result.assign_if_missing("title", sourcemeta::core::JSON{"Sourcemeta"});
  result.assign_if_missing(
      "description",
      sourcemeta::core::JSON{"The next-generation JSON Schema Registry"});
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
    : base_{path.parent_path()}, data_{sourcemeta::core::read_json(path)} {
  // TODO: Polish this
  preprocess_configuration(collections, this->base_, this->data_);

  if (!this->data_.defines("url")) {
    throw ConfigurationValidationError(path, {},
                                       "Missing 'url' required property");
  }
}

auto Configuration::base() const -> const std::filesystem::path & {
  return this->base_;
}

auto Configuration::url() const -> const sourcemeta::core::JSON::String & {
  assert(this->data_.defines("url"));
  assert(this->data_.at("url").is_string());
  return this->data_.at("url").to_string();
}

auto Configuration::title() const -> const sourcemeta::core::JSON::String & {
  assert(this->data_.defines("title"));
  assert(this->data_.at("title").is_string());
  return this->data_.at("title").to_string();
}

auto Configuration::description() const
    -> const sourcemeta::core::JSON::String & {
  assert(this->data_.defines("description"));
  assert(this->data_.at("description").is_string());
  return this->data_.at("description").to_string();
}

auto Configuration::hero() const
    -> std::optional<sourcemeta::core::JSON::String> {
  if (this->data_.defines("hero")) {
    return this->data_.at("hero").to_string();
  } else {
    return std::nullopt;
  }
}

auto Configuration::head() const
    -> std::optional<sourcemeta::core::JSON::String> {
  if (this->data_.defines("head")) {
    return this->data_.at("head").to_string();
  } else {
    return std::nullopt;
  }
}

auto Configuration::port() const -> sourcemeta::core::JSON::Integer {
  assert(this->data_.defines("port"));
  assert(this->data_.at("port").is_integer());
  return this->data_.at("port").to_integer();
}

auto Configuration::action() const -> std::optional<Action> {
  if (this->data_.defines("action")) {
    return Action{.url = this->data_.at("action").at("url").to_string(),
                  .icon = this->data_.at("action").at("icon").to_string(),
                  .title = this->data_.at("action").at("title").to_string()};
  } else {
    return std::nullopt;
  }
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

auto Configuration::attribute(const std::filesystem::path &path,
                              const sourcemeta::core::JSON::String &name) const
    -> bool {
  return this->data_.at("schemas")
      .at(path)
      .at_or(name, sourcemeta::core::JSON{true})
      .to_boolean();
}

auto Configuration::collection(const std::filesystem::path &path) const
    -> std::optional<Collection> {
  if (this->data_.at("schemas").defines(path)) {
    return Collection{this->base_, path, this->data_.at("schemas").at(path)};
  } else {
    return std::nullopt;
  }
}

auto Configuration::collections() const -> std::vector<Collection> {
  std::vector<Collection> result;
  for (const auto &entry : this->data_.at("schemas").as_object()) {
    result.emplace_back(this->base_, entry.first, entry.second);
  }
  return result;
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
      rebase{parse_rebase(entry)} {}

auto Configuration::Collection::default_identifier(
    const std::filesystem::path &schema_path) const -> std::string {
  return sourcemeta::core::URI{this->base_uri}
      .append_path(std::filesystem::relative(schema_path, this->path).string())
      .canonicalize()
      .recompose();
}

} // namespace sourcemeta::registry
