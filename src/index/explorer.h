#ifndef SOURCEMETA_REGISTRY_INDEX_EXPLORER_H_
#define SOURCEMETA_REGISTRY_INDEX_EXPLORER_H_

#include <sourcemeta/registry/metapack.h>
#include <sourcemeta/registry/resolver.h>

#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>

#include <algorithm>        // std::sort
#include <cassert>          // assert
#include <chrono>           // std::chrono::system_clock::time_point
#include <filesystem>       // std::filesystem
#include <fstream>          // std::ifstream
#include <initializer_list> // std::initializer_list
#include <optional>         // std::optional
#include <regex>            // std::regex, std::regex_search, std::smatch
#include <sstream>          // std::ostringstream
#include <string>           // std::string, std::stoul
#include <string_view>      // std::string_view
#include <tuple>            // std::tuple, std::make_tuple
#include <utility>          // std::move, std::pair
#include <vector>           // std::vector

// TODO: We need a SemVer module in Core

auto try_parse_version(const sourcemeta::core::JSON::String &name)
    -> std::optional<std::tuple<unsigned, unsigned, unsigned>> {
  std::regex version_regex(R"(v?(\d+)\.(\d+)\.(\d+))");
  std::smatch match;
  if (std::regex_search(name, match, version_regex)) {
    return std::make_tuple(std::stoul(match[1]), std::stoul(match[2]),
                           std::stoul(match[3]));
  } else {
    return std::nullopt;
  }
}

