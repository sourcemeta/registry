#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/time.h>
#include <sourcemeta/core/uuid.h>

#include <sourcemeta/registry/license.h>

#include "uwebsockets.h"

#include "configure.h"
#include "evaluate.h"
#include "reader.h"
#include "search.h"
#include "status.h"

#include <cassert>     // assert
#include <cctype>      // std::tolower
#include <chrono>      // std::chrono::system_clock
#include <cstdint>     // std::uint32_t, std::atoi
#include <cstdlib>     // EXIT_FAILURE
#include <filesystem>  // std::filesystem
#include <iostream>    // std::cerr, std::cout
#include <memory>      // std::unique_ptr
#include <mutex>       // std::mutex, std::lock_guard
#include <optional>    // std::optional
#include <sstream>     // std::ostringstream, std::istringstream
#include <stdexcept>   // std::invalid_argument
#include <string>      // std::string, std::getline
#include <string_view> // std::string_view
#include <thread>      // std::this_thread
#include <utility>     // std::move, std::pair
#include <vector>      // std::vector

static auto log(std::string_view message) -> void {
  // Otherwise we can get messed up output interleaved from multiple threads
  static std::mutex log_mutex;
  std::lock_guard<std::mutex> guard{log_mutex};
  std::cerr << "[" << sourcemeta::core::to_gmt(std::chrono::system_clock::now())
            << "] " << std::this_thread::get_id() << ' ' << message << "\n";
}

static auto send_response(const char *const code, const std::string_view method,
                          const std::string_view url,
                          uWS::HttpResponse<true> *response) -> void {
  response->end();
  std::ostringstream line;
  assert(code);
  line << code << ' ' << method << ' ' << url;
  log(std::move(line).str());
}

enum class ServerContentEncoding { Identity, GZIP };

static auto send_response(const char *const code, const std::string_view method,
                          const std::string_view url,
                          uWS::HttpResponse<true> *response,
                          const std::string &message,
                          const ServerContentEncoding encoding) -> void {
  if (encoding == ServerContentEncoding::GZIP) {
    response->writeHeader("Content-Encoding", "gzip");
    auto result{sourcemeta::core::gzip(message)};
    if (method == "head") {
      response->endWithoutBody(result.size());
      response->end();
    } else {
      response->end(std::move(result));
    }
  } else if (encoding == ServerContentEncoding::Identity) {
    if (method == "head") {
      response->endWithoutBody(message.size());
      response->end();
    } else {
      response->end(message);
    }
  }

  std::ostringstream line;
  assert(code);
  line << code << ' ' << method << ' ' << url;
  log(std::move(line).str());
}

static auto json_error(const std::string_view method,
                       const std::string_view url,
                       uWS::HttpResponse<true> *response,
                       const ServerContentEncoding encoding,
                       const char *const code, std::string &&id,
                       std::string &&message) -> void {
  auto object{sourcemeta::core::JSON::make_object()};
  object.assign("error", sourcemeta::core::JSON{std::move(id)});
  object.assign("message", sourcemeta::core::JSON{std::move(message)});
  object.assign("code", sourcemeta::core::JSON{std::atoi(code)});
  response->writeStatus(code);
  response->writeHeader("Content-Type", "application/json");
  response->writeHeader("Access-Control-Allow-Origin", "*");

  std::ostringstream output;
  sourcemeta::core::prettify(object, output);
  send_response(code, method, url, response, output.str(), encoding);
}

