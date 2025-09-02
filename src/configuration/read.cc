#include <sourcemeta/registry/configuration.h>

#include <algorithm> // std::ranges
#include <cassert>   // assert
#include <iterator>  // std::back_inserter
#include <utility>   // std::move
#include <vector>    // std::vector

namespace {

auto resolve_path(const std::filesystem::path &base,
                  const std::filesystem::path &rpath,
                  const std::filesystem::path &value) -> std::filesystem::path {
  if (value.is_absolute()) {
    return std::filesystem::weakly_canonical(value);
  } else if (value.string().starts_with("@")) {
    return std::filesystem::weakly_canonical(rpath / value.string().substr(1));
  } else {
    return std::filesystem::weakly_canonical(base / value);
  }
}

auto maybe_suffix(const std::filesystem::path &path,
                  const std::filesystem::path &suffix)
    -> std::filesystem::path {
  if (std::filesystem::is_regular_file(path) || path.extension() == ".json") {
    return path;
  } else {
    return path / suffix;
  }
}

auto dereference(const std::filesystem::path &collections_path,
                 const std::filesystem::path &base,
                 sourcemeta::core::JSON &input) -> void {
  assert(base.is_absolute());
  if (!input.is_object()) {
    return;

    // Read extensions
  } else if (input.defines("extends") && input.at("extends").is_array()) {
    auto accumulator{sourcemeta::core::JSON::make_object()};
    for (const auto &entry : input.at("extends").as_array()) {
      if (entry.is_string()) {
        const auto target_path{maybe_suffix(
            resolve_path(base, collections_path, entry.to_string()),
            "registry.json")};
        auto extension{sourcemeta::core::read_json(target_path)};
        if (extension.is_object()) {
          dereference(collections_path, target_path.parent_path(), extension);
          accumulator.merge(std::move(extension).as_object());
        }
      }
    }

    input.erase("extends");
    accumulator.merge(input.as_object());
    input = std::move(accumulator);
    assert(!input.defines("extends"));
    dereference(collections_path, base, input);

    // Read included files
  } else if (input.defines("include") && input.at("include").is_string()) {
    const auto target_path{maybe_suffix(
        resolve_path(base, collections_path, input.at("include").to_string()),
        "jsonschema.json")};
    input.into(sourcemeta::core::read_json(target_path));
    assert(!input.defines("include"));
    dereference(collections_path, target_path.parent_path(), input);

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
      dereference(collections_path, base, input.at("contents").at(key));
    }
  }
}

} // namespace

namespace sourcemeta::registry {

auto Configuration::read(const std::filesystem::path &configuration_path,
                         const std::filesystem::path &collections_path)
    -> sourcemeta::core::JSON {
  auto data{sourcemeta::core::read_json(configuration_path)};

  if (data.is_object() && data.defines("html") &&
      data.at("html").is_boolean() && data.at("html").to_boolean()) {
    data.at("html").into_object();
  } else if (!data.defines("html")) {
    data.assign("html", sourcemeta::core::JSON::make_object());
  }

  if (data.is_object() && data.defines("html") && data.at("html").is_object()) {
    data.at("html").assign_if_missing("name",
                                      sourcemeta::core::JSON{"Sourcemeta"});
    data.at("html").assign_if_missing(
        "description",
        sourcemeta::core::JSON{"The next-generation JSON Schema Registry"});
  }

  dereference(collections_path, configuration_path.parent_path(), data);
  return data;
}

} // namespace sourcemeta::registry
