#include <sourcemeta/registry/configuration.h>

#include <cassert> // assert

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

} // namespace

namespace sourcemeta::registry {

auto Configuration::read(const std::filesystem::path &path,
                         const std::filesystem::path &collections)
    -> sourcemeta::core::JSON {
  auto data{sourcemeta::core::read_json(path)};
  preprocess_configuration(collections, path.parent_path(), data);
  data.assign_if_missing("title", sourcemeta::core::JSON{"Sourcemeta"});
  data.assign_if_missing(
      "description",
      sourcemeta::core::JSON{"The next-generation JSON Schema Registry"});
  return data;
}

} // namespace sourcemeta::registry