/// A header list element consists of the element value and its quality value
/// See https://developer.mozilla.org/en-US/docs/Glossary/Quality_values
static auto header_list(const std::string_view &value)
    -> std::vector<std::pair<std::string, float>> {
  std::istringstream stream{std::string{value}};
  std::string token;
  std::vector<std::pair<std::string, float>> result;

  while (std::getline(stream, token, ',')) {
    const std::size_t start{token.find_first_not_of(" ")};
    const std::size_t end{token.find_last_not_of(" ")};
    if (start == std::string::npos || end == std::string::npos) {
      continue;
    }

    // See https://developer.mozilla.org/en-US/docs/Glossary/Quality_values
    const std::size_t value_start{token.find_first_of(";")};
    if (value_start != std::string::npos && token[value_start + 1] == 'q' &&
        token[value_start + 2] == '=') {
      result.emplace_back(token.substr(start, value_start - start),
                          std::stof(token.substr(value_start + 3)));
    } else {
      // No quality value is 1.0 by default
      result.emplace_back(token.substr(start, end - start + 1), 1.0f);
    }
  }

  // For convenient, automatically sort by the quality value
  std::sort(result.begin(), result.end(),
            [](const auto &left, const auto &right) {
              return left.second > right.second;
            });

  return result;
}

static auto serve_static_file(uWS::HttpRequest *request,
                              uWS::HttpResponse<true> *response,
                              const ServerContentEncoding encoding,
                              const std::filesystem::path &absolute_path,
                              const char *const code,
                              const bool enable_cors = false) -> void {
  if (request->getMethod() != "get" && request->getMethod() != "head") {
    if (std::filesystem::exists(absolute_path)) {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    } else {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_NOT_FOUND, "not-found",
                 "There is nothing at this URL");
    }

    return;
  }

  auto file{sourcemeta::registry::read_stream(absolute_path)};
  if (!file.has_value()) {
    json_error(request->getMethod(), request->getUrl(), response, encoding,
               sourcemeta::registry::STATUS_NOT_FOUND, "not-found",
               "There is nothing at this URL");
    return;
  }

  // Note that `If-Modified-Since` can only be used with a `GET` or `HEAD`.
  // See
  // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since
  const auto &last_modified{file.value().meta.at("lastModified").to_string()};
  const auto if_modified_since{request->getHeader("if-modified-since")};
  if (!if_modified_since.empty()) {
    try {
      // Time comparison can be flaky, but adding a bit of tolerance leads
      // to more consistent behavior.
      if ((sourcemeta::core::from_gmt(std::string{if_modified_since}) +
           std::chrono::seconds(1)) >=
          sourcemeta::core::from_gmt(last_modified)) {
        response->writeStatus(sourcemeta::registry::STATUS_NOT_MODIFIED);
        if (enable_cors) {
          response->writeHeader("Access-Control-Allow-Origin", "*");
        }

        send_response(sourcemeta::registry::STATUS_NOT_MODIFIED,
                      request->getMethod(), request->getUrl(), response);
        return;
      }
      // If there is an error parsing the `If-Modified-Since` timestamp, don't
      // abort, but lean on the safe side: the requested resource has been
      // modified
    } catch (const std::invalid_argument &) {
    }
  }

  const auto &md5{file.value().meta.at("md5").to_string()};
  const auto if_none_match{request->getHeader("if-none-match")};
  if (!if_none_match.empty()) {
    std::ostringstream etag_value_strong;
    std::ostringstream etag_value_weak;
    etag_value_strong << '"' << md5 << '"';
    etag_value_weak << 'W' << '/' << '"' << md5 << '"';
    for (const auto &match : header_list(if_none_match)) {
      // Cache hit
      if (match.first == "*" || match.first == etag_value_weak.str() ||
          match.first == etag_value_strong.str()) {
        response->writeStatus(sourcemeta::registry::STATUS_NOT_MODIFIED);
        if (enable_cors) {
          response->writeHeader("Access-Control-Allow-Origin", "*");
        }

        send_response(sourcemeta::registry::STATUS_NOT_MODIFIED,
                      request->getMethod(), request->getUrl(), response);
        return;
      }
    }
  }

  response->writeStatus(code);

  // To support requests from web browsers
  if (enable_cors) {
    response->writeHeader("Access-Control-Allow-Origin", "*");
  }

  response->writeHeader("Content-Type",
                        file.value().meta.at("mime").to_string());
  response->writeHeader("Last-Modified", last_modified);

  std::ostringstream etag;
  etag << '"' << md5 << '"';
  response->writeHeader("ETag", std::move(etag).str());

  // See
  // https://json-schema.org/draft/2020-12/json-schema-core.html#section-9.5.1.1
  const auto dialect{file.value().meta.try_at("dialect")};
  if (dialect) {
    std::ostringstream link;
    link << "<" << dialect->to_string() << ">; rel=\"describedby\"";
    response->writeHeader("Link", std::move(link).str());
  }

  std::ostringstream contents;
  contents << file.value().data.rdbuf();
  send_response(code, request->getMethod(), request->getUrl(), response,
                contents.str(), encoding);
}

