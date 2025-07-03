#include <sourcemeta/core/json.h>
#include <sourcemeta/hydra/http.h>
#include <sourcemeta/registry/license.h>

#include "configure.h"
#include "httpserver.h"

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

class ServerLogger {
public:
  auto operator<<(std::string_view message) const -> void {
    // Otherwise we can get messed up output interleaved from multiple threads
    static std::mutex log_mutex;
    std::lock_guard<std::mutex> guard{log_mutex};
    std::cerr << "["
              << sourcemeta::hydra::http::to_gmt(
                     std::chrono::system_clock::now())
              << "] " << std::this_thread::get_id() << " (" << this->identifier
              << ") " << message << "\n";
  }

  const std::string identifier;
};

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
  serve_file(*(__global_data) / "explorer" / "pages.html", request, response);
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
  auto stream = sourcemeta::core::read_file(*(__global_data) / "explorer" /
                                            "search.jsonl");
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

  const auto metadata_path{asset_path.str() + ".meta"};
  if (!std::filesystem::exists(metadata_path)) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
               "There is no schema at this URL");
    return;
  }

  assert(std::filesystem::exists(asset_path.str()));
  const auto metadata{sourcemeta::core::read_json(metadata_path)};
  const auto &last_modified{metadata.at("lastModified").to_string()};
  const auto &hash{metadata.at("md5").to_string()};

  if (!header_if_modified_since(
          request, sourcemeta::hydra::http::from_gmt(last_modified))) {
    response.status = sourcemeta::hydra::http::Status::NOT_MODIFIED;
    response.end();
    return;
  } else if (!header_if_none_match(request, hash)) {
    response.status = sourcemeta::hydra::http::Status::NOT_MODIFIED;
    response.end();
    return;
  }

  response.status = sourcemeta::hydra::http::Status::OK;
  response.header("Content-Type", metadata.at("mime").to_string());
  response.header("ETag", std::string{'"'} + hash + '"');
  response.header("Last-Modified", last_modified);

  std::ifstream stream{std::filesystem::canonical(asset_path.str())};
  stream.exceptions(std::ifstream::failbit | std::ifstream::badbit);
  assert(!stream.fail());
  assert(stream.is_open());
  std::ostringstream contents;
  contents << stream.rdbuf();
  if (request->getMethod() == "head") {
    response.head(contents.str());
  } else {
    response.end(contents.str());
  }
}

static auto get_schema_path(uWS::HttpRequest *request,
                            const std::string &request_path) noexcept
    -> std::filesystem::path {
  // Because Visual Studio Code famously does not support `$id` or `id`
  // See https://github.com/microsoft/vscode-json-languageservice/issues/224
  const auto &user_agent{request->getHeader("user-agent")};
  const auto is_vscode{user_agent.starts_with("Visual Studio Code") ||
                       user_agent.starts_with("VSCodium")};
  const auto bundle{!request->getQuery("bundle").empty()};
  const auto unidentify{!request->getQuery("unidentify").empty()};

  if (unidentify || is_vscode) {
    return std::filesystem::path{"schemas"} /
           (request_path.substr(1) + ".unidentified");
  } else if (bundle) {
    return std::filesystem::path{"schemas"} /
           (request_path.substr(1) + ".bundle");
  } else {
    return std::filesystem::path{"schemas"} /
           (request_path.substr(1) + ".schema");
  }
}

static auto read_schema(uWS::HttpRequest *request) -> std::optional<
    std::pair<sourcemeta::core::JSON, sourcemeta::core::JSON>> {
  std::string request_path{request->getUrl()};
  // Otherwise we may get unexpected results in case-sensitive file-systems
  std::transform(
      request_path.begin(), request_path.end(), request_path.begin(),
      [](const unsigned char character) { return std::tolower(character); });
  const auto schema_path{*(__global_data) /
                         get_schema_path(request, request_path)};
  if (!std::filesystem::exists(schema_path)) {
    return std::nullopt;
  }

  const auto metadata_path{schema_path.string() + ".meta"};
  assert(std::filesystem::exists(metadata_path));
  return std::make_pair(sourcemeta::core::read_json(metadata_path),
                        sourcemeta::core::read_json(schema_path));
}

