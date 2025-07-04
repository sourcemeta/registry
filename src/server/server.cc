#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/uuid.h>

#include <sourcemeta/hydra/http.h>

#include <sourcemeta/registry/license.h>

#include "uwebsockets.h"

#include "configure.h"
#include "logger.h"
#include "reader.h"
#include "search.h"

#include <cassert>     // assert
#include <cctype>      // std::tolower
#include <chrono>      // std::chrono::system_clock
#include <cstdint>     // std::uint32_t, std::int64_t
#include <cstdlib>     // EXIT_FAILURE
#include <filesystem>  // std::filesystem
#include <iostream>    // std::cerr, std::cout
#include <map>         // std::map
#include <sstream>     // std::ostringstream
#include <stdexcept>   // std::invalid_argument
#include <string>      // std::string
#include <string_view> // std::string_view
#include <utility>     // std::move

// TODO: Get rid of this
enum class ServerContentEncoding { Identity, GZIP };

// TODO: Simplify
class ServerResponse {
public:
  ServerResponse(uWS::HttpResponse<true> *data) : handler{data} {
    assert(this->handler);
  }

  ~ServerResponse() {}

  auto header(std::string_view key, std::string_view value) -> void {
    this->headers.emplace(key, value);
  }

  auto end(const std::string_view message) -> void {
    std::ostringstream code_string;
    code_string << this->status;
    this->handler->writeStatus(code_string.str());

    for (const auto &[key, value] : this->headers) {
      this->handler->writeHeader(key, value);
    }

    if (this->encoding == ServerContentEncoding::GZIP) {
      auto result{sourcemeta::core::gzip(message)};
      if (!result.has_value()) {
        throw std::runtime_error("Compression failed");
      }

      this->handler->end(result.value());
    } else if (this->encoding == ServerContentEncoding::Identity) {
      this->handler->end(message);
    }
  }

  auto head(const std::string_view message) -> void {
    std::ostringstream code_string;
    code_string << this->status;
    this->handler->writeStatus(code_string.str());

    for (const auto &[key, value] : this->headers) {
      this->handler->writeHeader(key, value);
    }

    if (this->encoding == ServerContentEncoding::GZIP) {
      auto result{sourcemeta::core::gzip(message)};
      if (!result.has_value()) {
        throw std::runtime_error("Compression failed");
      }

      this->handler->endWithoutBody(result.value().size());
      this->handler->end();
    } else if (this->encoding == ServerContentEncoding::Identity) {
      this->handler->endWithoutBody(message.size());
      this->handler->end();
    }
  }

  auto end() -> void {
    std::ostringstream code_string;
    code_string << this->status;
    this->handler->writeStatus(code_string.str());

    for (const auto &[key, value] : this->headers) {
      this->handler->writeHeader(key, value);
    }

    this->handler->end();
  }

  uWS::HttpResponse<true> *handler;
  sourcemeta::hydra::http::Status status{sourcemeta::hydra::http::Status::OK};
  ServerContentEncoding encoding{ServerContentEncoding::Identity};

private:
  std::map<std::string, std::string> headers;
};

// TODO: Simplify
static auto negotiate_content_encoding(uWS::HttpRequest *request,
                                       ServerResponse &response) -> bool {
  const auto accept_encoding{request->getHeader("accept-encoding")};
  if (accept_encoding.empty()) {
    return true;
  }

  for (const auto &encoding :
       sourcemeta::hydra::http::header_list(std::string{accept_encoding})) {
    if (encoding.second == 0.0f) {
      // The client explicitly prohibited the default encoding
      if (encoding.first == "*" || encoding.first == "identity") {
        return false;
      }

      continue;
    }

    assert(encoding.second > 0.0f);

    if (encoding.first == "identity") {
      return true;
    } else if (encoding.first == "*" || encoding.first == "gzip") {
      response.header("Content-Encoding", "gzip");
      response.encoding = ServerContentEncoding::GZIP;
      return true;
    }

    // For compatibility with previous implementations of HTTP, applications
    // SHOULD consider "x-gzip" [...] to be equivalent to "gzip".
    // See https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.5
    if (encoding.first == "x-gzip") {
      response.header("Content-Encoding", "gzip");
      response.encoding = ServerContentEncoding::GZIP;
      return true;
    }
  }

  // As long as the identity;q=0 or *;q=0 directives do not explicitly forbid
  // the identity value that means no encoding, the server must never return a
  // 406 Not Acceptable error. See
  // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Encoding
  return true;
}

