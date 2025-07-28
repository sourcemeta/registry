#ifndef SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_
#define SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_

#include <sourcemeta/registry/metapack.h>
#include <sourcemeta/registry/resolver.h>

#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/time.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>

#include "html_partials.h"
#include "html_safe.h"
#include "semver.h"

#include <algorithm>  // std::sort
#include <cassert>    // assert
#include <chrono>     // std::chrono::system_clock::time_point
#include <filesystem> // std::filesystem
#include <fstream>    // std::ifstream
#include <optional>   // std::optional
#include <regex>      // std::regex, std::regex_search, std::smatch
#include <sstream>    // std::ostringstream
#include <string>     // std::string
#include <utility>    // std::move
#include <vector>     // std::vector

namespace sourcemeta::registry {

auto GENERATE_SERVER_CONFIGURATION(const sourcemeta::core::JSON &configuration)
    -> sourcemeta::core::JSON {
  auto summary{sourcemeta::core::JSON::make_object()};
  summary.assign("port", configuration.at("port"));
  return summary;
}

auto GENERATE_BUNDLE(const sourcemeta::registry::Resolver &resolver,
                     const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::registry::read_contents(absolute_path)};
  assert(schema.has_value());
  return sourcemeta::core::bundle(
      sourcemeta::core::parse_json(schema.value().data),
      sourcemeta::core::schema_official_walker,
      [&resolver](const auto identifier) { return resolver(identifier); });
}

auto GENERATE_DEPENDENCIES(const sourcemeta::registry::Resolver &resolver,
                           const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::registry::read_contents(absolute_path)};
  assert(schema.has_value());
  auto result{sourcemeta::core::JSON::make_array()};
  sourcemeta::core::dependencies(
      sourcemeta::core::parse_json(schema.value().data),
      sourcemeta::core::schema_official_walker,
      [&resolver](const auto identifier) { return resolver(identifier); },
      [&result](const auto &origin, const auto &pointer, const auto &target,
                const auto &) {
        auto trace{sourcemeta::core::JSON::make_object()};
        trace.assign("from", sourcemeta::core::to_json(origin));
        trace.assign("to", sourcemeta::core::to_json(target));
        trace.assign("at", sourcemeta::core::to_json(pointer));
        result.push_back(std::move(trace));
      });

  return result;
}

auto GENERATE_UNIDENTIFIED(const sourcemeta::registry::Resolver &resolver,
                           const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  auto contents{sourcemeta::registry::read_contents(absolute_path)};
  assert(contents.has_value());
  auto schema{sourcemeta::core::parse_json(contents.value().data)};
  sourcemeta::core::unidentify(
      schema, sourcemeta::core::schema_official_walker,
      [&resolver](const auto identifier) { return resolver(identifier); });
  return schema;
}

auto GENERATE_BLAZE_TEMPLATE(const std::filesystem::path &absolute_path,
                             const sourcemeta::blaze::Mode mode)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::registry::read_contents(absolute_path)};
  assert(schema.has_value());
  const auto schema_template{sourcemeta::blaze::compile(
      sourcemeta::core::parse_json(schema.value().data),
      sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::blaze::default_schema_compiler, mode)};
  return sourcemeta::blaze::to_json(schema_template);
}

auto GENERATE_POINTER_POSITIONS(const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  sourcemeta::core::PointerPositionTracker tracker;
  const auto file{sourcemeta::registry::read_stream(absolute_path)};
  assert(file.has_value());
  std::stringstream buffer;
  buffer << file.value().data.rdbuf();
  if (file.value().encoding == sourcemeta::registry::MetaPackEncoding::GZIP) {
    std::stringstream decompressed;
    sourcemeta::core::gunzip(buffer, decompressed);
    const auto schema{
        sourcemeta::core::parse_json(decompressed, std::ref(tracker))};
    return sourcemeta::core::to_json(tracker);
  } else {
    const auto schema{sourcemeta::core::parse_json(buffer, std::ref(tracker))};
    return sourcemeta::core::to_json(tracker);
  }
}

