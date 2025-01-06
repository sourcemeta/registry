#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_EXPLORER_H_

#include <sourcemeta/hydra/http.h>
#include <sourcemeta/hydra/httpserver.h>

#include "enterprise_html.h"

#include <sstream> // std::ostringstream

namespace sourcemeta::registry::enterprise {

auto explore_directory(const std::filesystem::path &directory,
                       const sourcemeta::hydra::http::ServerRequest &request,
                       sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  std::ostringstream html;
  sourcemeta::registry::enterprise::html_start(
      html, configuration(), request.path(), request.path(), request.path());
  sourcemeta::registry::enterprise::html_file_manager(html, directory);
  sourcemeta::registry::enterprise::html_end(html);

  // TODO: On non-debug builds, add at least some sane level
  // of HTTP caching, maybe similar to how GitHub Pages does it?
  response.status(sourcemeta::hydra::http::Status::OK);
  response.header("Content-Type", "text/html");
  response.end(html.str());
}

} // namespace sourcemeta::registry::enterprise

#endif
