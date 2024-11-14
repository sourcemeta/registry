#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_INDEX_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_INDEX_H_

#include <sourcemeta/jsontoolkit/json.h>

#include <algorithm>  // std::sort
#include <cstdlib>    // EXIT_SUCCESS
#include <filesystem> // std::filesystem
#include <fstream>    // std::ofstream
#include <iostream>   // std::cerr
#include <utility>    // std::move

static auto trim(const std::string &input) -> std::string {
  auto copy = input;
  copy.erase(copy.find_last_not_of(' ') + 1);
  copy.erase(0, copy.find_first_not_of(' '));
  return copy;
}

namespace sourcemeta::registry::enterprise {

auto generate_toc(const sourcemeta::jsontoolkit::JSON &configuration,
                  const std::filesystem::path &base,
                  const std::filesystem::path &directory) -> void {
  assert(directory.string().starts_with(base.string()));
  auto entries{sourcemeta::jsontoolkit::JSON::make_array()};

  assert(configuration.is_object());
  assert(configuration.defines("collections"));
  assert(configuration.at("collections").is_object());

  for (const auto &entry : std::filesystem::directory_iterator{directory}) {
    auto entry_json{sourcemeta::jsontoolkit::JSON::make_object()};
    entry_json.assign("name",
                      sourcemeta::jsontoolkit::JSON{entry.path().filename()});
    const auto entry_relative_path{
        entry.path().string().substr(base.string().size())};
    if (entry.is_directory()) {
      entry_json.assign("type", sourcemeta::jsontoolkit::JSON{"directory"});
      entry_json.assign("title", sourcemeta::jsontoolkit::JSON{nullptr});
      entry_json.assign("description", sourcemeta::jsontoolkit::JSON{nullptr});
      entry_json.assign(
          "url", sourcemeta::jsontoolkit::JSON{
                     entry.path().string().substr(base.string().size())});

      const auto collection_entry_name{entry_relative_path.substr(1)};
      if (configuration.at("collections").defines(collection_entry_name) &&
          configuration.at("collections")
              .at(collection_entry_name)
              .is_object() &&
          configuration.at("collections")
              .at(collection_entry_name)
              .defines("title") &&
          configuration.at("collections")
              .at(collection_entry_name)
              .at("title")
              .is_string()) {
        entry_json.assign("title", sourcemeta::jsontoolkit::JSON{
                                       configuration.at("collections")
                                           .at(collection_entry_name)
                                           .at("title")
                                           .to_string()});
      }

      if (configuration.at("collections").defines(collection_entry_name) &&
          configuration.at("collections")
              .at(collection_entry_name)
              .is_object() &&
          configuration.at("collections")
              .at(collection_entry_name)
              .defines("description") &&
          configuration.at("collections")
              .at(collection_entry_name)
              .at("description")
              .is_string()) {
        entry_json.assign("description", sourcemeta::jsontoolkit::JSON{
                                             configuration.at("collections")
                                                 .at(collection_entry_name)
                                                 .at("description")
                                                 .to_string()});
      }

      entries.push_back(std::move(entry_json));
    } else if (entry.path().extension() == ".json" &&
               !entry.path().stem().string().starts_with(".")) {
      const auto schema{sourcemeta::jsontoolkit::from_file(entry.path())};
      entry_json.assign("type", sourcemeta::jsontoolkit::JSON{"schema"});
      entry_json.assign("title", sourcemeta::jsontoolkit::JSON{nullptr});
      entry_json.assign("description", sourcemeta::jsontoolkit::JSON{nullptr});
      if (schema.is_object() && schema.defines("title") &&
          schema.at("title").is_string()) {
        entry_json.assign("title", sourcemeta::jsontoolkit::JSON{
                                       trim(schema.at("title").to_string())});
      }

      if (schema.is_object() && schema.defines("description") &&
          schema.at("description").is_string()) {
        entry_json.assign("description",
                          sourcemeta::jsontoolkit::JSON{
                              trim(schema.at("description").to_string())});
      }

      entry_json.assign("url",
                        sourcemeta::jsontoolkit::JSON{entry_relative_path});

      entries.push_back(std::move(entry_json));
    }
  }

  std::sort(entries.as_array().begin(), entries.as_array().end(),
            [](const auto &left, const auto &right) {
              if (left.at("type") == right.at("type")) {
                return left.at("name") < right.at("name");
              }

              return left.at("type") < right.at("type");
            });

  auto result{sourcemeta::jsontoolkit::JSON::make_object()};
  result.assign("entries", std::move(entries));

  // Precompute the breadcrumb
  const std::filesystem::path relative_path{directory.string().substr(
      std::min(base.string().size() + 1, directory.string().size()))};
  result.assign("breadcrumb", sourcemeta::jsontoolkit::JSON::make_array());
  std::filesystem::path current_path{"/"};
  for (const auto &part : relative_path) {
    current_path = current_path / part;
    auto breadcrumb_entry{sourcemeta::jsontoolkit::JSON::make_object()};
    breadcrumb_entry.assign("name", sourcemeta::jsontoolkit::JSON{part});
    breadcrumb_entry.assign("url", sourcemeta::jsontoolkit::JSON{current_path});
    result.at("breadcrumb").push_back(std::move(breadcrumb_entry));
  }

  const auto meta_path{directory / ".meta.json"};
  std::cerr << "Saving into: " << meta_path.string() << "\n";
  std::ofstream stream{meta_path};
  assert(!stream.fail());
  sourcemeta::jsontoolkit::prettify(result, stream);
  stream << "\n";
  stream.close();
}

auto attach(const sourcemeta::jsontoolkit::JSON &configuration,
            const std::filesystem::path &, const std::filesystem::path &output)
    -> int {
  std::cerr << "-- Indexing directory: " << output.string() << "\n";
  const auto base{std::filesystem::canonical(output / "schemas")};
  generate_toc(configuration, base, base);

  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{output / "schemas"}) {
    if (!entry.is_directory()) {
      continue;
    }

    std::cerr << "-- Processing: " << entry.path().string() << "\n";
    generate_toc(configuration, base, std::filesystem::canonical(entry.path()));
  }

  return EXIT_SUCCESS;
}

} // namespace sourcemeta::registry::enterprise

#endif