// TODO: Put breadcrumb inside this metadata
auto GENERATE_NAV_SCHEMA(const sourcemeta::core::JSON &configuration,
                         const sourcemeta::registry::Resolver &resolver,
                         const std::filesystem::path &absolute_path,
                         // TODO: Compute this argument instead
                         const std::filesystem::path &relative_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::registry::read_contents(absolute_path)};
  assert(schema.has_value());
  const auto schema_json{sourcemeta::core::parse_json(schema.value().data)};
  auto id{sourcemeta::core::identify(
      schema_json,
      [&resolver](const auto identifier) { return resolver(identifier); })};
  assert(id.has_value());
  auto result{sourcemeta::core::JSON::make_object()};

  result.assign("bytes", sourcemeta::core::JSON{schema.value().bytes});
  result.assign("id", sourcemeta::core::JSON{std::move(id).value()});
  result.assign("url", sourcemeta::core::JSON{"/" + relative_path.string()});
  result.assign("canonical",
                sourcemeta::core::JSON{configuration.at("url").to_string() +
                                       "/" + relative_path.string()});
  const auto base_dialect{sourcemeta::core::base_dialect(
      schema_json,
      [&resolver](const auto identifier) { return resolver(identifier); })};
  assert(base_dialect.has_value());
  // The idea is to match the URLs from https://www.learnjsonschema.com
  // so we can provide links to it
  const std::regex MODERN(R"(^https://json-schema\.org/draft/(\d{4}-\d{2})/)");
  const std::regex LEGACY(R"(^http://json-schema\.org/draft-0?(\d+)/)");
  std::smatch match;
  if (std::regex_search(base_dialect.value(), match, MODERN)) {
    result.assign("baseDialect", sourcemeta::core::JSON{match[1].str()});
  } else if (std::regex_search(base_dialect.value(), match, LEGACY)) {
    result.assign("baseDialect",
                  sourcemeta::core::JSON{"draft" + match[1].str()});
  } else {
    // We should never get here
    assert(false);
    result.assign("baseDialect", sourcemeta::core::JSON{"unknown"});
  }

  const auto dialect{sourcemeta::core::dialect(schema_json, base_dialect)};
  assert(dialect.has_value());
  result.assign("dialect", sourcemeta::core::JSON{dialect.value()});
  if (schema_json.is_object()) {
    const auto title{schema_json.try_at("title")};
    if (title && title->is_string()) {
      result.assign("title", sourcemeta::core::JSON{title->trim()});
    }
    const auto description{schema_json.try_at("description")};
    if (description && description->is_string()) {
      result.assign("description", sourcemeta::core::JSON{description->trim()});
    }
  }

  // Precompute the breadcrumb
  result.assign("breadcrumb", sourcemeta::core::JSON::make_array());
  std::filesystem::path current_path{"/"};
  auto copy = relative_path;
  copy.replace_extension("");
  for (const auto &part : copy) {
    current_path = current_path / part;
    auto breadcrumb_entry{sourcemeta::core::JSON::make_object()};
    breadcrumb_entry.assign("name", sourcemeta::core::JSON{part});
    breadcrumb_entry.assign("url", sourcemeta::core::JSON{current_path});
    result.at("breadcrumb").push_back(std::move(breadcrumb_entry));
  }

  return result;
}