static auto on_request(const std::filesystem::path &base,
                       uWS::HttpRequest *request,
                       uWS::HttpResponse<true> *response,
                       const ServerContentEncoding encoding) -> void {
  if (request->getUrl() == "/") {
    const auto accept{request->getHeader("accept")};
    if (accept == "application/json") {
      serve_static_file(request, response, encoding,
                        base / "explorer" / "pages.nav",
                        sourcemeta::registry::STATUS_OK, true);
    } else {
      serve_static_file(request, response, encoding,
                        base / "explorer" / "pages.html",
                        sourcemeta::registry::STATUS_OK);
    }
  } else if (request->getUrl() == "/api/search") {
    if (request->getMethod() == "get") {
      const auto query{request->getQuery("q")};
      if (query.empty()) {
        json_error(request->getMethod(), request->getUrl(), response, encoding,
                   sourcemeta::registry::STATUS_BAD_REQUEST, "missing-query",
                   "You must provide a query parameter to search for");
      } else {
        auto result{sourcemeta::registry::search(
            base / "explorer" / "search.jsonl", query)};
        response->writeStatus(sourcemeta::registry::STATUS_OK);
        response->writeHeader("Access-Control-Allow-Origin", "*");
        response->writeHeader("Content-Type", "application/json");
        std::ostringstream output;
        sourcemeta::core::prettify(result, output);
        send_response(sourcemeta::registry::STATUS_OK, request->getMethod(),
                      request->getUrl(), response, output.str(), encoding);
      }
    } else {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    }
  } else if (request->getUrl().starts_with("/static/")) {
    std::ostringstream absolute_path;
    absolute_path << SOURCEMETA_REGISTRY_STATIC;
    absolute_path << request->getUrl().substr(7);
    serve_static_file(request, response, encoding, absolute_path.str(),
                      sourcemeta::registry::STATUS_OK);
  } else if (request->getUrl().ends_with(".json")) {
    // Otherwise we may get unexpected results in case-sensitive file-systems
    std::string lowercase_path{request->getUrl().substr(1)};
    std::transform(
        lowercase_path.begin(), lowercase_path.end(), lowercase_path.begin(),
        [](const unsigned char character) { return std::tolower(character); });

    // A CORS pre-flight request
    if (request->getMethod() == "options") {
      response->writeStatus(sourcemeta::registry::STATUS_NO_CONTENT);
      response->writeHeader("Access-Control-Allow-Origin", "*");
      response->writeHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
      response->writeHeader("Access-Control-Allow-Headers", "Content-Type");
      response->writeHeader("Access-Control-Max-Age", "3600");
      send_response(sourcemeta::registry::STATUS_NO_CONTENT,
                    request->getMethod(), request->getUrl(), response);
    } else if (request->getMethod() == "post") {
      auto template_path{base / "schemas" /
                         (lowercase_path + ".blaze-exhaustive")};
      if (!std::filesystem::exists(template_path)) {
        template_path.replace_extension(".schema");
        if (std::filesystem::exists(template_path)) {
          json_error(request->getMethod(), request->getUrl(), response,
                     encoding, sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                     "no-template",
                     "This schema was not precompiled for schema evaluation");
        } else {
          json_error(request->getMethod(), request->getUrl(), response,
                     encoding, sourcemeta::registry::STATUS_NOT_FOUND,
                     "not-found", "There is nothing at this URL");
        }

        return;
      }

      response->onAborted([]() {});
      std::unique_ptr<std::string> buffer;
      // Because `request` gets de-allocated
      std::string url{request->getUrl()};
      response->onData([response, encoding, buffer = std::move(buffer),
                        template_path = std::move(template_path),
                        trace = !request->getQuery("trace").empty(),
                        url = std::move(url)](const std::string_view chunk,
                                              const bool is_last) mutable {
        try {
          if (!buffer.get()) {
            buffer = std::make_unique<std::string>(chunk);
          } else {
            buffer->append(chunk);
          }

          if (is_last) {
            if (buffer->empty()) {
              json_error("post", url, response, encoding,
                         sourcemeta::registry::STATUS_BAD_REQUEST,
                         "no-instance",
                         "You must pass an instance to validate against");
            } else {
              const auto result{sourcemeta::registry::evaluate(
                  template_path, *buffer,
                  trace ? sourcemeta::registry::EvaluateType::Trace
                        : sourcemeta::registry::EvaluateType::Standard)};
              response->writeStatus(sourcemeta::registry::STATUS_OK);
              response->writeHeader("Content-Type", "application/json");
              response->writeHeader("Access-Control-Allow-Origin", "*");
              std::ostringstream payload;
              sourcemeta::core::prettify(result, payload);
              send_response(sourcemeta::registry::STATUS_OK, "post", url,
                            response, payload.str(), encoding);
            }
          }
        } catch (const std::exception &error) {
          json_error("post", url, response, encoding,
                     sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                     "uncaught-error", error.what());
        }
      });
    } else if (!request->getQuery("meta").empty()) {
      auto absolute_path{base / "explorer" / "pages" / lowercase_path};
      absolute_path.replace_extension(".nav");
      serve_static_file(request, response, encoding, absolute_path,
                        sourcemeta::registry::STATUS_OK, true);
    } else {
      // Because Visual Studio Code famously does not support `$id` or `id`
      // See
      // https://github.com/microsoft/vscode-json-languageservice/issues/224
      const auto &user_agent{request->getHeader("user-agent")};
      const auto is_vscode{user_agent.starts_with("Visual Studio Code") ||
                           user_agent.starts_with("VSCodium")};
      const auto positions{!request->getQuery("positions").empty()};
      const auto dependencies{!request->getQuery("dependencies").empty()};
      const auto bundle{!request->getQuery("bundle").empty()};
      const auto unidentify{!request->getQuery("unidentify").empty()};
      auto absolute_path{base / "schemas" / lowercase_path};
      if (positions) {
        absolute_path += ".positions";
      } else if (dependencies) {
        absolute_path += ".dependencies";
      } else if (unidentify || is_vscode) {
        absolute_path += ".unidentified";
      } else if (bundle) {
        absolute_path += ".bundle";
      } else {
        absolute_path += ".schema";
      }

      // For convenience
      if (!std::filesystem::exists(absolute_path)) {
        auto nav_path{base / "explorer" / "pages" / lowercase_path};
        nav_path.replace_extension(".nav");
        if (std::filesystem::exists(nav_path)) {
          serve_static_file(request, response, encoding, nav_path,
                            sourcemeta::registry::STATUS_OK, true);
          return;
        }
      }

      serve_static_file(request, response, encoding, absolute_path,
                        sourcemeta::registry::STATUS_OK, true);
    }
  } else if (request->getMethod() == "get" || request->getMethod() == "head") {
    const auto accept{request->getHeader("accept")};
    if (accept == "application/json") {
      const auto absolute_path{
          base / "explorer" / "pages" /
          (std::string{request->getUrl().substr(1)} + ".nav")};
      serve_static_file(request, response, encoding, absolute_path,
                        sourcemeta::registry::STATUS_OK, true);
    } else {
      const auto absolute_path{
          base / "explorer" / "pages" /
          (std::string{request->getUrl().substr(1)} + ".html")};
      if (std::filesystem::exists(absolute_path)) {
        serve_static_file(request, response, encoding, absolute_path,
                          sourcemeta::registry::STATUS_OK);
      } else {
        serve_static_file(request, response, encoding,
                          base / "explorer" / "404.html",
                          sourcemeta::registry::STATUS_NOT_FOUND);
      }
    }
  } else {
    json_error(request->getMethod(), request->getUrl(), response, encoding,
               sourcemeta::registry::STATUS_NOT_FOUND, "not-found",
               "There is nothing at this URL");
  }
}

