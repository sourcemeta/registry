#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_

#include <sourcemeta/hydra/httpserver.h>

#include <filesystem> // std::filesystem

namespace sourcemeta::registry::enterprise {

auto on_request(const sourcemeta::hydra::http::ServerLogger &logger,
                const sourcemeta::hydra::http::ServerRequest &request,
                sourcemeta::hydra::http::ServerResponse &response) -> void {
  const auto &request_path{request.path()};
  if (request_path.ends_with(".json")) {
    return ::on_request(logger, request, response);
  }

  const auto asset_path{SOURCEMETA_REGISTRY_ENTERPRISE_STATIC + request_path};
  if (std::filesystem::exists(asset_path)) {
    sourcemeta::hydra::http::serve_file(asset_path, request, response);
    return;
  }

  // Explorer
  const auto directory_path{sourcemeta::registry::path_join(
      *(__global_data) / "generated", request.path())};
  if (std::filesystem::is_directory(directory_path)) {
    sourcemeta::hydra::http::serve_file(directory_path / "index.html", request,
                                        response);
    return;
  }

  sourcemeta::hydra::http::serve_file(
      *(__global_data) / "generated" / "404.html", request, response,
      sourcemeta::hydra::http::Status::NOT_FOUND);
}

auto attach(sourcemeta::hydra::http::Server &server) -> void {
  server.route(sourcemeta::hydra::http::Method::GET, "/*", on_request);
  server.route(sourcemeta::hydra::http::Method::HEAD, "/*", on_request);
}

} // namespace sourcemeta::registry::enterprise

#endif