static auto json_error(const sourcemeta::registry::Logger &logger,
                       uWS::HttpRequest *, ServerResponse &response,
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
  response.header("X-Request-Id", logger.identifier);

  std::ostringstream output;
  sourcemeta::core::prettify(object, output);
  response.end(output.str());
}

// TODO: Try to simplify and inline in serve_static_file
static auto header_if_modified_since(
    uWS::HttpRequest *handler,
    const std::chrono::system_clock::time_point last_modified) -> bool {
  // `If-Modified-Since` can only be used with a `GET` or `HEAD`.
  // See
  // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since
  if (handler->getMethod() != "get" && handler->getMethod() != "head") {
    return true;
  }

  try {
    const auto if_modified_since{handler->getHeader("if-modified-since")};
    // If the client didn't express a modification baseline to compare to,
    // then we just tell it that it has been modified
    if (if_modified_since.empty()) {
      return true;
    }

    // Time comparison can be flaky, but adding a bit of tolerance leads
    // to more consistent behavior.
    return (sourcemeta::hydra::http::header_gmt(
                std::string{if_modified_since}) +
            std::chrono::seconds(1)) < last_modified;
    // If there is an error parsing the `If-Modified-Since` timestamp, don't
    // abort, but lean on the safe side: the requested resource has been
    // modified
  } catch (const std::invalid_argument &) {
    return true;
  }
}

static auto serve_static_file(const sourcemeta::registry::Logger &logger,
                              uWS::HttpRequest *request,
                              ServerResponse &response,
                              const std::filesystem::path &absolute_path,
                              const sourcemeta::hydra::http::Status code)
    -> void {
  if (request->getMethod() != "get" && request->getMethod() != "head") {
    if (std::filesystem::exists(absolute_path)) {
      json_error(logger, request, response,
                 sourcemeta::hydra::http::Status::METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    } else {
      json_error(logger, request, response,
                 sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
                 "There is nothing at this URL");
    }

    return;
  }

  auto file{sourcemeta::registry::read_file(absolute_path)};
  if (!file.has_value()) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
               "There is nothing at this URL");
    return;
  }

  const auto &last_modified{file.value().meta.at("lastModified").to_string()};
  if (!header_if_modified_since(
          request, sourcemeta::hydra::http::from_gmt(last_modified))) {
    response.status = sourcemeta::hydra::http::Status::NOT_MODIFIED;
    response.header("X-Request-Id", logger.identifier);
    response.end();
    return;
  }

  const auto &md5{file.value().meta.at("md5").to_string()};
  const auto if_none_match{request->getHeader("if-none-match")};
  if (!if_none_match.empty()) {
    std::ostringstream etag_value_strong;
    std::ostringstream etag_value_weak;
    etag_value_strong << '"' << md5 << '"';
    etag_value_weak << 'W' << '/' << '"' << md5 << '"';
    for (const auto &match :
         sourcemeta::hydra::http::header_list(std::string{if_none_match})) {
      // Cache hit
      if (match.first == "*" || match.first == etag_value_weak.str() ||
          match.first == etag_value_strong.str()) {
        response.status = sourcemeta::hydra::http::Status::NOT_MODIFIED;
        response.header("X-Request-Id", logger.identifier);
        response.end();
        return;
      }
    }
  }

  response.status = code;
  response.header("X-Request-Id", logger.identifier);
  response.header("Content-Type", file.value().meta.at("mime").to_string());
  response.header("Last-Modified", last_modified);

  std::ostringstream etag;
  etag << '"' << md5 << '"';
  response.header("ETag", std::move(etag).str());

  // See
  // https://json-schema.org/draft/2020-12/json-schema-core.html#section-9.5.1.1
  const auto dialect{file.value().meta.try_at("dialect")};
  if (dialect) {
    std::ostringstream link;
    link << "<" << dialect->to_string() << ">; rel=\"describedby\"";
    response.header("Link", std::move(link).str());
  }

  std::ostringstream contents;
  contents << file.value().stream.rdbuf();
  if (request->getMethod() == "head") {
    response.head(contents.str());
  } else {
    response.end(contents.str());
  }
}

static auto to_lowercase(std::string_view input) -> std::string {
  std::string result{input};
  std::transform(
      result.begin(), result.end(), result.begin(),
      [](const unsigned char character) { return std::tolower(character); });
  return result;
}

