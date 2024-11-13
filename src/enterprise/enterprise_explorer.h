#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_

#include <sourcemeta/hydra/http.h>
#include <sourcemeta/hydra/httpserver.h>

#include "enterprise_explorer.h"

#include <sstream> // std::ostringstream

static auto
explorer_start(const sourcemeta::hydra::http::ServerRequest &request,
               const std::string &server_base_url, const std::string &title,
               const std::string &description) -> std::ostringstream {
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

  html << "</head>";
  html << "<body class=\"h-100\">";
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

namespace sourcemeta::registry::enterprise {

auto explore_index(const std::string &server_base_url,
                   const sourcemeta::hydra::http::ServerRequest &request,
                   sourcemeta::hydra::http::ServerResponse &response) -> void {
  std::ostringstream html{
      explorer_start(request, server_base_url, "Sourcemeta Schemas",
                     "The Sourcemeta JSON Schema registry")};
  html << "<div class=\"container\">";
  html << "Sourcemeta Schemas";
  html << "</div>";
  explorer_end(html, response, sourcemeta::hydra::http::Status::OK);
}

auto explore_not_found(const std::string &server_base_url,
                       const sourcemeta::hydra::http::ServerRequest &request,
                       sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  std::ostringstream html{
      explorer_start(request, server_base_url, "Not Found",
                     "What you are looking for is not here")};
  html << "<div class=\"container\">";
  html << "Not Found";
  html << "</div>";
  explorer_end(html, response, sourcemeta::hydra::http::Status::NOT_FOUND);
}

} // namespace sourcemeta::registry::enterprise

#endif
