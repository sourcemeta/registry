#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/time.h>
#include <sourcemeta/core/uuid.h>

#include <sourcemeta/registry/shared.h>

#include "uwebsockets.h"

#include "configure.h"
#include "evaluate.h"
#include "search.h"
#include "status.h"

#include <cassert>     // assert
#include <cctype>      // std::tolower
#include <chrono>      // std::chrono::system_clock
#include <csignal>     // std::signal, SIGINT, SIGTERM
#include <cstdint>     // std::uint32_t, std::atoi, std::stoul
#include <cstdlib>     // EXIT_FAILURE, std::exit
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

// TODO: Use `Encoding` from `src/shared`
enum class ServerContentEncoding { Identity, GZIP };

static auto send_response(const char *const code, const std::string_view method,
                          const std::string_view url,
                          uWS::HttpResponse<true> *response,
                          const std::string &message,
                          const ServerContentEncoding expected_encoding,
                          const ServerContentEncoding current_encoding)
    -> void {
  if (expected_encoding == ServerContentEncoding::GZIP) {
    response->writeHeader("Content-Encoding", "gzip");
    if (current_encoding == ServerContentEncoding::Identity) {
      auto effective_message{sourcemeta::core::gzip(message)};
      if (method == "head") {
        response->endWithoutBody(effective_message.size());
        response->end();
      } else {
        response->end(std::move(effective_message));
      }
    } else {
      if (method == "head") {
        response->endWithoutBody(message.size());
        response->end();
      } else {
        response->end(message);
      }
    }
  } else if (expected_encoding == ServerContentEncoding::Identity) {
    if (current_encoding == ServerContentEncoding::GZIP) {
      auto effective_message{sourcemeta::core::gunzip(message)};
      if (method == "head") {
        response->endWithoutBody(effective_message.size());
        response->end();
      } else {
        response->end(effective_message);
      }
    } else {
      if (method == "head") {
        response->endWithoutBody(message.size());
        response->end();
      } else {
        response->end(message);
      }
    }
  }

  std::ostringstream line;
  assert(code);
  line << code << ' ' << method << ' ' << url;
  log(std::move(line).str());
}