static auto on_request(const ServerLogger &logger, uWS::HttpRequest *request,
                       ServerResponse &response) -> void {
  std::string request_path{request->getUrl()};
  std::transform(
      request_path.begin(), request_path.end(), request_path.begin(),
      [](const unsigned char character) { return std::tolower(character); });

  if (!request_path.ends_with(".json")) {
    const auto directory_path{*(__global_data) / "explorer" / "pages" /
                              (request_path.substr(1) + ".html")};
    if (std::filesystem::exists(directory_path)) {
      serve_file(directory_path, request, response);
    } else {
      serve_file(*(__global_data) / "explorer" / "404.html", request, response,
                 sourcemeta::hydra::http::Status::NOT_FOUND);
    }

    return;
  }

  const auto schema{read_schema(request)};
  if (!schema.has_value()) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
               "There is no schema at this URL");
    return;
  }

  const auto &metadata{schema.value().first};
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
  sourcemeta::core::prettify(schema.value().second, payload);
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
    const auto schema{read_schema(request)};
    if (schema.has_value()) {
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

static auto
middleware(uWS::HttpResponse<true> *const response_handler,
           uWS::HttpRequest *const request,
           const std::function<void(const ServerLogger &, uWS::HttpRequest *,
                                    ServerResponse &)> &callback) noexcept
    -> void {
  // These should never throw, otherwise we cannot even react to errors
  ServerLogger logger{sourcemeta::core::uuidv4()};
  ServerResponse response{response_handler};

  // For easy tracking
  response.header("X-Request-Id", logger.identifier);

  try {
    // Attempt automatic content encoding negotiation, which the user can always
    // manually override later on in their request callback
    const bool can_satisfy_requested_content_encoding{
        negotiate_content_encoding(request, response)};
    if (can_satisfy_requested_content_encoding) {
      callback(logger, request, response);
    } else {
      response.status = sourcemeta::hydra::http::Status::NOT_ACCEPTABLE;
      response.end();
    }
  } catch (const std::exception &error) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::METHOD_NOT_ALLOWED,
               "uncaught-error", error.what());
  }

  std::ostringstream line;
  line << response.status << ' ' << request->getMethod() << ' '
       << request->getUrl();
  logger << line.str();
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

    const auto configuration{
        sourcemeta::core::read_json(*__global_data / "configuration.json")};
    assert(configuration.defines("port"));
    assert(configuration.at("port").is_integer());
    assert(configuration.at("port").is_positive());
    const auto port{
        static_cast<std::uint32_t>(configuration.at("port").to_integer())};

    ServerLogger logger{"global"};
    uWS::LocalCluster({}, [port, &logger](uWS::SSLApp &app) -> void {
#define UWS_CALLBACK(callback_name)                                            \
  [](auto *const response, auto *const request) noexcept -> void {             \
    middleware(response, request, (callback_name));                            \
  }
      app.get("/", UWS_CALLBACK(on_index));
      app.get("/api/search", UWS_CALLBACK(on_search));
      app.get("/static/*", UWS_CALLBACK(on_static));
      app.head("/static/*", UWS_CALLBACK(on_static));
      app.get("/*", UWS_CALLBACK(on_request));
      app.head("/*", UWS_CALLBACK(on_request));
      app.any("/*", UWS_CALLBACK(on_otherwise));
#undef UWS_CALLBACK
      app.listen(static_cast<int>(port),
                 [port, &logger](us_listen_socket_t *const socket) -> void {
                   if (socket) {
                     const auto socket_port = us_socket_local_port(
                         true, reinterpret_cast<struct us_socket_t *>(socket));
                     assert(socket_port > 0);
                     assert(port == static_cast<std::uint32_t>(socket_port));
                     logger
                         << "Listening on port " + std::to_string(socket_port);
                   } else {
                     logger
                         << "Failed to listen on port " + std::to_string(port);
                   }
                 });
    });

    logger << "Failed to listen on port " + std::to_string(port);
    return EXIT_FAILURE;
  } catch (const std::exception &error) {
    std::cerr << "unexpected error: " << error.what() << "\n";
    return EXIT_FAILURE;
  }
}