namespace sourcemeta::registry::html {
using Attribute = std::pair<std::string_view, std::string_view>;

template <typename T> class SafeOutput {
public:
  SafeOutput(T &output) : stream{output} {};

  auto doctype() -> SafeOutput & { return this->open("!DOCTYPE html"); }

  auto open(const std::string_view tag,
            std::initializer_list<Attribute> attributes = {}) -> SafeOutput & {
    this->stream << "<" << tag;
    for (const auto &attribute : attributes) {
      this->stream << " " << attribute.first;
      if (!attribute.second.empty()) {
        this->stream << "=\"" << attribute.second << "\"";
      }
    }
    this->stream << ">";
    return *this;
  }

  auto close(const std::string_view tag) -> SafeOutput & {
    this->stream << "</" << tag << ">";
    return *this;
  }

  auto text(const std::string_view content) -> SafeOutput & {
    // TODO: Perform escaping
    this->stream << content;
    return *this;
  }

  auto unsafe(const std::string_view content) -> SafeOutput & {
    this->stream << content;
    return *this;
  }

private:
  T &stream;
};

namespace partials {

template <typename T> auto css(T &output, const std::string_view url) -> T & {
  output.open("link", {{"rel", "stylesheet"}, {"href", url}});
  return output;
}

template <typename T>
auto image(T &output, const std::string_view url, const std::uint64_t height,
           const std::uint64_t width, const std::string_view alt,
           const std::optional<std::string_view> classes) -> T & {
  if (classes.has_value()) {
    output.open("img", {{"src", url},
                        {"alt", alt},
                        {"height", std::to_string(height)},
                        {"width", std::to_string(width)},
                        {"class", classes.value()}});
  } else {
    output.open("img", {{"src", url},
                        {"alt", alt},
                        {"height", std::to_string(height)},
                        {"width", std::to_string(width)}});
  }

  return output;
}

template <typename T>
auto image(T &output, const std::string_view url, const std::uint64_t size,
           const std::string_view alt,
           const std::optional<std::string_view> classes) -> T & {
  return image(output, url, size, size, alt, classes);
}

template <typename T>
auto html_navigation(T &output, const sourcemeta::core::JSON &configuration)
    -> void {
  output.open("nav", {{"class", "navbar navbar-expand border-bottom bg-body"}});
  output.open("div", {{"class", "container-fluid px-4 py-1 align-items-center "
                                "flex-column flex-md-row"}});

  output.open(
      "a",
      {{"class",
        "navbar-brand me-0 me-md-3 d-flex align-items-center w-100 w-md-auto"},
       {"href", configuration.at("url").to_string()}});

  output.open("span", {{"class", "fw-bold me-1"}})
      .text(configuration.at("title").to_string())
      .close("span")
      .open("span", {{"class", "fw-lighter"}})
      .text(" Schemas")
      .close("span");
  output.close("a");

  output
      .open("div",
            {{"class",
              "mt-2 mt-md-0 flex-grow-1 position-relative w-100 w-md-auto"}})
      .open("div", {{"class", "input-group"}})
      .open("span", {{"class", "input-group-text"}})
      .open("i", {{"class", "bi bi-search"}})
      .close("i")
      .close("span")
      .open("input", {{"class", "form-control"},
                      {"type", "search"},
                      {"id", "search"},
                      {"placeholder", "Search"},
                      {"aria-label", "Search"},
                      {"autocomplete", "off"}})
      .close("div")
      .open("ul", {{"class",
                    "d-none list-group position-absolute w-100 mt-2 shadow-sm"},
                   {"id", "search-result"}})
      .close("ul")
      .close("div");

  if (configuration.defines("action")) {
    output.open("a",
                {{"class", "ms-md-3 btn btn-dark mt-2 mt-md-0 w-100 w-md-auto"},
                 {"role", "button"},
                 {"href", configuration.at("action").at("url").to_string()}});

    if (configuration.at("action").defines("icon")) {
      output
          .open("i", {{"class",
                       "me-2 bi bi-" +
                           configuration.at("action").at("icon").to_string()}})
          .close("i");
    }

    output.text(configuration.at("action").at("title").to_string());
    output.close("a");
  }

  output.close("div");
  output.close("nav");
}

template <typename T>
auto html_footer(T &output, const std::string_view version) -> void {
  output.open(
      "footer",
      {{"class",
        "border-top text-secondary py-3 d-flex "
        "align-items-center justify-content-between flex-column flex-md-row"}});
  output.open("small", {{"class", "mb-2 mb-md-0"}});
  image(output, "/static/icon.svg", 25, "Sourcemeta", "me-2");

  output
      .open("a", {{"href", "https://github.com/sourcemeta/registry"},
                  {"class", "text-secondary"},
                  {"target", "_blank"}})
      .text("Registry")
      .close("a")
      .text(" v")
      .text(version)
#if defined(SOURCEMETA_REGISTRY_ENTERPRISE)
      .text(" (Enterprise)")
#elif defined(SOURCEMETA_REGISTRY_PRO)
      .text(" (Pro)")
#else
      .text(" (Starter)")
#endif
      .text(" © 2025 ")
      .open("a", {{"href", "https://www.sourcemeta.com"},
                  {"class", "text-secondary"},
                  {"target", "_blank"}})
      .text("Sourcemeta")
      .close("a")
      .close("small");
  output.open("small")
      .open("a",
            {{"href", "https://github.com/sourcemeta/registry/discussions"},
             {"class", "text-secondary"},
             {"target", "_blank"}})
      .open("i", {{"class", "bi bi-question-square me-2"}})
      .close("i")
      .text("Need Help?")
      .close("a");

  output.close("small");
  output.close("footer");
}

template <typename T>
auto html_start(T &output, const std::string &canonical,
                const std::string &head,
                const sourcemeta::core::JSON &configuration,
                const std::string &title, const std::string &description,
                const std::optional<std::string> &path) -> void {
  output.doctype();
  output.open("html", {{"class", "h-100"}, {"lang", "en"}});
  output.open("head");

  // Meta headers
  output.open("meta", {{"charset", "utf-8"}})
      .open("meta", {{"name", "referrer"}, {"content", "no-referrer"}})
      .open("meta", {{"name", "viewport"},
                     {"content", "width=device-width, initial-scale=1.0"}})
      .open("meta",
            {{"http-equiv", "x-ua-compatible"}, {"content", "ie=edge"}});

  // Site metadata
  output.open("title").text(title).close("title");
  output.open("meta", {{"name", "description"}, {"content", description}});
  if (path.has_value()) {
    output.open("link", {{"rel", "canonical"}, {"href", canonical}});
  }

  css(output, "/static/style.min.css");

  // Application icons
  // TODO: Allow changing these by supporing an object in the
  // configuration manifest to select static files to override
  output
      .open(
          "link",
          {{"rel", "icon"}, {"href", "/static/favicon.ico"}, {"sizes", "any"}})
      .open("link", {{"rel", "icon"},
                     {"href", "/static/icon.svg"},
                     {"type", "image/svg+xml"}})
      .open("link", {{"rel", "shortcut icon"},
                     {"href", "/static/apple-touch-icon.png"},
                     {"type", "image/png"}})
      .open("link", {{"rel", "apple-touch-icon"},
                     {"href", "/static/apple-touch-icon.png"},
                     {"sizes", "180x180"}})
      .open("link",
            {{"rel", "manifest"}, {"href", "/static/manifest.webmanifest"}});

  output.unsafe(head);
  output.close("head");
  output.open("body", {{"class", "h-100 d-flex flex-column"}});

  html_navigation(output, configuration);
}

template <typename T>
auto html_end(T &output, const std::string_view version) -> void {
  output
      .open("script",
            {{"async", ""}, {"defer", ""}, {"src", "/static/main.min.js"}})
      .close("script");
  output.open("div", {{"class", "container-fluid px-4 mb-2"}});
  html_footer(output, version);
  output.close("div");
  output.close("body");
  output.close("html");
}

// TODO: Refactor this function to use new HTML utilities
template <typename T>
static auto profile_picture(T &html, const sourcemeta::core::JSON &meta,
                            const std::uint64_t size,
                            const std::string_view classes = "") -> bool {
  if (meta.defines("github") && !meta.at("github").contains('/')) {
    html << "<img";
    if (!classes.empty()) {
      html << " class=\"" << classes << "\"";
    }

    html << " src=\"https://github.com/";
    html << meta.at("github").to_string();
    html << ".png?size=";
    html << size * 2;
    html << "\" width=\"" << size << "\" height=\"" << size << "\">";
    return true;
  }

  return false;
}

template <typename T>
auto breadcrumb(T &html, const sourcemeta::core::JSON &meta) -> void {
  assert(meta.defines("breadcrumb"));
  assert(meta.at("breadcrumb").is_array());
  if (!meta.at("breadcrumb").empty()) {
    html << "<nav class=\"container-fluid px-4 py-2 bg-light bg-gradient "
            "border-bottom font-monospace\" aria-label=\"breadcrumb\">";
    html << "<ol class=\"breadcrumb mb-0\">";
    html << "<li class=\"breadcrumb-item\">";
    html << "<a href=\"/\">";
    html << "<i class=\"bi bi-arrow-left\"></i>";
    html << "</a>";
    html << "</li>";

    const auto &breadcrumb{meta.at("breadcrumb").as_array()};
    for (auto iterator = breadcrumb.cbegin(); iterator != breadcrumb.cend();
         iterator++) {
      assert(iterator->is_object());
      assert(iterator->defines("name"));
      assert(iterator->at("name").is_string());
      assert(iterator->defines("url"));
      assert(iterator->at("url").is_string());
      if (std::next(iterator) == breadcrumb.cend()) {
        html << "<li class=\"breadcrumb-item active\" aria-current=\"page\">";
        html << iterator->at("name").to_string();
        html << "</li>";
      } else {
        html << "<li class=\"breadcrumb-item\">";
        html << "<a href=\"" << iterator->at("url").to_string() << "\">";
        html << iterator->at("name").to_string();
        html << "</a>";
        html << "</li>";
      }
    }

    html << "</ol>";
    html << "</nav>";
  }
}

template <typename T>
auto dialect_badge(T &html, const sourcemeta::core::JSON::String &base_dialect)
    -> void {
  html << "<a "
          "href=\"https://www.learnjsonschema.com/";
  html << base_dialect;
  html << "\" target=\"_blank\">";
  html << "<span class=\"align-middle badge ";

  // Highlight the latest version in a different manner
  if (base_dialect == "2020-12") {
    html << "text-bg-primary";
  } else {
    html << "text-bg-danger";
  }

  html << "\">";
  for (auto iterator = base_dialect.cbegin(); iterator != base_dialect.cend();
       ++iterator) {
    if (iterator == base_dialect.cbegin()) {
      html << static_cast<char>(std::toupper(*iterator));
    } else {
      html << *iterator;
    }
  }

  html << "</span>";
  html << "</a>";
}

// TODO: Refactor this function to use new HTML utilities
template <typename T>
auto html_file_manager(T &html, const sourcemeta::core::JSON &meta) -> void {
  breadcrumb(html, meta);

  html << "<div class=\"container-fluid p-4 flex-grow-1\">";
  html << "<table class=\"table table-bordered border-light-subtle "
          "table-light\">";

  if (!meta.at("breadcrumb").empty() && meta.defines("title")) {
    html << "<div class=\"mb-4 d-flex\">";
    profile_picture(html, meta, 100, "img-thumbnail me-4");
    html << "<div>";
    html << "<h2 class=\"fw-bold h4\">";
    html << meta.at("title").to_string();
    html << "</h2>";

    if (meta.defines("description")) {
      html << "<p class=\"text-secondary\">";
      html << meta.at("description").to_string();
      html << "</p>";
    }

    if (meta.defines("email") || meta.defines("github") ||
        meta.defines("website")) {
      html << "<div>";

      if (meta.defines("github")) {
        html << "<small class=\"me-3 d-block mb-2 mb-md-0 d-md-inline-block\">";
        html << "<i class=\"bi bi-github text-secondary me-1\"></i>";
        html << "<a href=\"https://github.com/";
        html << meta.at("github").to_string();
        html << "\" class=\"text-secondary\" target=\"_blank\">";
        html << meta.at("github").to_string();
        html << "</a>";
        html << "</small>";
      }

      if (meta.defines("website")) {
        html << "<small class=\"me-3 d-block mb-2 mb-md-0 d-md-inline-block\">";
        html << "<i class=\"bi bi-link-45deg text-secondary me-1\"></i>";
        html << "<a href=\"";
        html << meta.at("website").to_string();
        html << "\" class=\"text-secondary\" target=\"_blank\">";
        html << meta.at("website").to_string();
        html << "</a>";
        html << "</small>";
      }

      if (meta.defines("email")) {
        html << "<small class=\"me-3 d-block mb-2 mb-md-0 d-md-inline-block\">";
        html << "<i class=\"bi bi-envelope text-secondary me-1\"></i>";
        html << "<a href=\"mailto:";
        html << meta.at("email").to_string();
        html << "\" class=\"text-secondary\">";
        html << meta.at("email").to_string();
        html << "</a>";
        html << "</small>";
      }

      html << "</div>";
    }

    html << "</div>";
    html << "</div>";
  }

  html << "<thead>";
  html << "<tr>";
  html << "<th scope=\"col\" style=\"width: 50px\"></th>";
  html << "<th scope=\"col\">Name</th>";
  html << "<th scope=\"col\">Title</th>";
  html << "<th scope=\"col\">Description</th>";
  html << "</tr>";
  html << "</thead>";
  html << "<tbody>";

  assert(meta.is_object());
  assert(meta.defines("entries"));
  assert(meta.at("entries").is_array());

  for (const auto &entry : meta.at("entries").as_array()) {
    assert(entry.is_object());
    html << "<tr>";

    assert(entry.defines("type"));
    assert(entry.at("type").is_string());
    html << "<td class=\"text-nowrap\">";
    if (entry.at("type").to_string() == "directory") {
      const auto has_picture{profile_picture(html, entry, 40)};
      if (!has_picture) {
        html << "<i class=\"bi bi-folder-fill\"></i>";
      }
    } else {
      const auto &base_dialect{entry.at("baseDialect").to_string()};
      dialect_badge(html, base_dialect);
    }
    html << "</td>";

    assert(entry.defines("name"));
    assert(entry.at("name").is_string());
    html << "<td class=\"font-monospace text-nowrap\">";
    assert(entry.defines("url"));
    assert(entry.at("url").is_string());
    html << "<a href=\"" << entry.at("url").to_string() << "\">";
    html << entry.at("name").to_string();
    html << "</a>";
    html << "</td>";

    html << "<td>";
    html << "<small>";
    if (entry.defines("title")) {
      html << entry.at("title").to_string();
    } else {
      html << "-";
    }
    html << "</small>";
    html << "</td>";

    html << "<td>";
    html << "<small>";
    if (entry.defines("description")) {
      html << entry.at("description").to_string();
    } else {
      html << "-";
    }
    html << "</small>";
    html << "</td>";

    html << "</tr>";
  }

  html << "</tbody>";

  html << "</table>";
  html << "</div>";
}

} // namespace partials

} // namespace sourcemeta::registry::html

namespace sourcemeta::registry {

auto GENERATE_SERVER_CONFIGURATION(const sourcemeta::core::JSON &configuration)
    -> sourcemeta::core::JSON {
  auto summary{sourcemeta::core::JSON::make_object()};
  summary.assign("port", configuration.at("port"));
  return summary;
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
          const auto left_version{try_parse_version(left_name.to_string())};
          const auto right_version{try_parse_version(right_name.to_string())};
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
