#include <sourcemeta/hydra/http.h>

#include "httpserver.h"

#include <sourcemeta/registry/license.h>

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>

#include "configure.h"

#include <algorithm>   // std::search
#include <cassert>     // assert
#include <cctype>      // std::tolower
#include <cstdint>     // std::uint32_t, std::int64_t
#include <exception>   // std::exception_ptr, std::rethrow_exception
#include <filesystem>  // std::filesystem
#include <iostream>    // std::cerr, std::cout
#include <memory>      // std::unique_ptr
#include <optional>    // std::optional, std::nullopt
#include <sstream>     // std::ostringstream
#include <string>      // std::string, std::getline
#include <string_view> // std::string_view
#include <utility>     // std::move

static inline std::unique_ptr<const std::filesystem::path> __global_data;
static auto configuration() -> const sourcemeta::core::JSON & {
  static auto document{
      sourcemeta::core::read_json(*(__global_data) / "configuration.json")};
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

static auto schema_directory(const bool bundle, const bool unidentify) noexcept
    -> std::filesystem::path {
  if (unidentify) {
    return "unidentified";
  } else if (bundle) {
    return "bundles";
  } else {
    return "schemas";
  }
}

static auto resolver(std::string_view identifier, const bool bundle,
                     const bool unidentify)
    -> std::optional<sourcemeta::core::JSON> {
  static const auto SERVER_BASE_URL{
      sourcemeta::core::URI{configuration().at("url").to_string()}
          .canonicalize()};
  sourcemeta::core::URI uri{std::string{identifier}};
  uri.canonicalize().relative_to(SERVER_BASE_URL);

  // If so, this URI doesn't belong to us
  if (uri.is_absolute() || uri.empty()) {
    return sourcemeta::core::schema_official_resolver(identifier);
  }

  assert(uri.path().has_value());
  const auto schema_path{
      path_join(*(__global_data) / schema_directory(bundle, unidentify),
                uri.path().value())};
  if (!std::filesystem::exists(schema_path)) {
    return std::nullopt;
  }

  return sourcemeta::core::read_json(schema_path);
}

static auto json_error(const ServerLogger &logger, uWS::HttpRequest *,
                       ServerResponse &response,
                       const sourcemeta::hydra::http::Status code,
                       std::string &&id, std::string &&message) -> void {
  auto object{sourcemeta::core::JSON::make_object()};
  object.assign("request", sourcemeta::core::JSON{logger.identifier});
  object.assign("error", sourcemeta::core::JSON{std::move(id)});
  object.assign("message", sourcemeta::core::JSON{std::move(message)});
  object.assign("code",
                sourcemeta::core::JSON{static_cast<std::int64_t>(code)});
  response.status = code;
  response.header("Content-Type", "application/json");

  std::ostringstream output;
  sourcemeta::core::prettify(object, output);
  response.end(output.str());
}

auto on_index(const ServerLogger &, uWS::HttpRequest *request,
              ServerResponse &response) -> void {
  serve_file(*(__global_data) / "generated" / "index.html", request, response);
}

auto on_search(const ServerLogger &logger, uWS::HttpRequest *request,
               ServerResponse &response) -> void {
  const auto query{request->getQuery("q")};
  if (query.empty()) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::BAD_REQUEST, "missing-query",
               "You must provide a query parameter to search for");
    return;
  }

  auto result{sourcemeta::core::JSON::make_array()};
  auto stream = sourcemeta::core::read_file(*(__global_data) / "search.jsonl");
  stream.exceptions(std::ifstream::badbit);
  // TODO: Extend the Core JSONL iterators to be able
  // to access the stringified contents of the current entry
  // BEFORE parsing it as JSON, letting the client decide
  // whether to parse or not.
  std::string line;
  while (std::getline(stream, line)) {
    if (std::search(line.cbegin(), line.cend(), query.begin(), query.end(),
                    [](const auto left, const auto right) {
                      return std::tolower(left) == std::tolower(right);
                    }) == line.cend()) {
      continue;
    }

    auto entry{sourcemeta::core::JSON::make_object()};
    auto line_json{sourcemeta::core::parse_json(line)};
    entry.assign("url", std::move(line_json.at(0)));
    entry.assign("title", std::move(line_json.at(1)));
    entry.assign("description", std::move(line_json.at(2)));
    result.push_back(std::move(entry));

    constexpr auto MAXIMUM_SEARCH_COUNT{10};
    if (result.array_size() >= MAXIMUM_SEARCH_COUNT) {
      break;
    }
  }

  response.status = sourcemeta::hydra::http::Status::OK;

  std::ostringstream output;
  sourcemeta::core::prettify(result, output);
  response.end(output.str());
}

static auto on_static(const ServerLogger &logger, uWS::HttpRequest *request,
                      ServerResponse &response) -> void {
  std::ostringstream asset_path;
  asset_path << SOURCEMETA_REGISTRY_STATIC;
  asset_path << request->getUrl().substr(7);
  if (!std::filesystem::exists(asset_path.str())) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
               "There is no schema at this URL");
    return;
  }

  serve_file(asset_path.str(), request, response);
}

