#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_

#include <sourcemeta/hydra/http.h>
#include <sourcemeta/hydra/httpserver.h>

#include "enterprise_explorer.h"

#include <cassert> // assert
#include <sstream> // std::ostringstream

static auto
explorer_start(const sourcemeta::hydra::http::ServerRequest &request,
               const std::string &server_base_url, const std::string &site_name,
               const std::string &title, const std::string &description)
    -> std::ostringstream {
  std::ostringstream html;
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
  html << "<link rel=\"canonical\" href=\"" << server_base_url << request.path()
       << "\">";
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

  if (configuration().defines("analytics")) {
    if (configuration().at("analytics").defines("plausible")) {
      html << "<script defer data-domain=\"";
      html << configuration().at("analytics").at("plausible").to_string();
      html << "\" src=\"https://plausible.io/js/script.js\"></script>";
    }
  }

  html << "</head>";
  html << "<body class=\"h-100\">";

  html << "<nav class=\"navbar navbar-expand border-bottom bg-body\">";
  html << "<div class=\"container-fluid px-4 py-2\">";
  html << "<a class=\"navbar-brand\" href=\"" << server_base_url << "\">";
  html << "<img src=\"/icon.svg\" alt=\"" << site_name
       << "\" height=\"30\" width=\"30\" class=\"me-2\">";
  html << "<span class=\"align-middle fw-bold\">" << site_name << "</span>";
  html << "<span class=\"align-middle fw-lighter\"> Schemas</span>";
  html << "</a>";
  html << "</div>";
  html << "</nav>";

  return html;
}

static auto explorer_end(std::ostringstream &html,
                         sourcemeta::hydra::http::ServerResponse &response,
                         const sourcemeta::hydra::http::Status code) -> void {
  html << "</body>";
  html << "</html>";

  // TODO: On non-debug builds, add at least some sane level
  // of HTTP caching, maybe similar to how GitHub Pages does it?
  response.status(code);
  response.header("Content-Type", "text/html");
  response.end(html.str());
}

static auto file_manager(std::ostringstream &html,
                         const std::filesystem::path &directory) -> void {
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

  // html << "<p class=\"mb-0 text-secondary fw-light\">";
  // html << "XXXXX" << "\n";
  // html << "</p>";

  html << "<div class=\"container-fluid p-4\">";
  html << "<table class=\"table table-bordered border-light-subtle "
          "table-light\">";

  html << "<thead>";
  html << "<tr>";
  html << "<th scope=\"col\" style=\"width: 1%\">Kind</th>";
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
    html << "<td>";
    if (entry.at("type").to_string() == "directory") {
      html << "<i class=\"bi bi-folder-fill\"></i>";
    } else {
      html << "<i class=\"bi bi-braces\"></i>";
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

    assert(entry.defines("title"));
    html << "<td>";
    html << "<small>";
    if (entry.at("title").is_string()) {
      html << entry.at("title").to_string();
    } else {
      html << "-";
    }
    html << "</small>";
    html << "</td>";

    assert(entry.defines("description"));
    html << "<td>";
    html << "<small>";
    if (entry.at("description").is_string()) {
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

namespace sourcemeta::registry::enterprise {

auto explore_index(const std::string &site_name, const std::string &title,
                   const std::string &description,
                   const std::string &server_base_url,
                   const std::filesystem::path &schema_base_directory,
                   const sourcemeta::hydra::http::ServerRequest &request,
                   sourcemeta::hydra::http::ServerResponse &response) -> void {
  std::ostringstream html{
      explorer_start(request, server_base_url, site_name, title, description)};
  file_manager(html, sourcemeta::registry::path_join(schema_base_directory,
                                                     request.path()));
  explorer_end(html, response, sourcemeta::hydra::http::Status::OK);
}

auto explore_directory(const std::string &site_name,
                       const std::filesystem::path &directory,
                       const std::string &server_base_url,
                       const sourcemeta::hydra::http::ServerRequest &request,
                       sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  std::ostringstream html{explorer_start(request, server_base_url, site_name,
                                         request.path(), request.path())};
  file_manager(html, directory);
  explorer_end(html, response, sourcemeta::hydra::http::Status::OK);
}

auto explore_not_found(const std::string &site_name,
                       const std::string &server_base_url,
                       const sourcemeta::hydra::http::ServerRequest &request,
                       sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  std::ostringstream html{
      explorer_start(request, server_base_url, site_name, "Not Found",
                     "What you are looking for is not here")};
  html << "<div class=\"container-fluid p-4\">";
  html << "Not Found";
  html << "</div>";
  explorer_end(html, response, sourcemeta::hydra::http::Status::NOT_FOUND);
}

} // namespace sourcemeta::registry::enterprise

#endif
