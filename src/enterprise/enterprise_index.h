#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_INDEX_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_INDEX_H_

#include <sourcemeta/jsontoolkit/json.h>

#include "enterprise_html.h"

#include <algorithm>  // std::sort
#include <cassert>    // assert
#include <cstdlib>    // EXIT_SUCCESS
#include <filesystem> // std::filesystem
#include <fstream>    // std::ofstream
#include <iostream>   // std::cerr
#include <utility>    // std::move

// TODO: Elevate to JSON Toolkit as a JSON string method
static auto trim(const std::string &input) -> std::string {
  auto copy = input;
  copy.erase(copy.find_last_not_of(' ') + 1);
  copy.erase(0, copy.find_first_not_of(' '));
  return copy;
}

static auto base_dialect_id(const std::string &base_dialect) -> std::string {
  if (base_dialect == "https://json-schema.org/draft/2020-12/schema" ||
      base_dialect == "https://json-schema.org/draft/2020-12/hyper-schema") {
    return "2020-12";
  }

  if (base_dialect == "https://json-schema.org/draft/2019-09/schema" ||
      base_dialect == "https://json-schema.org/draft/2019-09/hyper-schema") {
    return "2019-09";
  }

  if (base_dialect == "http://json-schema.org/draft-07/schema#" ||
      base_dialect == "http://json-schema.org/draft-07/hyper-schema#") {
    return "draft7";
  }

  if (base_dialect == "http://json-schema.org/draft-06/schema#" ||
      base_dialect == "http://json-schema.org/draft-06/hyper-schema#") {
    return "draft6";
  }

  if (base_dialect == "http://json-schema.org/draft-04/schema#" ||
      base_dialect == "http://json-schema.org/draft-04/hyper-schema#") {
    return "draft4";
  }

  if (base_dialect == "http://json-schema.org/draft-03/schema#" ||
      base_dialect == "http://json-schema.org/draft-03/hyper-schema#") {
    return "draft3";
  }

  if (base_dialect == "http://json-schema.org/draft-02/hyper-schema#") {
    return "draft2";
  }

  if (base_dialect == "http://json-schema.org/draft-01/hyper-schema#") {
    return "draft1";
  }

  if (base_dialect == "http://json-schema.org/draft-00/hyper-schema#") {
    return "draft0";
  }

  // We should never get here
  assert(false);
  return "Unknown";
}