// TODO: We should simplify this signature somehow
auto GENERATE_NAV_DIRECTORY(const sourcemeta::core::JSON &configuration,
                            const std::filesystem::path &navigation_base,
                            const std::filesystem::path &base,
                            const std::filesystem::path &directory)
    -> sourcemeta::core::JSON {
  assert(directory.string().starts_with(base.string()));
  auto entries{sourcemeta::core::JSON::make_array()};

  for (const auto &entry : std::filesystem::directory_iterator{directory}) {
    auto entry_json{sourcemeta::core::JSON::make_object()};
    const auto entry_relative_path{
        entry.path().string().substr(base.string().size() + 1)};
    assert(!entry_relative_path.starts_with('/'));
    if (entry.is_directory()) {
      entry_json.assign("name",
                        sourcemeta::core::JSON{entry.path().filename()});
      if (configuration.defines("pages") &&
          configuration.at("pages").defines(entry_relative_path)) {
        entry_json.merge(
            configuration.at("pages").at(entry_relative_path).as_object());
      }

      entry_json.assign("type", sourcemeta::core::JSON{"directory"});
      entry_json.assign(
          "url", sourcemeta::core::JSON{
                     entry.path().string().substr(base.string().size())});
      entries.push_back(std::move(entry_json));
    } else if (entry.path().extension() == ".schema") {
      entry_json.assign("name", sourcemeta::core::JSON{
                                    entry.path().stem().replace_extension("")});

      auto schema_nav_path{navigation_base / entry_relative_path};
      schema_nav_path.replace_extension("");
      // TODO: This generator should not be aware of the fact that
      // we use a .nav extension on the actual file?
      schema_nav_path.replace_extension("nav");

      const auto nav{sourcemeta::registry::read_contents(schema_nav_path)};
      assert(nav.has_value());
      entry_json.merge(
          sourcemeta::core::parse_json(nav.value().data).as_object());
      // No need to show breadcrumbs of children
      entry_json.erase("breadcrumb");
      entry_json.assign("type", sourcemeta::core::JSON{"schema"});

      assert(entry_json.defines("url"));
      std::filesystem::path url{entry_json.at("url").to_string()};
      url.replace_extension("");
      entry_json.at("url").into(sourcemeta::core::JSON{url});

      entries.push_back(std::move(entry_json));
    }
  }

  std::sort(
      entries.as_array().begin(), entries.as_array().end(),
      [](const auto &left, const auto &right) {
        if (left.at("type") == right.at("type")) {
          const auto &left_name{left.at("name")};
          const auto &right_name{right.at("name")};

          // If the schema/directories represent SemVer versions, attempt to
          // parse them as such and provide better sorting
          const auto left_version{
              sourcemeta::registry::try_parse_version(left_name.to_string())};
          const auto right_version{
              sourcemeta::registry::try_parse_version(right_name.to_string())};
          if (left_version.has_value() && right_version.has_value()) {
            return left_version.value() > right_version.value();
          }

          return left_name > right_name;
        }

        return left.at("type") < right.at("type");
      });

  auto meta{sourcemeta::core::JSON::make_object()};

  const auto page_key{std::filesystem::relative(directory, base)};
  if (configuration.defines("pages") &&
      configuration.at("pages").defines(page_key)) {
    meta.merge(configuration.at("pages").at(page_key).as_object());
  }

  meta.assign("entries", std::move(entries));

  const std::filesystem::path relative_path{directory.string().substr(
      std::min(base.string().size() + 1, directory.string().size()))};
  meta.assign(
      "url", sourcemeta::core::JSON{std::string{"/"} + relative_path.string()});

  if (relative_path.string().empty()) {
    meta.assign("canonical", configuration.at("url"));
  } else {
    meta.assign("canonical",
                sourcemeta::core::JSON{configuration.at("url").to_string() +
                                       "/" + relative_path.string()});
  }

  // Precompute the breadcrumb
  meta.assign("breadcrumb", sourcemeta::core::JSON::make_array());
  std::filesystem::path current_path{"/"};
  for (const auto &part : relative_path) {
    current_path = current_path / part;
    auto breadcrumb_entry{sourcemeta::core::JSON::make_object()};
    breadcrumb_entry.assign("name", sourcemeta::core::JSON{part});
    breadcrumb_entry.assign("url", sourcemeta::core::JSON{current_path});
    meta.at("breadcrumb").push_back(std::move(breadcrumb_entry));
  }

  return meta;
}

