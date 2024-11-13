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

auto generate_toc(const std::filesystem::path &directory) -> void {
  auto entries{sourcemeta::jsontoolkit::JSON::make_array()};

  for (const auto &entry : std::filesystem::directory_iterator{directory}) {
    auto entry_json{sourcemeta::jsontoolkit::JSON::make_object()};
    entry_json.assign("name",
                      sourcemeta::jsontoolkit::JSON{entry.path().stem()});
    if (entry.is_directory()) {
      entry_json.assign("type", sourcemeta::jsontoolkit::JSON{"directory"});
      // TODO: Read these from "pages" in the configuration
      entry_json.assign("title", sourcemeta::jsontoolkit::JSON{nullptr});
      entry_json.assign("description", sourcemeta::jsontoolkit::JSON{nullptr});
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

      if (!entry_json.defines("title")) {
        entry_json.assign("title", sourcemeta::jsontoolkit::JSON{nullptr});
      }

      if (!entry_json.defines("description")) {
        entry_json.assign("description",
                          sourcemeta::jsontoolkit::JSON{nullptr});
      }

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

  const auto meta_path{directory / ".meta.json"};
  std::cerr << "Saving into: " << meta_path.string() << "\n";
  std::ofstream stream{meta_path};
  assert(!stream.fail());
  sourcemeta::jsontoolkit::prettify(result, stream);
  stream << "\n";
  stream.close();
}

auto attach(const sourcemeta::jsontoolkit::JSON &,
            const std::filesystem::path &, const std::filesystem::path &output)
    -> int {
  std::cerr << "-- Indexing directory: " << output.string() << "\n";
  generate_toc(output / "schemas");

  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{output / "schemas"}) {
    if (!entry.is_directory()) {
      continue;
    }

    std::cerr << "-- Processing: " << entry.path().string() << "\n";
    generate_toc(entry.path());
  }

  return EXIT_SUCCESS;
}

} // namespace sourcemeta::registry::enterprise

#endif
