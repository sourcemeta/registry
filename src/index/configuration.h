#ifndef SOURCEMETA_REGISTRY_INDEX_CONFIGURATION_H_
#define SOURCEMETA_REGISTRY_INDEX_CONFIGURATION_H_

#include <sourcemeta/core/json.h>

#include <cassert>    // assert
#include <filesystem> // std::filesystem

namespace sourcemeta::registry {

// TODO: Allow the configuration to read collection entries from separate files
auto preprocess_configuration(
    const std::filesystem::path &collections_directory,
    const std::filesystem::path &directory,
    const sourcemeta::core::JSON &schema, sourcemeta::core::JSON &configuration)
    -> void {
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
                               extension_path.parent_path(), schema,
                               extension_json);

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

  result.assign_if_missing("title",
                           schema.at("properties").at("title").at("default"));
  result.assign_if_missing(
      "description", schema.at("properties").at("description").at("default"));
  result.merge(configuration.as_object());
  configuration = std::move(result);
}

} // namespace sourcemeta::registry

#endif
