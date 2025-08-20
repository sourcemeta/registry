#include <sourcemeta/registry/configuration.h>

#include <algorithm> // std::ranges
#include <cassert>   // assert
#include <iterator>  // std::back_inserter
#include <vector>    // std::vector

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

auto dereference(const std::filesystem::path &base,
                 sourcemeta::core::JSON &input) -> void {
  assert(base.is_absolute());
  if (!input.is_object()) {
    return;

    // Read included files
  } else if (input.defines("include") && input.at("include").is_string()) {
    auto include_path{std::filesystem::weakly_canonical(
        base / input.at("include").to_string())};
    if (std::filesystem::is_directory(include_path)) {
      include_path /= "jsonschema.json";
    }
    input.into(sourcemeta::core::read_json(include_path));
    assert(!input.defines("include"));
    dereference(include_path.parent_path(), input);

    // Revisit and relativize paths
  } else if (input.defines("path") && input.at("path").is_string()) {
    const std::filesystem::path current_path{input.at("path").to_string()};
    const auto absolute_path{std::filesystem::weakly_canonical(
        current_path.is_relative() ? base / current_path : current_path)};
    input.at("path").into(sourcemeta::core::JSON{absolute_path});

    // Recurse on children, if any
  } else if (input.defines("contents") && input.at("contents").is_object()) {
    // TODO: All of this dance because we can't get mutable iterators out of
    // objects
    std::vector<sourcemeta::core::JSON::String> keys;
    std::ranges::transform(input.at("contents").as_object(),
                           std::back_inserter(keys),
                           [](const auto &entry) { return entry.first; });
    for (const auto &key : keys) {
      dereference(base, input.at("contents").at(key));
    }
  }
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
  dereference(path.parent_path(), data);
  return data;
}

} // namespace sourcemeta::registry