static auto dispatch(const std::filesystem::path &base,
                     uWS::HttpResponse<true> *const response,
                     uWS::HttpRequest *const request) noexcept -> void {
  try {
    // As long as the identity;q=0 or *;q=0 directives do not explicitly
    // forbid the identity value that means no encoding, the server must never
    // return a 406 Not Acceptable error. See
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Encoding
    std::optional<ServerContentEncoding> encoding{
        ServerContentEncoding::Identity};

    const auto accept_encoding{request->getHeader("accept-encoding")};
    if (!accept_encoding.empty()) {
      for (const auto &rule : header_list(accept_encoding)) {
        if (rule.second == 0.0f &&
            // The client explicitly prohibited the default encoding
            (rule.first == "*" || rule.first == "identity")) {
          encoding = std::nullopt;
          break;
        } else if (rule.first == "identity") {
          break;
        } else if (
            rule.first == "*" || rule.first == "gzip" ||
            // For compatibility with previous implementations of HTTP,
            // applications SHOULD consider "x-gzip" [...] to be equivalent to
            // "gzip". See
            // https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.5
            rule.first == "x-gzip") {
          encoding = ServerContentEncoding::GZIP;
          break;
        }
      }
    }

    if (encoding.has_value()) {
      on_request(base, request, response, encoding.value());
    } else {
      json_error(request->getMethod(), request->getUrl(), response,
                 ServerContentEncoding::Identity,
                 sourcemeta::registry::STATUS_BAD_REQUEST,
                 "cannot-satisfy-content-encoding",
                 "The server cannot satisfy the request content encoding");
    }
  } catch (const std::exception &error) {
    json_error(request->getMethod(), request->getUrl(), response,
               // As computing the right content encoding might throw
               ServerContentEncoding::Identity,
               sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
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

    const auto base{std::filesystem::canonical(argv[1])};
    const auto configuration{
        sourcemeta::core::read_json(base / "configuration.json")};
    assert(configuration.defines("port"));
    assert(configuration.at("port").is_integer());
    assert(configuration.at("port").is_positive());
    const auto port{
        static_cast<std::uint32_t>(configuration.at("port").to_integer())};

    uWS::LocalCluster({}, [&base, port](uWS::SSLApp &app) -> void {
      app.any(
          "/*",
          [&base](auto *const response, auto *const request) noexcept -> void {
            dispatch(base, response, request);
          });

      app.listen(static_cast<int>(port),
                 [port](us_listen_socket_t *const socket) -> void {
                   if (socket) {
                     const auto socket_port = us_socket_local_port(
                         true, reinterpret_cast<struct us_socket_t *>(socket));
                     assert(socket_port > 0);
                     assert(port == static_cast<std::uint32_t>(socket_port));
                     log("Listening on port " + std::to_string(socket_port));
                   } else {
                     log("Failed to listen on port " + std::to_string(port));
                   }
                 });
    });

    log("Failed to listen on port " + std::to_string(port));
    return EXIT_FAILURE;
  } catch (const std::exception &error) {
    std::cerr << "unexpected error: " << error.what() << "\n";
    return EXIT_FAILURE;
  }
}