auto GENERATE_SEARCH_INDEX(
    const std::vector<std::filesystem::path> &absolute_paths)
    -> std::vector<sourcemeta::core::JSON> {
  std::vector<sourcemeta::core::JSON> result;
  result.reserve(absolute_paths.size());
  for (const auto &absolute_path : absolute_paths) {
    auto metadata{sourcemeta::registry::read_contents(absolute_path)};
    assert(metadata.has_value());
    auto metadata_json{sourcemeta::core::parse_json(metadata.value().data)};
    auto entry{sourcemeta::core::JSON::make_array()};
    std::filesystem::path url = metadata_json.at("url").to_string();
    url.replace_extension("");
    entry.push_back(sourcemeta::core::JSON{url});
    // TODO: Can we move these?
    entry.push_back(metadata_json.at_or("title", sourcemeta::core::JSON{""}));
    entry.push_back(
        metadata_json.at_or("description", sourcemeta::core::JSON{""}));
    result.push_back(std::move(entry));
  }

  std::sort(result.begin(), result.end(),
            [](const sourcemeta::core::JSON &left,
               const sourcemeta::core::JSON &right) {
              assert(left.is_array() && left.size() == 3);
              assert(right.is_array() && right.size() == 3);

              // Prioritise entries that have more meta-data filled in
              const auto left_score =
                  (!left.at(1).empty() ? 1 : 0) + (!left.at(2).empty() ? 1 : 0);
              const auto right_score = (!right.at(1).empty() ? 1 : 0) +
                                       (!right.at(2).empty() ? 1 : 0);
              if (left_score != right_score) {
                return left_score > right_score;
              }

              // Otherwise revert to lexicographic comparisons
              // TODO: Ideally we sort based on schema health too, given lint
              // results
              if (left_score > 0) {
                return left.at(0).to_string() < right.at(0).to_string();
              }

              return false;
            });

  return result;
}

// TODO: HTML generators should not depend on the config file, as
// all the necessary information should be present in the nav file
auto GENERATE_EXPLORER_404(const sourcemeta::core::JSON &configuration)
    -> std::string {
  std::ostringstream stream;
  assert(!stream.fail());
  sourcemeta::registry::html::SafeOutput output_html{stream};

  const auto head{
      configuration.at_or("head", sourcemeta::core::JSON{""}).to_string()};

  sourcemeta::registry::html::partials::html_start(
      output_html, configuration.at("url").to_string(), head, configuration,
      "Not Found", "What you are looking for is not here", std::nullopt);
  output_html.open("div", {{"class", "container-fluid p-4"}})
      .open("h2", {{"class", "fw-bold"}})
      .text("Oops! What you are looking for is not here")
      .close("h2")
      .open("p", {{"class", "lead"}})
      .text("Are you sure the link you got is correct?")
      .close("p")
      .open("a", {{"href", "/"}})
      .text("Get back to the home page")
      .close("a")
      .close("div")
      .close("div");
  sourcemeta::registry::html::partials::html_end(
      output_html, sourcemeta::registry::PROJECT_VERSION);
  return stream.str();
}

// TODO: HTML generators should not depend on the config file, as
// all the necessary information should be present in the nav file
auto GENERATE_EXPLORER_INDEX(const sourcemeta::core::JSON &configuration,
                             const std::filesystem::path &navigation_path)
    -> std::string {
  const auto navigation{sourcemeta::registry::read_contents(navigation_path)};
  assert(navigation.has_value());
  const auto meta{sourcemeta::core::parse_json(navigation.value().data)};
  std::ostringstream html;
  sourcemeta::registry::html::SafeOutput output_html{html};

  const auto head{
      configuration.at_or("head", sourcemeta::core::JSON{""}).to_string()};

  sourcemeta::registry::html::partials::html_start(
      output_html, meta.at("canonical").to_string(), head, configuration,
      configuration.at("title").to_string() + " Schemas",
      configuration.at("description").to_string(), "");

  if (configuration.defines("hero")) {
    output_html.open("div", {{"class", "container-fluid px-4"}})
        .open("div", {{"class",
                       "bg-light border border-light-subtle mt-4 px-3 py-3"}});
    output_html.unsafe(configuration.at("hero").to_string());
    output_html.close("div").close("div");
  }

  sourcemeta::registry::html::partials::html_file_manager(html, meta);
  sourcemeta::registry::html::partials::html_end(
      output_html, sourcemeta::registry::PROJECT_VERSION);
  return html.str();
}

