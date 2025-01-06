#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_

#include <sourcemeta/hydra/httpserver.h>

#include <filesystem> // std::filesystem
#include <sstream>    // std::ostringstream

namespace sourcemeta::registry::enterprise {

auto on_index(const sourcemeta::hydra::http::ServerLogger &,
              const sourcemeta::hydra::http::ServerRequest &request,
              sourcemeta::hydra::http::ServerResponse &response) -> void {
  sourcemeta::hydra::http::serve_file(
      *(__global_data) / "generated" / "index.html", request, response);
}

auto on_request(const sourcemeta::hydra::http::ServerLogger &logger,
                const sourcemeta::hydra::http::ServerRequest &request,
                sourcemeta::hydra::http::ServerResponse &response) -> void {
  const auto &request_path{request.path()};
  const auto extension{std::filesystem::path{request_path}.extension()};
  if (extension == ".json") {
    return ::on_request(logger, request, response);
  }

  // TODO: Prevent relative paths that can let a client
  // serve a file outside of the static asset directory
  std::ostringstream asset_path_stream;
  asset_path_stream << SOURCEMETA_REGISTRY_ENTERPRISE_STATIC << request_path;
  const std::string asset_path{asset_path_stream.str()};
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
  server.route(sourcemeta::hydra::http::Method::GET, "/", on_index);
  server.route(sourcemeta::hydra::http::Method::GET, "/*", on_request);
  server.route(sourcemeta::hydra::http::Method::HEAD, "/*", on_request);
}

} // namespace sourcemeta::registry::enterprise

#endif
