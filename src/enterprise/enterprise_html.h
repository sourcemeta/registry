#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_HTML_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_HTML_H_

#include <sourcemeta/jsontoolkit/json.h>

#include <filesystem> // std::filesystem
#include <optional>   // std::optional
#include <string>     // std::string

namespace sourcemeta::registry::enterprise {

template <typename T>
auto html_start(T &html, const sourcemeta::jsontoolkit::JSON &configuration,
                const std::string &title, const std::string &description,
                const std::optional<std::string> &path) -> void {
  const auto &base_url{configuration.at("url").to_string()};

  html << "<!DOCTYPE html>";
  html << "<html lang=\"en\">";
  html << "<head>";

  // Meta headers
  html << "<meta charset=\"utf-8\">";
  html << "<meta name=\"referrer\" content=\"no-referrer\">";
  html << "<meta name=\"viewport\" content=\"width=device-width, "
          "initial-scale=1.0\">";
  html << "<meta http-equiv=\"x-ua-compatible\" content=\"ie=edge\">";

  // Site metadata
  html << "<title>" << title << "</title>";
  html << "<meta name=\"description\" content=\"" << description << "\">";
  if (path.has_value()) {
    html << "<link rel=\"canonical\" href=\"" << base_url << path.value()
         << "\">";
  }
  html << "<link rel=\"stylesheet\" href=\"/style.min.css\">";

  // Application icons
  // TODO: Allow changing these by supporing an object in the
  // configuration manifest to select static files to override
  html << "<link rel=\"icon\" href=\"/favicon.ico\" sizes=\"any\">";
  html << "<link rel=\"icon\" href=\"/icon.svg\" type=\"image/svg+xml\">";
  html << "<link rel=\"shortcut icon\" type=\"image/png\" "
          "href=\"/apple-touch-icon.png\">";
  html << "<link rel=\"apple-touch-icon\" sizes=\"180x180\" "
          "href=\"/apple-touch-icon.png\">";
  html << "<link rel=\"manifest\" href=\"/manifest.webmanifest\">";

  if (configuration.defines("analytics")) {
    if (configuration.at("analytics").defines("plausible")) {
      html << "<script defer data-domain=\"";
      html << configuration.at("analytics").at("plausible").to_string();
      html << "\" src=\"https://plausible.io/js/script.js\"></script>";
    }
  }

  html << "</head>";
  html << "<body class=\"h-100\">";

  const auto &site_name{configuration.at("title").to_string()};

  html << "<nav class=\"navbar navbar-expand border-bottom bg-body\">";
  html << "<div class=\"container-fluid px-4 py-2\">";
  html << "<a class=\"navbar-brand\" href=\"" << base_url << "\">";
  html << "<img src=\"/icon.svg\" alt=\"" << site_name
       << "\" height=\"30\" width=\"30\" class=\"me-2\">";
  html << "<span class=\"align-middle fw-bold\">" << site_name << "</span>";
  html << "<span class=\"align-middle fw-lighter\"> Schemas</span>";
  html << "</a>";
  html << "</div>";
  html << "</nav>";
}

template <typename T> auto html_end(T &html) -> void {
  html << "</body>";
  html << "</html>";
}

template <typename T>
auto html_file_manager(T &html, const std::filesystem::path &directory)
    -> void {
  const auto meta_path{directory / "index.json"};
  assert(std::filesystem::exists(meta_path));
  const auto meta{sourcemeta::jsontoolkit::from_file(meta_path)};

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

  html << "<div class=\"container-fluid p-4\">";
  html << "<table class=\"table table-bordered border-light-subtle "
          "table-light\">";

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
      if (entry.defines("github")) {
        html << "<img src=\"https://github.com/";
        html << entry.at("github").to_string();
        html << ".png?size=80\" width=\"40\" height=\"40\">";
      } else {
        html << "<i class=\"bi bi-folder-fill\"></i>";
      }
    } else {
      const auto &base_dialect{entry.at("baseDialect").to_string()};
      html << "<a "
              "href=\"https://www.learnjsonschema.com/";
      html << base_dialect;
      html << "\">";
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
