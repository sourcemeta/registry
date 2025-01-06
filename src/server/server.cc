#include <sourcemeta/hydra/crypto.h>
#include <sourcemeta/hydra/http.h>
#include <sourcemeta/hydra/httpserver.h>

#include <sourcemeta/jsontoolkit/json.h>
#include <sourcemeta/jsontoolkit/jsonschema.h>
#include <sourcemeta/jsontoolkit/uri.h>

#include "configure.h"
#include "resolver.h"

#include <cassert>    // assert
#include <cstdint>    // std::uint32_t, std::int64_t
#include <exception>  // std::exception_ptr, std::rethrow_exception
#include <filesystem> // std::filesystem
#include <iostream>   // std::cerr, std::cout
#include <memory>     // std::unique_ptr
#include <optional>   // std::optional
#include <sstream>    // std::ostringstream
#include <string>     // std::string
#include <utility>    // std::move

static inline std::unique_ptr<const std::filesystem::path> __global_data;
static auto configuration() -> const sourcemeta::jsontoolkit::JSON & {
  static auto document{sourcemeta::jsontoolkit::from_file(
      *(__global_data) / "configuration.json")};
  return document;
}

static auto resolver(std::string_view identifier)
    -> std::optional<sourcemeta::jsontoolkit::JSON> {
  static const auto SERVER_BASE_URL{
      sourcemeta::jsontoolkit::URI{configuration().at("url").to_string()}
          .canonicalize()};
  return sourcemeta::registry::resolver(
      SERVER_BASE_URL, *(__global_data) / "schemas", identifier);
}

static auto json_error(const sourcemeta::hydra::http::ServerLogger &logger,
                       const sourcemeta::hydra::http::ServerRequest &,
                       sourcemeta::hydra::http::ServerResponse &response,
                       const sourcemeta::hydra::http::Status code,
                       std::string &&id, std::string &&message) -> void {
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

static auto on_request(const sourcemeta::hydra::http::ServerLogger &logger,
                       const sourcemeta::hydra::http::ServerRequest &request,
                       sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  const auto schema_identifier{sourcemeta::registry::request_path_to_schema_uri(
      configuration().at("url").to_string(), request.path())};
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

static auto on_otherwise(const sourcemeta::hydra::http::ServerLogger &logger,
                         const sourcemeta::hydra::http::ServerRequest &request,
                         sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  static const auto SERVER_BASE_URL{configuration().at("url").to_string()};
  const auto maybe_schema{
      resolver(sourcemeta::registry::request_path_to_schema_uri(
          SERVER_BASE_URL, request.path()))};

  if (maybe_schema.has_value()) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::METHOD_NOT_ALLOWED,
               "method-not-allowed",
               "This HTTP method is invalid for this URL");
  } else {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
               "There is no schema at this URL");
  }
}

static auto on_error(std::exception_ptr exception_ptr,
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

#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
#include "enterprise_server.h"
#endif

// We try to keep this function as straight to point as possible
// with minimal input validation (outside debug builds). The intention
// is for the server to start running and bind to the port as quickly
// as possible, so we can take better advantage of scale-to-zero.
auto main(int argc, char *argv[]) noexcept -> int {
  std::cerr << "Sourcemeta Registry v" << sourcemeta::registry::PROJECT_VERSION;
#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
  std::cout << " Enterprise ";
#else
  std::cout << " Community ";
#endif
  std::cout << "Edition\n";

  try {
    if (argc < 2) {
      std::cout << "Usage: " << argv[0]
                << " <configuration.json> <path/to/output/directory>\n";
      return EXIT_FAILURE;
    }

    __global_data = std::make_unique<std::filesystem::path>(
        std::filesystem::canonical(argv[1]));

    sourcemeta::hydra::http::Server server;
#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
    sourcemeta::registry::enterprise::attach(server);
#else
    server.route(sourcemeta::hydra::http::Method::GET, "/*", on_request);
    server.route(sourcemeta::hydra::http::Method::HEAD, "/*", on_request);
#endif
    server.otherwise(on_otherwise);
    server.error(on_error);

    assert(configuration().defines("port"));
    assert(configuration().at("port").is_integer());
    assert(configuration().at("port").is_positive());
    return server.run(
        static_cast<std::uint32_t>(configuration().at("port").to_integer()));
  } catch (const std::exception &error) {
    std::cerr << "unexpected error: " << error.what() << "\n";
    return EXIT_FAILURE;
  }
}
