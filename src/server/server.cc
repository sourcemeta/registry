#include <sourcemeta/hydra/httpserver.h>

#include <sourcemeta/jsontoolkit/json.h>
#include <sourcemeta/jsontoolkit/jsonschema.h>
#include <sourcemeta/jsontoolkit/uri.h>

#include "configure.h"
#include "error.h"
#include "request.h"
#include "resolver.h"

#include <cassert>    // assert
#include <cstdint>    // std::uint32_t
#include <filesystem> // std::filesystem
#include <iostream>   // std::cerr, std::cout
#include <memory>     // std::unique_ptr

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

static auto on_otherwise(const sourcemeta::hydra::http::ServerLogger &logger,
                         const sourcemeta::hydra::http::ServerRequest &request,
                         sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  static const auto SERVER_BASE_URL{configuration().at("url").to_string()};
  const auto maybe_schema{
      resolver(sourcemeta::registry::request_path_to_schema_uri(
          SERVER_BASE_URL, request.path()))};
  return sourcemeta::registry::on_otherwise(maybe_schema, logger, request,
                                            response);
}

static auto on_request(const sourcemeta::hydra::http::ServerLogger &logger,
                       const sourcemeta::hydra::http::ServerRequest &request,
                       sourcemeta::hydra::http::ServerResponse &response)
    -> void {
  static const auto SERVER_BASE_URL{configuration().at("url").to_string()};
  return sourcemeta::registry::on_request(
      sourcemeta::registry::request_path_to_schema_uri(SERVER_BASE_URL,
                                                       request.path()),
      resolver, logger, request, response);
}

// We try to keep this function as straight to point as possible
// with minimal input validation (outside debug builds). The intention
// is for the server to start running and bind to the port as quickly
// as possible, so we can take better advantage of scale-to-zero.
auto main(int argc, char *argv[]) noexcept -> int {
  try {
    if (argc < 2) {
      std::cerr << "Sourcemeta Registry v"
                << sourcemeta::registry::PROJECT_VERSION;
#ifdef SOURCEMETA_REGISTRY_ENTERPRISE
      std::cout << " Enterprise ";
#else
      std::cout << " Community ";
#endif
      std::cout << "Edition\n";
      std::cout << "Usage: " << argv[0]
                << " <configuration.json> <path/to/output/directory>\n";
      return EXIT_FAILURE;
    }

    __global_data = std::make_unique<std::filesystem::path>(argv[1]);

    sourcemeta::hydra::http::Server server;
    server.route(sourcemeta::hydra::http::Method::GET, "/*", on_request);
    server.route(sourcemeta::hydra::http::Method::HEAD, "/*", on_request);
    server.otherwise(on_otherwise);
    server.error(sourcemeta::registry::on_error);

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
