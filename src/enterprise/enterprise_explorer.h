#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_

#include <sourcemeta/hydra/http.h>
#include <sourcemeta/hydra/httpserver.h>

#include "enterprise_explorer.h"

#include <sstream> // std::ostringstream

static auto explorer_start(const std::string &title) -> std::ostringstream {
  std::ostringstream html;
  html << "<!DOCTYPE html>";
  html << "<html lang=\"en\">";
  html << "<head>";
  html << "<title>";
  html << title;
  html << "</title>";
  html << "</head>";
  html << "<body>";
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

auto explore_index(sourcemeta::hydra::http::ServerResponse &response) -> void {
  std::ostringstream html{explorer_start("Sourcemeta Schemas")};
  html << "Sourcemeta Schemas";
  explorer_end(html, response, sourcemeta::hydra::http::Status::OK);
}

} // namespace sourcemeta::registry::enterprise

#endif
