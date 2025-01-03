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
                  const std::filesystem::path &directory,
                  sourcemeta::jsontoolkit::JSON &search_index) -> void {
  assert(directory.string().starts_with(base.string()));
  auto entries{sourcemeta::jsontoolkit::JSON::make_array()};

  for (const auto &entry : std::filesystem::directory_iterator{directory}) {
    auto entry_json{sourcemeta::jsontoolkit::JSON::make_object()};
    entry_json.assign("name",
                      sourcemeta::jsontoolkit::JSON{entry.path().filename()});
    const auto entry_relative_path{
        entry.path().string().substr(base.string().size())};
    if (entry.is_directory()) {
      const auto collection_entry_name{entry_relative_path.substr(1)};
      if (configuration.defines("pages") &&
          configuration.at("pages").defines(collection_entry_name)) {
        for (const auto &page_entry :
             configuration.at("pages").at(collection_entry_name).as_object()) {
          entry_json.assign(page_entry.first, page_entry.second);
        }
      }

      entry_json.assign("type", sourcemeta::jsontoolkit::JSON{"directory"});
      entry_json.assign(
          "url", sourcemeta::jsontoolkit::JSON{
                     entry.path().string().substr(base.string().size())});

      entries.push_back(std::move(entry_json));
    } else if (entry.path().extension() == ".json" &&
               !entry.path().stem().string().starts_with(".")) {
      const auto schema{sourcemeta::jsontoolkit::from_file(entry.path())};
      entry_json.assign("type", sourcemeta::jsontoolkit::JSON{"schema"});
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

      // Collect schemas high-level metadata for searching purposes
      auto search_entry{sourcemeta::jsontoolkit::JSON::make_object()};
      search_entry.assign("url", entry_json.at("url"));
      search_entry.assign("title", entry_json.defines("title")
                                       ? entry_json.at("title")
                                       : sourcemeta::jsontoolkit::JSON{""});
      search_entry.assign("description",
                          entry_json.defines("description")
                              ? entry_json.at("description")
                              : sourcemeta::jsontoolkit::JSON{""});
      search_index.push_back(std::move(search_entry));

      entries.push_back(std::move(entry_json));
    }
  }

  std::sort(entries.as_array().begin(), entries.as_array().end(),
            [](const auto &left, const auto &right) {
              if (left.at("type") == right.at("type")) {
                return left.at("name") > right.at("name");
              }

              return left.at("type") < right.at("type");
            });

  auto result{sourcemeta::jsontoolkit::JSON::make_object()};
  const auto page_entry_name{
      std::filesystem::relative(directory, base).string()};

  // Precompute page metadata
  if (configuration.defines("pages") &&
      configuration.at("pages").defines(page_entry_name)) {
    for (const auto &entry :
         configuration.at("pages").at(page_entry_name).as_object()) {
      result.assign(entry.first, entry.second);
    }
  }

  // Store entries
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

  const auto index_path{base.parent_path() / "generated" /
                        std::filesystem::relative(directory, base) /
                        "index.json"};
  std::cerr << "Saving into: " << index_path.string() << "\n";
  std::filesystem::create_directories(index_path.parent_path());
  std::ofstream stream{index_path};
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
  auto search_index{sourcemeta::jsontoolkit::JSON::make_array()};
  generate_toc(configuration, base, base, search_index);

  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{output / "schemas"}) {
    if (!entry.is_directory()) {
      continue;
    }

    std::cerr << "-- Processing: " << entry.path().string() << "\n";
    generate_toc(configuration, base, std::filesystem::canonical(entry.path()),
                 search_index);
  }

  std::ofstream stream{output / "search.json"};
  assert(!stream.fail());
  sourcemeta::jsontoolkit::prettify(search_index, stream);
  stream << "\n";
  stream.close();

  return EXIT_SUCCESS;
}

} // namespace sourcemeta::registry::enterprise

#endif