static auto on_request(const std::filesystem::path &base,
                       const sourcemeta::registry::Logger &logger,
                       uWS::HttpRequest *request, ServerResponse &response)
    -> void {
  const bool can_satisfy_requested_content_encoding{
      negotiate_content_encoding(request, response)};
  if (!can_satisfy_requested_content_encoding) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::BAD_REQUEST,
               "cannot-satisfy-content-encoding",
               "The server cannot satisfy the request content encoding");
  } else if (request->getUrl() == "/") {
    serve_static_file(logger, request, response,
                      base / "explorer" / "pages.html",
                      sourcemeta::hydra::http::Status::OK);
  } else if (request->getUrl() == "/api/search") {
    if (request->getMethod() == "get") {
      const auto query{request->getQuery("q")};
      if (query.empty()) {
        json_error(logger, request, response,
                   sourcemeta::hydra::http::Status::BAD_REQUEST,
                   "missing-query",
                   "You must provide a query parameter to search for");
      } else {
        auto result{sourcemeta::registry::search(
            base / "explorer" / "search.jsonl", query)};
        response.status = sourcemeta::hydra::http::Status::OK;
        response.header("X-Request-Id", logger.identifier);
        std::ostringstream output;
        sourcemeta::core::prettify(result, output);
        response.end(output.str());
      }
    } else {
      json_error(logger, request, response,
                 sourcemeta::hydra::http::Status::METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    }
  } else if (request->getUrl().starts_with("/static/")) {
    std::ostringstream absolute_path;
    absolute_path << SOURCEMETA_REGISTRY_STATIC;
    absolute_path << request->getUrl().substr(7);
    serve_static_file(logger, request, response, absolute_path.str(),
                      sourcemeta::hydra::http::Status::OK);
  } else if (request->getUrl().ends_with(".json")) {
    // Because Visual Studio Code famously does not support `$id` or `id`
    // See https://github.com/microsoft/vscode-json-languageservice/issues/224
    const auto &user_agent{request->getHeader("user-agent")};
    const auto is_vscode{user_agent.starts_with("Visual Studio Code") ||
                         user_agent.starts_with("VSCodium")};
    const auto bundle{!request->getQuery("bundle").empty()};
    const auto unidentify{!request->getQuery("unidentify").empty()};
    auto absolute_path{base / "schemas" /
                       // Otherwise we may get unexpected results in
                       // case-sensitive file-systems
                       to_lowercase(request->getUrl().substr(1))};
    if (unidentify || is_vscode) {
      absolute_path += ".unidentified";
    } else if (bundle) {
      absolute_path += ".bundle";
    } else {
      absolute_path += ".schema";
    }

    serve_static_file(logger, request, response, absolute_path,
                      sourcemeta::hydra::http::Status::OK);
  } else if (request->getMethod() == "get" || request->getMethod() == "head") {
    const auto absolute_path{
        base / "explorer" / "pages" /
        (std::string{request->getUrl().substr(1)} + ".html")};
    if (std::filesystem::exists(absolute_path)) {
      serve_static_file(logger, request, response, absolute_path,
                        sourcemeta::hydra::http::Status::OK);
    } else {
      serve_static_file(logger, request, response,
                        base / "explorer" / "404.html",
                        sourcemeta::hydra::http::Status::NOT_FOUND);
    }
  } else {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::NOT_FOUND, "not-found",
               "There is nothing at this URL");
  }
}

static auto dispatch(const std::filesystem::path &base,
                     uWS::HttpResponse<true> *const response_handler,
                     uWS::HttpRequest *const request) noexcept -> void {
  // These should never throw, otherwise we cannot even react to errors
  sourcemeta::registry::Logger logger{sourcemeta::core::uuidv4()};
  // TODO: Get rid of this class
  ServerResponse response{response_handler};

  try {
    on_request(base, logger, request, response);
  } catch (const std::exception &error) {
    json_error(logger, request, response,
               sourcemeta::hydra::http::Status::METHOD_NOT_ALLOWED,
               "uncaught-error", error.what());
  }

  std::ostringstream line;
  line << response.status << ' ' << request->getMethod() << ' '
       << request->getUrl();
  logger << std::move(line).str();
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

    const auto base{std::filesystem::canonical(argv[1])};
    const auto configuration{
        sourcemeta::core::read_json(base / "configuration.json")};
    assert(configuration.defines("port"));
    assert(configuration.at("port").is_integer());
    assert(configuration.at("port").is_positive());
    const auto port{
        static_cast<std::uint32_t>(configuration.at("port").to_integer())};

    sourcemeta::registry::Logger logger{"global"};
    uWS::LocalCluster({}, [&base, port, &logger](uWS::SSLApp &app) -> void {
      app.any(
          "/*",
          [&base](auto *const response, auto *const request) noexcept -> void {
            dispatch(base, response, request);
          });

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
