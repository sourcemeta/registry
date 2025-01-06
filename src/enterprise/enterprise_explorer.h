#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_

#include <sourcemeta/hydra/http.h>
#include <sourcemeta/hydra/httpserver.h>

#include "enterprise_html.h"

#include <cassert> // assert
#include <sstream> // std::ostringstream

static auto explorer_end(std::ostringstream &html,
                         sourcemeta::hydra::http::ServerResponse &response,
                         const sourcemeta::hydra::http::Status code) -> void {
  // TODO: On non-debug builds, add at least some sane level
  // of HTTP caching, maybe similar to how GitHub Pages does it?
  response.status(code);
  response.header("Content-Type", "text/html");
  response.end(html.str());
}

namespace sourcemeta::registry::enterprise {

auto explore_index(const std::string &title, const std::string &description,
                   const std::filesystem::path &schema_base_directory,
                   const sourcemeta::hydra::http::ServerRequest &request,
                   sourcemeta::hydra::http::ServerResponse &response) -> void {
  std::ostringstream html;
  sourcemeta::registry::enterprise::html_start(html, configuration(), title,
                                               description, request.path());
  sourcemeta::registry::enterprise::html_file_manager(
      html,
      sourcemeta::registry::path_join(schema_base_directory, request.path()));
  sourcemeta::registry::enterprise::html_end(html);
  explorer_end(html, response, sourcemeta::hydra::http::Status::OK);
}

auto explore_directory(const std::filesystem::path &directory,
                       const sourcemeta::hydra::http::ServerRequest &request,
                       sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  std::ostringstream html;
  sourcemeta::registry::enterprise::html_start(
      html, configuration(), request.path(), request.path(), request.path());
  sourcemeta::registry::enterprise::html_file_manager(html, directory);
  sourcemeta::registry::enterprise::html_end(html);
  explorer_end(html, response, sourcemeta::hydra::http::Status::OK);
}

auto explore_not_found(const sourcemeta::hydra::http::ServerRequest &request,
                       sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  std::ostringstream html;
  sourcemeta::registry::enterprise::html_start(
      html, configuration(), "Not Found",
      "What you are looking for is not here", request.path());
  html << "<div class=\"container-fluid p-4\">";
  html << "Not Found";
  html << "</div>";
  sourcemeta::registry::enterprise::html_end(html);
  explorer_end(html, response, sourcemeta::hydra::http::Status::NOT_FOUND);
}

} // namespace sourcemeta::registry::enterprise

#endif