namespace sourcemeta::registry::enterprise {

auto generate_toc(
    const sourcemeta::jsontoolkit::FlatFileSchemaResolver &resolver,
    const sourcemeta::jsontoolkit::URI &server_url,
    const sourcemeta::jsontoolkit::JSON &configuration,
    const std::filesystem::path &base, const std::filesystem::path &directory,
    sourcemeta::jsontoolkit::JSON &search_index) -> void {
  const auto server_url_string{server_url.recompose()};
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

      // Calculate base dialect
      std::ostringstream absolute_schema_url;
      absolute_schema_url << server_url_string;

      // TODO: We should have better utilities to avoid these
      // URL concatenation edge cases

      if (!server_url_string.ends_with('/')) {
        absolute_schema_url << '/';
      }

      if (entry_relative_path.starts_with('/')) {
        absolute_schema_url << entry_relative_path.substr(1);
      } else {
        absolute_schema_url << entry_relative_path;
      }

      const auto resolved_schema{resolver(absolute_schema_url.str())};
      assert(resolved_schema.has_value());
      const auto base_dialect{
          sourcemeta::jsontoolkit::base_dialect(schema, resolver)};
      assert(base_dialect.has_value());
      entry_json.assign(
          "baseDialect",
          sourcemeta::jsontoolkit::JSON{base_dialect_id(base_dialect.value())});

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

  auto meta{sourcemeta::jsontoolkit::JSON::make_object()};
  const auto page_entry_name{
      std::filesystem::relative(directory, base).string()};

  // Precompute page metadata
  if (configuration.defines("pages") &&
      configuration.at("pages").defines(page_entry_name)) {
    for (const auto &entry :
         configuration.at("pages").at(page_entry_name).as_object()) {
      meta.assign(entry.first, entry.second);
    }
  }

  // Store entries
  meta.assign("entries", std::move(entries));

  // Precompute the breadcrumb
  const std::filesystem::path relative_path{directory.string().substr(
      std::min(base.string().size() + 1, directory.string().size()))};
  meta.assign("breadcrumb", sourcemeta::jsontoolkit::JSON::make_array());
  std::filesystem::path current_path{"/"};
  for (const auto &part : relative_path) {
    current_path = current_path / part;
    auto breadcrumb_entry{sourcemeta::jsontoolkit::JSON::make_object()};
    breadcrumb_entry.assign("name", sourcemeta::jsontoolkit::JSON{part});
    breadcrumb_entry.assign("url", sourcemeta::jsontoolkit::JSON{current_path});
    meta.at("breadcrumb").push_back(std::move(breadcrumb_entry));
  }

  const auto index_path{base.parent_path() / "generated" /
                        std::filesystem::relative(directory, base) /
                        "index.json"};
  std::cerr << "Saving into: " << index_path.string() << "\n";
  std::filesystem::create_directories(index_path.parent_path());
  std::ofstream stream{index_path};
  assert(!stream.fail());
  sourcemeta::jsontoolkit::prettify(meta, stream);
  stream << "\n";
  stream.close();

  if (directory == base) {
    std::cerr << "Generating HTML index page\n";
    std::ofstream html{index_path.parent_path() / "index.html"};
    assert(!html.fail());
    sourcemeta::registry::enterprise::html_start(
        html, configuration, configuration.at("title").to_string(),
        configuration.at("description").to_string(), "");
    sourcemeta::registry::enterprise::html_file_manager(html, meta);
    sourcemeta::registry::enterprise::html_end(html);
    html << "\n";
    html.close();
  } else {
    std::cerr << "Generating HTML directory page\n";
    const auto page_relative_path{std::string{'/'} + relative_path.string()};
    std::ofstream html{index_path.parent_path() / "index.html"};
    assert(!html.fail());
    sourcemeta::registry::enterprise::html_start(
        html, configuration, page_relative_path, page_relative_path,
        page_relative_path);
    sourcemeta::registry::enterprise::html_file_manager(html, meta);
    sourcemeta::registry::enterprise::html_end(html);
    html << "\n";
    html.close();
  }
}

auto attach(const sourcemeta::jsontoolkit::FlatFileSchemaResolver &resolver,
            const sourcemeta::jsontoolkit::URI &server_url,
            const sourcemeta::jsontoolkit::JSON &configuration,
            const std::filesystem::path &, const std::filesystem::path &output)
    -> int {
  std::cerr << "-- Indexing directory: " << output.string() << "\n";
  const auto base{std::filesystem::canonical(output / "schemas")};
  auto search_index{sourcemeta::jsontoolkit::JSON::make_array()};
  generate_toc(resolver, server_url, configuration, base, base, search_index);

  for (const auto &entry :
       std::filesystem::recursive_directory_iterator{output / "schemas"}) {
    if (!entry.is_directory()) {
      continue;
    }

    std::cerr << "-- Processing: " << entry.path().string() << "\n";
    generate_toc(resolver, server_url, configuration, base,
                 std::filesystem::canonical(entry.path()), search_index);
  }

  std::ofstream stream{output / "search.json"};
  assert(!stream.fail());
  sourcemeta::jsontoolkit::prettify(search_index, stream);
  stream << "\n";
  stream.close();

  // Not found page
  std::ofstream stream_not_found{output / "generated" / "404.html"};
  assert(!stream_not_found.fail());
  sourcemeta::registry::enterprise::html_start(
      stream_not_found, configuration, "Not Found",
      "What you are looking for is not here", std::nullopt);
  stream_not_found << "<div class=\"container-fluid p-4\">";
  stream_not_found << "Not Found";
  stream_not_found << "</div>";
  sourcemeta::registry::enterprise::html_end(stream_not_found);
  stream_not_found << "\n";
  stream_not_found.close();

  return EXIT_SUCCESS;
}

} // namespace sourcemeta::registry::enterprise

#endif
