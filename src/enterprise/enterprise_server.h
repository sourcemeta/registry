#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_

#include <sourcemeta/hydra/httpserver.h>

#include "enterprise_explorer.h"

#include <filesystem> // std::filesystem
#include <sstream>    // std::ostringstream

namespace sourcemeta::registry::enterprise {

auto on_index(const sourcemeta::hydra::http::ServerLogger &,
              const sourcemeta::hydra::http::ServerRequest &request,
              sourcemeta::hydra::http::ServerResponse &response) -> void {
  static const auto SERVER_TITLE{configuration().at("title").to_string()};
  static const auto SERVER_DESCRIPTION{
      configuration().at("description").to_string()};
  static const auto GENERATED_BASE_DIRECTORY{*(__global_data) / "generated"};
  explore_index(SERVER_TITLE, SERVER_DESCRIPTION, GENERATED_BASE_DIRECTORY,
                request, response);
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
  static const auto GENERATED_BASE_DIRECTORY{*(__global_data) / "generated"};
  const auto directory_path{sourcemeta::registry::path_join(
      GENERATED_BASE_DIRECTORY, request.path())};
  if (std::filesystem::is_directory(directory_path)) {
    explore_directory(directory_path, request, response);
    return;
  }

  sourcemeta::hydra::http::serve_file(
      GENERATED_BASE_DIRECTORY / "404.html", request, response,
      sourcemeta::hydra::http::Status::NOT_FOUND);
}

auto attach(sourcemeta::hydra::http::Server &server) -> void {
  server.route(sourcemeta::hydra::http::Method::GET, "/", on_index);
  server.route(sourcemeta::hydra::http::Method::GET, "/*", on_request);
  server.route(sourcemeta::hydra::http::Method::HEAD, "/*", on_request);
}

} // namespace sourcemeta::registry::enterprise

#endif