// See https://www.rfc-editor.org/rfc/rfc7807
static auto json_error(const std::string_view method,
                       const std::string_view url,
                       uWS::HttpResponse<true> *response,
                       const ServerContentEncoding encoding,
                       const char *const code, std::string &&id,
                       std::string &&message) -> void {
  auto object{sourcemeta::core::JSON::make_object()};
  object.assign("title",
                // A URI with a custom scheme
                sourcemeta::core::JSON{"sourcemeta:registry/" + std::move(id)});
  object.assign("status", sourcemeta::core::JSON{std::atoi(code)});
  object.assign("detail", sourcemeta::core::JSON{std::move(message)});
  response->writeStatus(code);
  response->writeHeader("Content-Type", "application/problem+json");
  response->writeHeader("Access-Control-Allow-Origin", "*");

  std::ostringstream output;
  sourcemeta::core::prettify(object, output);
  send_response(code, method, url, response, output.str(), encoding,
                ServerContentEncoding::Identity);
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

static auto
serve_static_file(uWS::HttpRequest *request, uWS::HttpResponse<true> *response,
                  const ServerContentEncoding encoding,
                  const std::filesystem::path &absolute_path,
                  const char *const code, const bool enable_cors = false,
                  const std::optional<std::string> &mime = std::nullopt)
    -> void {
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

  auto file{sourcemeta::registry::read_stream_raw(absolute_path)};
  if (!file.has_value()) {
    json_error(request->getMethod(), request->getUrl(), response, encoding,
               sourcemeta::registry::STATUS_NOT_FOUND, "not-found",
               "There is nothing at this URL");
    return;
  }

  // Note that `If-Modified-Since` can only be used with a `GET` or `HEAD`.
  // See
  // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since
  const auto if_modified_since{request->getHeader("if-modified-since")};
  if (!if_modified_since.empty()) {
    try {
      // Time comparison can be flaky, but adding a bit of tolerance leads
      // to more consistent behavior.
      if ((sourcemeta::core::from_gmt(std::string{if_modified_since}) +
           std::chrono::seconds(1)) >= file.value().last_modified) {
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

  const auto &checksum{file.value().checksum};
  const auto if_none_match{request->getHeader("if-none-match")};
  if (!if_none_match.empty()) {
    std::ostringstream etag_value_strong;
    std::ostringstream etag_value_weak;
    etag_value_strong << '"' << checksum << '"';
    etag_value_weak << 'W' << '/' << '"' << checksum << '"';
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

  if (mime.has_value()) {
    response->writeHeader("Content-Type", mime.value());
  } else {
    response->writeHeader("Content-Type", file.value().mime);
  }

  response->writeHeader("Last-Modified",
                        sourcemeta::core::to_gmt(file.value().last_modified));

  std::ostringstream etag;
  etag << '"' << checksum << '"';
  response->writeHeader("ETag", std::move(etag).str());

  // See
  // https://json-schema.org/draft/2020-12/json-schema-core.html#section-9.5.1.1
  const auto &dialect{file.value().extension};
  if (dialect.is_string()) {
    std::ostringstream link;
    link << "<" << dialect.to_string() << ">; rel=\"describedby\"";
    response->writeHeader("Link", std::move(link).str());
  }

  std::ostringstream contents;
  contents << file.value().data.rdbuf();

  if (file.value().encoding == sourcemeta::registry::Encoding::GZIP) {
    send_response(code, request->getMethod(), request->getUrl(), response,
                  contents.str(), encoding, ServerContentEncoding::GZIP);
  } else {
    send_response(code, request->getMethod(), request->getUrl(), response,
                  contents.str(), encoding, ServerContentEncoding::Identity);
  }
}

constexpr auto SENTINEL{"%"};

static auto on_evaluate(const std::filesystem::path &base,
                        const std::string_view &path, uWS::HttpRequest *request,
                        uWS::HttpResponse<true> *response,
                        const ServerContentEncoding encoding,
                        const sourcemeta::registry::EvaluateType mode) -> void {
  // A CORS pre-flight request
  if (request->getMethod() == "options") {
    response->writeStatus(sourcemeta::registry::STATUS_NO_CONTENT);
    response->writeHeader("Access-Control-Allow-Origin", "*");
    response->writeHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    response->writeHeader("Access-Control-Allow-Headers", "Content-Type");
    response->writeHeader("Access-Control-Max-Age", "3600");
    send_response(sourcemeta::registry::STATUS_NO_CONTENT, request->getMethod(),
                  request->getUrl(), response);
  } else if (request->getMethod() == "post") {
    auto template_path{base / "schemas"};
    template_path /= path;
    template_path += ".json";
    template_path /= SENTINEL;
    template_path /= "blaze-exhaustive.metapack";
    if (!std::filesystem::exists(template_path)) {
      const auto schema_path{template_path.parent_path() / "schema.metapack"};
      if (std::filesystem::exists(schema_path)) {
        json_error(request->getMethod(), request->getUrl(), response, encoding,
                   sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                   "no-template",
                   "This schema was not precompiled for schema evaluation");
      } else {
        json_error(request->getMethod(), request->getUrl(), response, encoding,
                   sourcemeta::registry::STATUS_NOT_FOUND, "not-found",
                   "There is nothing at this URL");
      }

      return;
    } else if (std::filesystem::exists(template_path.parent_path() /
                                       "protected.metapack")) {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED, "protected",
                 "This schema is protected");
    }

    response->onAborted([]() {});
    std::unique_ptr<std::string> buffer;
    // Because `request` gets de-allocated
    std::string url{request->getUrl()};
    response->onData([response, encoding, mode, buffer = std::move(buffer),
                      template_path = std::move(template_path),
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
                       sourcemeta::registry::STATUS_BAD_REQUEST, "no-instance",
                       "You must pass an instance to validate against");
          } else {
            const auto result{
                sourcemeta::registry::evaluate(template_path, *buffer, mode)};
            response->writeStatus(sourcemeta::registry::STATUS_OK);
            response->writeHeader("Content-Type", "application/json");
            response->writeHeader("Access-Control-Allow-Origin", "*");
            std::ostringstream payload;
            sourcemeta::core::prettify(result, payload);
            send_response(sourcemeta::registry::STATUS_OK, "post", url,
                          response, payload.str(), encoding,
                          ServerContentEncoding::Identity);
          }
        }
      } catch (const std::exception &error) {
        json_error("post", url, response, encoding,
                   sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                   "uncaught-error", error.what());
      }
    });
  } else {
    json_error(request->getMethod(), request->getUrl(), response, encoding,
               sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
               "method-not-allowed",
               "This HTTP method is invalid for this URL");
  }
}

