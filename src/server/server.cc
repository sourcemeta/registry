#include <sourcemeta/hydra/crypto.h>
#include <sourcemeta/hydra/http.h>
#include <sourcemeta/hydra/httpserver.h>

#include <sourcemeta/jsontoolkit/json.h>
#include <sourcemeta/jsontoolkit/jsonschema.h>
#include <sourcemeta/jsontoolkit/uri.h>

#include "configure.h"

#include <cassert>     // assert
#include <cctype>      // std::tolower
#include <cstdint>     // std::uint32_t, std::int64_t
#include <exception>   // std::exception_ptr, std::rethrow_exception
#include <filesystem>  // std::filesystem
#include <iostream>    // std::cerr, std::cout
#include <memory>      // std::unique_ptr
#include <optional>    // std::optional, std::nullopt
#include <sstream>     // std::ostringstream
#include <string>      // std::string
#include <string_view> // std::string_view
#include <utility>     // std::move

static inline std::unique_ptr<const std::filesystem::path> __global_data;
static auto configuration() -> const sourcemeta::jsontoolkit::JSON & {
  static auto document{sourcemeta::jsontoolkit::from_file(
      *(__global_data) / "configuration.json")};
  return document;
}

static auto path_join(const std::filesystem::path &base,
                      const std::filesystem::path &path)
    -> std::filesystem::path {
  if (path.is_absolute()) {
    return (base / path.string().substr(1)).lexically_normal();
  }

  return (base / path).lexically_normal();
}

static auto request_path_to_schema_uri(const std::string &server_base_url,
                                       const std::string &request_path)
    -> std::string {
  assert(request_path.starts_with('/'));
  assert(!server_base_url.ends_with('/'));
  std::ostringstream schema_identifier;
  schema_identifier << server_base_url;
  // TODO: Can we avoid this copy?
  auto path_copy{request_path};
  path_copy.erase(path_copy.find_last_not_of('/') + 1);
  for (const auto character : path_copy) {
    schema_identifier << static_cast<char>(std::tolower(character));
  }

  if (request_path != "/" && !schema_identifier.str().ends_with(".json")) {
    schema_identifier << ".json";
  }

  return schema_identifier.str();
}

static auto resolver(std::string_view identifier)
    -> std::optional<sourcemeta::jsontoolkit::JSON> {
  static const auto SERVER_BASE_URL{
      sourcemeta::jsontoolkit::URI{configuration().at("url").to_string()}
          .canonicalize()};
  sourcemeta::jsontoolkit::URI uri{std::string{identifier}};
  uri.canonicalize().relative_to(SERVER_BASE_URL);

  // If so, this URI doesn't belong to us
  // TODO: Have a more efficient way of checking that a URI is blank
  if (uri.is_absolute() || uri.recompose().empty()) {
    return sourcemeta::jsontoolkit::official_resolver(identifier);
  }

  assert(uri.path().has_value());
  const auto schema_path{
      path_join(*(__global_data) / "schemas", uri.path().value())};
  if (!std::filesystem::exists(schema_path)) {
    return std::nullopt;
  }

  return sourcemeta::jsontoolkit::from_file(schema_path);
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

#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
auto on_index(const sourcemeta::hydra::http::ServerLogger &,
              const sourcemeta::hydra::http::ServerRequest &request,
              sourcemeta::hydra::http::ServerResponse &response) -> void {
  sourcemeta::hydra::http::serve_file(
      *(__global_data) / "generated" / "index.html", request, response);
}
#endif

static auto on_request(const sourcemeta::hydra::http::ServerLogger &logger,
                       const sourcemeta::hydra::http::ServerRequest &request,
                       sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  const auto &request_path{request.path()};

#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
  if (!request_path.ends_with(".json")) {
    const auto asset_path{SOURCEMETA_REGISTRY_ENTERPRISE_STATIC + request_path};
    if (std::filesystem::exists(asset_path)) {
      sourcemeta::hydra::http::serve_file(asset_path, request, response);
      return;
    }

    const auto directory_path{
        path_join(*(__global_data) / "generated", request.path())};
    if (std::filesystem::is_directory(directory_path)) {
      sourcemeta::hydra::http::serve_file(directory_path / "index.html",
                                          request, response);
    } else {
      sourcemeta::hydra::http::serve_file(
          *(__global_data) / "generated" / "404.html", request, response,
          sourcemeta::hydra::http::Status::NOT_FOUND);
    }

    return;
  }
#endif

  const auto schema_identifier{request_path_to_schema_uri(
      configuration().at("url").to_string(), request_path)};
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
  const auto maybe_schema{resolver(request_path_to_schema_uri(
      configuration().at("url").to_string(), request.path()))};

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
    server.route(sourcemeta::hydra::http::Method::GET, "/", on_index);
#endif
    server.route(sourcemeta::hydra::http::Method::GET, "/*", on_request);
    server.route(sourcemeta::hydra::http::Method::HEAD, "/*", on_request);
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
