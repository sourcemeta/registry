#ifndef SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_
#define SOURCEMETA_REGISTRY_ENTERPRISE_SERVER_H_

#include <sourcemeta/hydra/httpserver.h>

namespace sourcemeta::registry::enterprise {

auto attach(sourcemeta::hydra::http::Server &server) -> void {
  server.route(sourcemeta::hydra::http::Method::GET, "/*", ::on_request);
  server.route(sourcemeta::hydra::http::Method::HEAD, "/*", ::on_request);
  server.otherwise(::on_otherwise);
  server.error(sourcemeta::registry::on_error);
}

} // namespace sourcemeta::registry::enterprise

#endif
