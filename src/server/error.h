#ifndef SOURCEMETA_REGISTRY_SERVER_ERROR_H_
#define SOURCEMETA_REGISTRY_SERVER_ERROR_H_

#include <sourcemeta/hydra/http.h>
#include <sourcemeta/hydra/httpserver.h>

#include <sourcemeta/jsontoolkit/json.h>

#include <cstdint>   // std::int64_t
#include <exception> // std::exception_ptr, std::rethrow_exception
#include <optional>  // std::optional
#include <sstream>   // std::ostringstream
#include <string>    // std::string
#include <utility>   // std::move

namespace sourcemeta::registry {

auto json_error(const sourcemeta::hydra::http::ServerLogger &logger,
                const sourcemeta::hydra::http::ServerRequest &,
                sourcemeta::hydra::http::ServerResponse &response,
                const sourcemeta::hydra::http::Status code, std::string &&id,
                std::string &&message) -> void {
  auto object{sourcemeta::jsontoolkit::JSON::make_object()};
  object.assign("request", sourcemeta::jsontoolkit::JSON{logger.id()});
  object.assign("error", sourcemeta::jsontoolkit::JSON{std::move(id)});
  object.assign("message", sourcemeta::jsontoolkit::JSON{std::move(message)});
  object.assign("code",
                sourcemeta::jsontoolkit::JSON{static_cast<std::int64_t>(code)});
  response.status(code);
  response.header("Content-Type", "application/json");
  response.end(std::move(object));
}

auto on_error(std::exception_ptr exception_ptr,
              const sourcemeta::hydra::http::ServerLogger &logger,
              const sourcemeta::hydra::http::ServerRequest &request,
              sourcemeta::hydra::http::ServerResponse &response) noexcept
    -> void {
  try {
    std::rethrow_exception(exception_ptr);
  } catch (const sourcemeta::jsontoolkit::SchemaResolutionError &error) {
    std::ostringstream message;
    message << error.what() << ": " << error.id();
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::BAD_REQUEST,
               "schema-resolution-error", message.str());
  } catch (const std::exception &error) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::METHOD_NOT_ALLOWED,
               "uncaught-error", error.what());
  }
}

auto on_otherwise(const std::optional<sourcemeta::jsontoolkit::JSON> &schema,
                  const sourcemeta::hydra::http::ServerLogger &logger,
                  const sourcemeta::hydra::http::ServerRequest &request,
                  sourcemeta::hydra::http::ServerResponse &response) -> void {
  if (schema.has_value()) {
    sourcemeta::registry::json_error(
        logger, request, response,
        sourcemeta::hydra::http::Status::METHOD_NOT_ALLOWED,
        "method-not-allowed", "This HTTP method is invalid for this URL");
  } else {
    sourcemeta::registry::json_error(
        logger, request, response, sourcemeta::hydra::http::Status::NOT_FOUND,
        "not-found", "There is no schema at this URL");
  }
}

} // namespace sourcemeta::registry

#endif
