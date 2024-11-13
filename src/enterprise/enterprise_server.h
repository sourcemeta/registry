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
  static const auto SERVER_BASE_URL{configuration().at("url").to_string()};
  static const auto SERVER_TITLE{configuration().at("title").to_string()};
  static const auto SERVER_DESCRIPTION{
      configuration().at("description").to_string()};
  static const auto SCHEMAS_BASE_DIRECTORY{*(__global_data) / "schemas"};
  explore_index(SERVER_TITLE, SERVER_TITLE, SERVER_DESCRIPTION, SERVER_BASE_URL,
                SCHEMAS_BASE_DIRECTORY, request, response);
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

  static const auto SERVER_TITLE{configuration().at("title").to_string()};

  // Explorer
  static const auto SCHEMAS_BASE_DIRECTORY{*(__global_data) / "schemas"};
  const auto directory_path{
      sourcemeta::registry::path_join(SCHEMAS_BASE_DIRECTORY, request.path())};
  if (std::filesystem::is_directory(directory_path)) {
    static const auto SERVER_BASE_URL{configuration().at("url").to_string()};
    explore_directory(SERVER_TITLE, directory_path, SERVER_BASE_URL, request,
                      response);
    return;
  }

  static const auto SERVER_BASE_URL{configuration().at("url").to_string()};
  explore_not_found(SERVER_TITLE, SERVER_BASE_URL, request, response);
}

auto attach(sourcemeta::hydra::http::Server &server) -> void {
  server.route(sourcemeta::hydra::http::Method::GET, "/", on_index);
  server.route(sourcemeta::hydra::http::Method::GET, "/*", on_request);
  server.route(sourcemeta::hydra::http::Method::HEAD, "/*", on_request);
  server.otherwise(::on_otherwise);
  server.error(sourcemeta::registry::on_error);
}

} // namespace sourcemeta::registry::enterprise

#endif
