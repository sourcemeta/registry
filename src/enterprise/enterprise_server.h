#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_

#include <sourcemeta/hydra/httpserver.h>

#include "enterprise_explorer.h"

#include <filesystem> // std::filesystem

namespace sourcemeta::registry::enterprise {

auto on_index(const sourcemeta::hydra::http::ServerLogger &,
              const sourcemeta::hydra::http::ServerRequest &,
              sourcemeta::hydra::http::ServerResponse &response) -> void {
  explore_index(response);
}

auto on_request(const sourcemeta::hydra::http::ServerLogger &logger,
                const sourcemeta::hydra::http::ServerRequest &request,
                sourcemeta::hydra::http::ServerResponse &response) -> void {
  const auto extension{std::filesystem::path{request.path()}.extension()};
  if (extension == ".json") {
    return ::on_request(logger, request, response);
  }

  explore_not_found(response);
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
