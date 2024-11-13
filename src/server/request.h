#ifndef SOURCEMETA_REGISTRY_SERVER_REQUEST_H_
#define SOURCEMETA_REGISTRY_SERVER_REQUEST_H_

#include <sourcemeta/jsontoolkit/json.h>
#include <sourcemeta/jsontoolkit/jsonschema.h>

#include <sourcemeta/hydra/crypto.h>
#include <sourcemeta/hydra/http.h>
#include <sourcemeta/hydra/httpserver.h>

#include <cassert> // assert
#include <sstream> // std::ostringstream
#include <string>  // std::string

#include "error.h"

namespace sourcemeta::registry {

auto on_request(const std::string &schema_identifier,
                const sourcemeta::jsontoolkit::SchemaResolver &resolver,
                const sourcemeta::hydra::http::ServerLogger &logger,
                const sourcemeta::hydra::http::ServerRequest &request,
                sourcemeta::hydra::http::ServerResponse &response) -> void {
  const auto maybe_schema{resolver(schema_identifier)};
  if (!maybe_schema.has_value()) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
               "There is no schema at this URL");
    return;
  }

  std::ostringstream payload;
  sourcemeta::jsontoolkit::prettify(
      maybe_schema.value(), payload,
      sourcemeta::jsontoolkit::schema_format_compare);

  std::ostringstream hash;
  sourcemeta::hydra::md5(payload.str(), hash);

  if (!request.header_if_none_match(hash.str())) {
    response.status(sourcemeta::hydra::http::Status::NOT_MODIFIED);
    response.end();
    return;
  }

  response.status(sourcemeta::hydra::http::Status::OK);
  response.header("Content-Type", "application/schema+json");

  // See
  // https://json-schema.org/draft/2020-12/json-schema-core.html#section-9.5.1.1
  const auto dialect{sourcemeta::jsontoolkit::dialect(maybe_schema.value())};
  assert(dialect.has_value());
  std::ostringstream link;
  link << "<" << dialect.value() << ">; rel=\"describedby\"";
  response.header("Link", link.str());

  // For HTTP caching, we only rely on ETag hashes, as Last-Modified
  // can be tricky to obtain in all cases.
  response.header_etag(hash.str());

  if (request.method() == sourcemeta::hydra::http::Method::HEAD) {
    response.head(payload.str());
    return;
  } else {
    response.end(payload.str());
    return;
  }
}

} // namespace sourcemeta::registry

#endif