// TODO: HTML generators should not depend on the config file, as
// all the necessary information should be present in the nav file
auto GENERATE_EXPLORER_DIRECTORY_PAGE(
    const sourcemeta::core::JSON &configuration,
    const std::filesystem::path &navigation_path) -> std::string {
  const auto navigation{sourcemeta::registry::read_contents(navigation_path)};
  assert(navigation.has_value());
  const auto meta{sourcemeta::core::parse_json(navigation.value().data)};
  std::ostringstream html;

  sourcemeta::registry::html::SafeOutput output_html{html};
  const auto head{
      configuration.at_or("head", sourcemeta::core::JSON{""}).to_string()};
  sourcemeta::registry::html::partials::html_start(
      output_html, meta.at("canonical").to_string(), head, configuration,
      meta.defines("title") ? meta.at("title").to_string()
                            : meta.at("url").to_string(),
      meta.defines("description")
          ? meta.at("description").to_string()
          : ("Schemas located at " + meta.at("url").to_string()),
      meta.at("url").to_string());
  sourcemeta::registry::html::partials::html_file_manager(html, meta);
  sourcemeta::registry::html::partials::html_end(
      output_html, sourcemeta::registry::PROJECT_VERSION);
  return html.str();
}

auto GENERATE_EXPLORER_SCHEMA_PAGE(
    const sourcemeta::core::JSON &configuration,
    const std::filesystem::path &navigation_path,
    const std::filesystem::path &schema_path,
    const std::filesystem::path &dependencies_path) -> std::string {
  const auto navigation{sourcemeta::registry::read_contents(navigation_path)};
  assert(navigation.has_value());
  const auto meta{sourcemeta::core::parse_json(navigation.value().data)};

  std::ostringstream html;

  const auto &title{meta.defines("title") ? meta.at("title").to_string()
                                          : meta.at("url").to_string()};

  sourcemeta::registry::html::SafeOutput output_html{html};
  const auto head{
      configuration.at_or("head", sourcemeta::core::JSON{""}).to_string()};
  sourcemeta::registry::html::partials::html_start(
      output_html, meta.at("canonical").to_string(), head, configuration, title,
      meta.defines("description")
          ? meta.at("description").to_string()
          : ("Schemas located at " + meta.at("url").to_string()),
      meta.at("url").to_string());

  sourcemeta::registry::html::partials::breadcrumb(html, meta);

  output_html.open("div", {{"class", "container-fluid p-4"}});
  output_html.open("div");

  output_html.open("div");

  if (meta.defines("title")) {
    output_html.open("h2", {{"class", "fw-bold h4"}});
    output_html.text(title);
    output_html.close("h2");
  }

  if (meta.defines("description")) {
    output_html.open("p", {{"class", "text-secondary"}})
        .text(meta.at("description").to_string())
        .close("p");
  }

  output_html
      .open("a", {{"href", meta.at("url").to_string()},
                  {"class", "btn btn-primary me-2"},
                  {"role", "button"}})
      .text("Get JSON Schema")
      .close("a");

  output_html
      .open("a", {{"href", meta.at("url").to_string() + "?bundle=1"},
                  {"class", "btn btn-secondary"},
                  {"role", "button"}})
      .text("Bundle")
      .close("a");
  output_html.close("div");

  output_html.open("table", {{"class", "table table-bordered my-4"}});

  output_html.open("tr");
  output_html.open("th", {{"scope", "row"}, {"class", "text-nowrap"}})
      .text("Identifier")
      .close("th");
  output_html.open("td")
      .open("code")
      .open("a", {{"href", meta.at("id").to_string()}})
      .text(meta.at("id").to_string())
      .close("a")
      .close("code")
      .close("td");
  output_html.close("tr");

  output_html.open("tr");
  output_html.open("th", {{"scope", "row"}, {"class", "text-nowrap"}})
      .text("Base Dialect")
      .close("th");
  output_html.open("td");
  sourcemeta::registry::html::partials::dialect_badge(
      html, meta.at("baseDialect").to_string());
  output_html.close("td");
  output_html.close("tr");

  output_html.open("tr");
  output_html.open("th", {{"scope", "row"}, {"class", "text-nowrap"}})
      .text("Dialect")
      .close("th");
  output_html.open("td")
      .open("code")
      .text(meta.at("dialect").to_string())
      .close("code")
      .close("td");
  output_html.close("tr");

  output_html.open("tr");
  output_html.open("th", {{"scope", "row"}, {"class", "text-nowrap"}})
      .text("Size")
      .close("th");
  output_html.open("td")
      .text(std::to_string(meta.at("bytes").as_real() / (1024 * 1024)) + " MB")
      .close("td");
  output_html.close("tr");

  output_html.close("table");
  output_html.close("div");

  output_html.open("pre", {{"class", "bg-light p-3 border"}});
  output_html.open("code");
  std::ostringstream schema_summary;
  auto file{sourcemeta::registry::read_stream(schema_path)};
  assert(file.has_value());
  std::stringstream file_contents;
  sourcemeta::core::gunzip(file.value().data, file_contents);
  std::string line;
  int count = 0;
  while (count < 20 && std::getline(file_contents, line)) {
    schema_summary << line << "\n";
    count += 1;
  }
  const auto has_more_lines{file_contents && std::getline(file_contents, line)};
  if (has_more_lines) {
    schema_summary << "...\n";
  }
  output_html.text(schema_summary.str());
  output_html.close("code");
  output_html.close("pre");

  if (has_more_lines) {
    output_html.open("a", {{"href", meta.at("url").to_string()}})
        .text("See the full schema")
        .close("a");
  }

  output_html.open("h3", {{"class", "fw-bold h5 mt-4"}})
      .text("Dependencies")
      .close("h3");

  const auto dependencies{
      sourcemeta::registry::read_contents(dependencies_path)};
  assert(dependencies.has_value());
  const auto dependencies_json{
      sourcemeta::core::parse_json(dependencies.value().data)};
  std::vector<std::reference_wrapper<const sourcemeta::core::JSON>> direct;
  std::vector<std::reference_wrapper<const sourcemeta::core::JSON>> indirect;
  for (const auto &dependency : dependencies_json.as_array()) {
    if (dependency.at("from") == meta.at("id")) {
      direct.emplace_back(dependency);
    } else {
      indirect.emplace_back(dependency);
    }
  }

  std::ostringstream dependency_summary;
  dependency_summary << "This schema has " << direct.size() << " direct "
                     << (direct.size() == 1 ? "dependency" : "dependencies")
                     << " and " << indirect.size() << " indirect "
                     << (indirect.size() == 1 ? "dependency" : "dependencies")
                     << ".";
  output_html.open("p").text(dependency_summary.str()).close("p");

  if (direct.size() + indirect.size() > 0) {
    output_html.open("table", {{"class", "table"}});
    output_html.open("thead");
    output_html.open("tr");
    output_html.open("th", {{"scope", "col"}}).text("Origin").close("th");
    output_html.open("th", {{"scope", "col"}}).text("Dependency").close("th");
    output_html.close("tr");
    output_html.close("thead");
    output_html.open("tbody");

    for (const auto &dependency : dependencies_json.as_array()) {
      output_html.open("tr");

      if (dependency.at("from") == meta.at("id")) {
        output_html.open("td")
            .open("code")
            .text(dependency.at("at").to_string())
            .close("code")
            .close("td");
      } else {
        output_html.open("td")
            .open("span", {{"class", "badge text-bg-dark"}})
            .text("Indirect")
            .close("span")
            .close("td");
      }

      if (dependency.at("to").to_string().starts_with(
              configuration.at("url").to_string())) {
        std::filesystem::path dependency_schema_url{
            dependency.at("to").to_string().substr(
                configuration.at("url").to_string().size())};
        dependency_schema_url.replace_extension("");
        output_html.open("td")
            .open("code")
            .open("a", {{"href", dependency_schema_url.string()}})
            .text(dependency_schema_url.string())
            .close("a")
            .close("code")
            .close("td");
      } else {
        output_html.open("td")
            .open("code")
            .text(dependency.at("to").to_string())
            .close("code")
            .close("td");
      }

      output_html.close("tr");
    }

    output_html.close("tbody");
    output_html.close("table");
  }

  output_html.close("div");

  sourcemeta::registry::html::partials::html_end(
      output_html, sourcemeta::registry::PROJECT_VERSION);
  return html.str();
}

} // namespace sourcemeta::registry

#endif