static auto on_request(const std::filesystem::path &base,
                       uWS::HttpRequest *request,
                       uWS::HttpResponse<true> *response,
                       const ServerContentEncoding encoding,
                       const bool is_headless) -> void {
  if (request->getUrl() == "/") {
    serve_static_file(request, response, encoding,
                      base / "explorer" / SENTINEL / "directory-html.metapack",
                      sourcemeta::registry::STATUS_OK);
  } else if (request->getUrl() == "/self/api/list") {
    serve_static_file(request, response, encoding,
                      base / "explorer" / SENTINEL / "directory.metapack",
                      sourcemeta::registry::STATUS_OK, true);
  } else if (request->getUrl().starts_with("/self/api/list/")) {
    const auto absolute_path{base / "explorer" / request->getUrl().substr(15) /
                             SENTINEL / "directory.metapack"};
    serve_static_file(request, response, encoding, absolute_path,
                      sourcemeta::registry::STATUS_OK, true);
  } else if (request->getUrl().starts_with("/self/api/schemas/dependencies/")) {
    if (request->getMethod() == "get" || request->getMethod() == "head") {
      auto absolute_path{base / "schemas"};
      absolute_path /= request->getUrl().substr(31);
      absolute_path += ".json";
      absolute_path /= SENTINEL;
      absolute_path /= "dependencies.metapack";
      serve_static_file(request, response, encoding, absolute_path,
                        sourcemeta::registry::STATUS_OK, true);
    } else {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    }
  } else if (request->getUrl().starts_with("/self/api/schemas/health/")) {
    if (request->getMethod() == "get" || request->getMethod() == "head") {
      auto absolute_path{base / "schemas"};
      absolute_path /= request->getUrl().substr(25);
      absolute_path += ".json";
      absolute_path /= SENTINEL;
      absolute_path /= "health.metapack";
      serve_static_file(request, response, encoding, absolute_path,
                        sourcemeta::registry::STATUS_OK, true);
    } else {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    }
  } else if (request->getUrl().starts_with("/self/api/schemas/locations/")) {
    if (request->getMethod() == "get" || request->getMethod() == "head") {
      auto absolute_path{base / "schemas"};
      absolute_path /= request->getUrl().substr(28);
      absolute_path += ".json";
      absolute_path /= SENTINEL;
      absolute_path /= "locations.metapack";

      if (std::filesystem::exists(absolute_path.parent_path() /
                                  "protected.metapack")) {
        json_error(request->getMethod(), request->getUrl(), response, encoding,
                   sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED, "protected",
                   "This schema is protected");
      } else {
        serve_static_file(request, response, encoding, absolute_path,
                          sourcemeta::registry::STATUS_OK, true);
      }
    } else {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    }
  } else if (request->getUrl().starts_with("/self/api/schemas/positions/")) {
    if (request->getMethod() == "get" || request->getMethod() == "head") {
      auto absolute_path{base / "schemas"};
      absolute_path /= request->getUrl().substr(28);
      absolute_path += ".json";
      absolute_path /= SENTINEL;
      absolute_path /= "positions.metapack";

      if (std::filesystem::exists(absolute_path.parent_path() /
                                  "protected.metapack")) {
        json_error(request->getMethod(), request->getUrl(), response, encoding,
                   sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED, "protected",
                   "This schema is protected");
      } else {
        serve_static_file(request, response, encoding, absolute_path,
                          sourcemeta::registry::STATUS_OK, true);
      }
    } else {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    }
  } else if (request->getUrl().starts_with("/self/api/schemas/metadata/")) {
    if (request->getMethod() == "get" || request->getMethod() == "head") {
      auto absolute_path{base / "explorer"};
      absolute_path /= request->getUrl().substr(27);
      absolute_path /= SENTINEL;
      absolute_path /= "schema.metapack";
      serve_static_file(request, response, encoding, absolute_path,
                        sourcemeta::registry::STATUS_OK, true);
    } else {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    }
  } else if (request->getUrl().starts_with("/self/api/schemas/evaluate/")) {
    on_evaluate(base, request->getUrl().substr(27), request, response, encoding,
                sourcemeta::registry::EvaluateType::Standard);
  } else if (request->getUrl().starts_with("/self/api/schemas/trace/")) {
    on_evaluate(base, request->getUrl().substr(24), request, response, encoding,
                sourcemeta::registry::EvaluateType::Trace);
  } else if (request->getUrl() == "/self/api/schemas/search") {
    if (request->getMethod() == "get") {
      const auto query{request->getQuery("q")};
      if (query.empty()) {
        json_error(request->getMethod(), request->getUrl(), response, encoding,
                   sourcemeta::registry::STATUS_BAD_REQUEST, "missing-query",
                   "You must provide a query parameter to search for");
      } else {
        auto result{sourcemeta::registry::search(
            base / "explorer" / SENTINEL / "search.metapack", query)};
        response->writeStatus(sourcemeta::registry::STATUS_OK);
        response->writeHeader("Access-Control-Allow-Origin", "*");
        response->writeHeader("Content-Type", "application/json");
        std::ostringstream output;
        sourcemeta::core::prettify(result, output);
        send_response(sourcemeta::registry::STATUS_OK, request->getMethod(),
                      request->getUrl(), response, output.str(), encoding,
                      ServerContentEncoding::Identity);
      }
    } else {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED,
                 "method-not-allowed",
                 "This HTTP method is invalid for this URL");
    }
  } else if (request->getUrl().starts_with("/self/api/")) {
    json_error(request->getMethod(), request->getUrl(), response, encoding,
               sourcemeta::registry::STATUS_NOT_FOUND, "not-found",
               "There is nothing at this URL");
  } else if (!is_headless && request->getUrl().starts_with("/self/static/")) {
    std::ostringstream absolute_path;
    absolute_path << SOURCEMETA_REGISTRY_STATIC;
    absolute_path << request->getUrl().substr(12);
    serve_static_file(request, response, encoding, absolute_path.str(),
                      sourcemeta::registry::STATUS_OK);
  } else if (request->getUrl().ends_with(".json")) {
    // Otherwise we may get unexpected results in case-sensitive file-systems
    std::string lowercase_path{request->getUrl().substr(1)};
    std::transform(
        lowercase_path.begin(), lowercase_path.end(), lowercase_path.begin(),
        [](const unsigned char character) { return std::tolower(character); });

    // Because Visual Studio Code famously does not support `$id` or `id`
    // See
    // https://github.com/microsoft/vscode-json-languageservice/issues/224
    const auto &user_agent{request->getHeader("user-agent")};
    const auto is_vscode{user_agent.starts_with("Visual Studio Code") ||
                         user_agent.starts_with("VSCodium")};
    const auto is_deno{user_agent.starts_with("Deno/")};
    const auto bundle{!request->getQuery("bundle").empty()};
    auto absolute_path{base / "schemas" / lowercase_path / SENTINEL};
    if (is_vscode) {
      absolute_path /= "unidentified.metapack";
    } else if (bundle || is_deno) {
      absolute_path /= "bundle.metapack";
    } else {
      absolute_path /= "schema.metapack";
    }

    if (std::filesystem::exists(absolute_path.parent_path() /
                                "protected.metapack")) {
      json_error(request->getMethod(), request->getUrl(), response, encoding,
                 sourcemeta::registry::STATUS_METHOD_NOT_ALLOWED, "protected",
                 "This schema is protected");
    } else if (is_deno) {
      serve_static_file(request, response, encoding, absolute_path,
                        sourcemeta::registry::STATUS_OK, true,
                        // For HTTP imports, as Deno won't like the
                        // `application/schema+json` one
                        "application/json");
    } else {
      serve_static_file(request, response, encoding, absolute_path,
                        sourcemeta::registry::STATUS_OK, true);
    }
  } else if (request->getMethod() == "get" || request->getMethod() == "head") {
    auto absolute_path{base / "explorer" / request->getUrl().substr(1) /
                       SENTINEL};
    if (std::filesystem::exists(absolute_path / "schema-html.metapack")) {
      serve_static_file(request, response, encoding,
                        absolute_path / "schema-html.metapack",
                        sourcemeta::registry::STATUS_OK);
    } else {
      absolute_path /= "directory-html.metapack";
      if (std::filesystem::exists(absolute_path)) {
        serve_static_file(request, response, encoding, absolute_path,
                          sourcemeta::registry::STATUS_OK);
      } else {
        serve_static_file(request, response, encoding,
                          base / "explorer" / SENTINEL / "404.metapack",
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
                     uWS::HttpRequest *const request,
                     const bool is_headless) noexcept -> void {
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
      on_request(base, request, response, encoding.value(), is_headless);
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

auto terminate(int signal) -> void {
  std::cerr << "Terminatting on signal: " << signal << "\n";
  // TODO: Use `us_listen_socket_close` instead
  // See https://github.com/uNetworking/uWebSockets/issues/1402
  std::exit(EXIT_SUCCESS);
}

// We try to keep this function as straight to point as possible
// with minimal input validation (outside debug builds). The intention
// is for the server to start running and bind to the port as quickly
// as possible, so we can take better advantage of scale-to-zero.
auto main(int argc, char *argv[]) noexcept -> int {
  std::cout << "Sourcemeta Registry v" << sourcemeta::registry::PROJECT_VERSION;
#if defined(SOURCEMETA_REGISTRY_ENTERPRISE)
  std::cout << " Enterprise ";
#elif defined(SOURCEMETA_REGISTRY_PRO)
  std::cout << " Pro ";
#else
  std::cout << " Starter ";
#endif
  std::cout << "Edition\n";

  // Mainly for Docker Compose
  std::signal(SIGINT, terminate);
  std::signal(SIGTERM, terminate);

  try {
    if (argc != 3) {
      std::cout << "Usage: " << argv[0]
                << " <path/to/output/directory> <port>\n";
      return EXIT_FAILURE;
    }

    const auto port{static_cast<std::uint32_t>(std::stoul(argv[2]))};

    if (!sourcemeta::registry::license_permitted()) {
      std::cerr << sourcemeta::registry::license_error();
      return EXIT_FAILURE;
    }

    const auto base{std::filesystem::canonical(argv[1])};
    const auto is_headless{!std::filesystem::exists(
        base / "explorer" / SENTINEL / "directory-html.metapack")};

    uWS::LocalCluster({}, [&base, port, is_headless](uWS::SSLApp &app) -> void {
      app.any("/*",
              [&base, is_headless](auto *const response,
                                   auto *const request) noexcept -> void {
                dispatch(base, response, request, is_headless);
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
