#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_HTML_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_HTML_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/registry/html.h>

#include <optional> // std::optional
#include <string>   // std::string

#include "configure.h"

namespace sourcemeta::registry::enterprise {

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
  sourcemeta::registry::html::partials::image(
      output, "/static/icon.svg", 30, configuration.at("title").to_string(),
      "me-2");
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

template <typename T> auto html_footer(T &output) -> void {
  output.open(
      "footer",
      {{"class",
        "border-top text-secondary py-3 d-flex "
        "align-items-center justify-content-between flex-column flex-md-row"}});
  output.open("small", {{"class", "mb-2 mb-md-0"}})
      .open("a", {{"href", "https://github.com/sourcemeta/registry"},
                  {"class", "text-secondary"},
                  {"target", "_blank"}})
      .text("Registry")
      .close("a")
      .text(" v")
      .text(sourcemeta::registry::PROJECT_VERSION)
#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
      .text(" (Enterprise Edition)")
#else
      .text(" (Community Edition)")
#endif
      .text(" © 2025 ")
      .open("a", {{"href", "https://www.sourcemeta.com"},
                  {"class", "text-secondary"},
                  {"target", "_blank"}})
      .text("Sourcemeta, Ltd.")
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
      .close("a")
      .close("small");
  output.close("footer");
}

template <typename T>
auto html_start(T &output, const sourcemeta::core::JSON &configuration,
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
    output.open("link",
                {{"rel", "canonical"},
                 {"href", configuration.at("url").to_string() + path.value()}});
  }

  sourcemeta::registry::html::partials::css(output, "/static/style.min.css");

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

  if (configuration.defines("analytics") &&
      configuration.at("analytics").defines("plausible")) {
    output
        .open("script",
              {{"defer", ""},
               {"data-domain",
                configuration.at("analytics").at("plausible").to_string()},
               {"src", "https://plausible.io/js/script.js"}})
        .close("script");
  }

  output.close("head");
  output.open("body", {{"class", "h-100 d-flex flex-column"}});

  html_navigation(output, configuration);
}

template <typename T> auto html_end(T &output) -> void {
  output
      .open("script",
            {{"async", ""}, {"defer", ""}, {"src", "/static/main.js"}})
      .close("script");
  output.open("div", {{"class", "container-fluid px-4 mb-2"}});
  html_footer(output);
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

// TODO: Refactor this function to use new HTML utilities
template <typename T>
auto html_file_manager(T &html, const sourcemeta::core::JSON &meta) -> void {
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

      for (auto iterator = base_dialect.cbegin();
           iterator != base_dialect.cend(); ++iterator) {
        if (iterator == base_dialect.cbegin()) {
          html << static_cast<char>(std::toupper(*iterator));
        } else {
          html << *iterator;
        }
      }

      html << "</span>";
      html << "</a>";
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

} // namespace sourcemeta::registry::enterprise

#endif