static auto on_request(const ServerLogger &logger, uWS::HttpRequest *request,
                       ServerResponse &response) -> void {
  std::string request_path{request->getUrl()};
  std::transform(
      request_path.begin(), request_path.end(), request_path.begin(),
      [](const unsigned char character) { return std::tolower(character); });

  if (!request_path.ends_with(".json")) {
    const auto directory_path{
        path_join(*(__global_data) / "generated", request_path)};
    if (std::filesystem::is_directory(directory_path)) {
      serve_file(directory_path / "index.html", request, response);
    } else {
      serve_file(*(__global_data) / "generated" / "404.html", request, response,
                 sourcemeta::hydra::http::Status::NOT_FOUND);
    }

    return;
  }

  const auto bundle{!request->getQuery("bundle").empty()};
  const auto unidentify{!request->getQuery("unidentify").empty()};

  const auto metadata_path{
      path_join(*(__global_data) / schema_directory(bundle, unidentify),
                request_path + ".meta")};
  if (!std::filesystem::exists(metadata_path)) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
               "There is no schema at this URL");
    return;
  }

  const auto metadata{sourcemeta::core::read_json(metadata_path)};

  // Because Visual Studio Code famously does not support `$id` or `id`
  // See https://github.com/microsoft/vscode-json-languageservice/issues/224
  const auto user_agent{request->getHeader("user-agent")};
  const auto is_vscode{user_agent.starts_with("Visual Studio Code") ||
                       user_agent.starts_with("VSCodium")};

  const auto maybe_schema{resolver(metadata.at("id").to_string(),
                                   is_vscode || bundle,
                                   is_vscode || unidentify)};
  if (!maybe_schema.has_value()) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
               "There is no schema at this URL");
    return;
  }

  const auto hash{metadata.at("md5").to_string()};
  if (!header_if_none_match(request, hash)) {
    response.status = sourcemeta::hydra::http::Status::NOT_MODIFIED;
    response.end();
    return;
  }

  response.status = sourcemeta::hydra::http::Status::OK;
  response.header("Content-Type", metadata.at("mime").to_string());
  // See
  // https://json-schema.org/draft/2020-12/json-schema-core.html#section-9.5.1.1
  std::ostringstream link;
  link << "<" << metadata.at("dialect").to_string() << ">; rel=\"describedby\"";
  response.header("Link", link.str());
  response.header("ETag", std::string{'"'} + hash + '"');
  // TODO: Test this
  response.header("Last-Modified", metadata.at("lastModified").to_string());

  std::ostringstream payload;
  sourcemeta::core::prettify(maybe_schema.value(), payload,
                             sourcemeta::core::schema_format_compare);
  if (request->getMethod() == "head") {
    response.head(payload.str());
    return;
  } else {
    response.end(payload.str());
    return;
  }
}

static auto on_otherwise(const ServerLogger &logger, uWS::HttpRequest *request,
                         ServerResponse &response) -> void {
  if (request->getUrl().starts_with("/api/")) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::METHOD_NOT_ALLOWED,
               "method-not-allowed",
               "This HTTP method is invalid for this URL");
    return;
  }

  if (request->getUrl().ends_with(".json")) {
    const auto metadata_path{
        path_join(*(__global_data) / schema_directory(false, false),
                  std::string{request->getUrl()} + ".meta")};
    if (std::filesystem::exists(metadata_path)) {
      json_error(logger, request, response,
                 sourcemeta::hydra::http::Status::METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
      return;
    }
  }

  json_error(logger, request, response,
             sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
             "There is no schema at this URL");
}

static auto on_error(std::exception_ptr exception_ptr,
                     const ServerLogger &logger, uWS::HttpRequest *request,
                     ServerResponse &response) noexcept -> void {
  try {
    std::rethrow_exception(exception_ptr);
  } catch (const sourcemeta::core::SchemaResolutionError &error) {
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
#if defined(SOURCEMETA_REGISTRY_ENTERPRISE)
  std::cout << " Enterprise ";
#elif defined(SOURCEMETA_REGISTRY_PRO)
  std::cout << " Pro ";
#else
  std::cout << " Starter ";
#endif
  std::cout << "Edition\n";

  try {
    if (argc < 2) {
      std::cout << "Usage: " << argv[0] << " <path/to/output/directory>\n";
      return EXIT_FAILURE;
    }

    if (!sourcemeta::registry::license_permitted()) {
      std::cerr << sourcemeta::registry::license_error();
      return EXIT_FAILURE;
    }

    __global_data = std::make_unique<std::filesystem::path>(
        std::filesystem::canonical(argv[1]));

    Server server;
    server.route(sourcemeta::hydra::http::Method::GET, "/", on_index);
    server.route(sourcemeta::hydra::http::Method::GET, "/api/search",
                 on_search);
    server.route(sourcemeta::hydra::http::Method::GET, "/static/*", on_static);
    server.route(sourcemeta::hydra::http::Method::HEAD, "/static/*", on_static);
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
