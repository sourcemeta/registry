#ifndef SOURCEMETA_REGISTRY_HTTPSERVER_H
#define SOURCEMETA_REGISTRY_HTTPSERVER_H

#include <sourcemeta/core/md5.h>
#include <sourcemeta/hydra/http.h>

#include "httpserver_logger.h"
#include "httpserver_request.h"
#include "httpserver_response.h"

#include "uwebsockets.h"

#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnewline-eof"
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-parameter"
#elif defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wunused-parameter"
#endif
#include <src/LocalCluster.h>
#if defined(__clang__)
#pragma clang diagnostic pop
#elif defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

#include <cassert>    // assert
#include <cstdint>    // std::uint32_t
#include <cstdlib>    // EXIT_FAILURE
#include <exception>  // std::exception_ptr
#include <filesystem> // std::filesystem::path
#include <fstream>    // std::ifstream
#include <functional> // std::function
#include <iostream>   // std::cerr
#include <ostream>    // std::ostream
#include <sstream>    // std::ostringstream
#include <string>     // std::string
#include <tuple>      // std::tuple
#include <utility>    // std::move
#include <vector>     // std::vector

using RouteCallback = std::function<void(
    const ServerLogger &, const ServerRequest &, ServerResponse &)>;
using ErrorCallback =
    std::function<void(std::exception_ptr, const ServerLogger &,
                       const ServerRequest &, ServerResponse &)>;

static auto negotiate_content_encoding(const ServerRequest &request,
                                       ServerResponse &response) -> bool {
  const auto accept_encoding{request.header_list("accept-encoding")};
  if (!accept_encoding.has_value()) {
    response.encoding(ServerContentEncoding::Identity);
    return true;
  }

  for (const auto &encoding : accept_encoding.value()) {
    if (encoding.second == 0.0f) {
      // The client explicitly prohibited the default encoding
      if (encoding.first == "*" || encoding.first == "identity") {
        return false;
      }

      continue;
    }

    assert(encoding.second > 0.0f);

    if (encoding.first == "identity") {
      response.encoding(ServerContentEncoding::Identity);
      return true;
    } else if (encoding.first == "*" || encoding.first == "gzip") {
      response.encoding(ServerContentEncoding::GZIP);
      return true;
    }

    // For compatibility with previous implementations of HTTP, applications
    // SHOULD consider "x-gzip" [...] to be equivalent to "gzip".
    // See https://www.w3.org/Protocols/rfc2616/rfc2616-sec3.html#sec3.5
    if (encoding.first == "x-gzip") {
      response.encoding(ServerContentEncoding::GZIP);
      return true;
    }
  }

  // As long as the identity;q=0 or *;q=0 directives do not explicitly forbid
  // the identity value that means no encoding, the server must never return a
  // 406 Not Acceptable error. See
  // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept-Encoding
  response.encoding(ServerContentEncoding::Identity);
  return true;
}

static auto wrap_route(uWS::HttpResponse<true> *const response_handler,
                       uWS::HttpRequest *const request_handler,
                       const ErrorCallback &error,
                       const RouteCallback &callback) noexcept -> void {
  assert(error);
  assert(callback);
  assert(response_handler);
  assert(request_handler);

  // These should never throw, otherwise we cannot even react to errors
  ServerLogger logger;
  const ServerRequest request{request_handler};
  ServerResponse response{response_handler};

  // For easy tracking
  response.header("X-Request-Id", logger.id());

  try {
    // Attempt automatic content encoding negotiation, which the user can always
    // manually override later on in their request callback
    const bool can_satisfy_requested_content_encoding{
        negotiate_content_encoding(request, response)};
    if (can_satisfy_requested_content_encoding) {
      callback(logger, request, response);
    } else {
      response.status(sourcemeta::hydra::http::Status::NOT_ACCEPTABLE);
      response.end();
    }
  } catch (...) {
    error(std::current_exception(), logger, request, response);
  }

  std::ostringstream line;
  line << response.status() << ' ' << request.method() << ' ' << request.path();
  logger << line.str();
}

static auto default_handler(const ServerLogger &, const ServerRequest &,
                            ServerResponse &response) -> void {
  response.status(sourcemeta::hydra::http::Status::NOT_IMPLEMENTED);
  response.end();
}

static auto default_error_handler(std::exception_ptr error,
                                  const ServerLogger &, const ServerRequest &,
                                  ServerResponse &response) -> void {
  assert(error);
  response.status(sourcemeta::hydra::http::Status::INTERNAL_SERVER_ERROR);
  try {
    std::rethrow_exception(error);
  } catch (const std::exception &exception) {
    response.end(exception.what());
  }
}

class Server {
public:
  Server()
      : routes{}, fallback{default_handler},
        error_handler{default_error_handler} {}

  auto route(const sourcemeta::hydra::http::Method method, std::string &&path,
             RouteCallback &&callback) -> void {
    this->routes.emplace_back(method, std::move(path), std::move(callback));
  }

  auto otherwise(RouteCallback &&callback) -> void {
    this->fallback = std::move(callback);
  }

  auto error(ErrorCallback &&callback) -> void {
    this->error_handler = std::move(callback);
  }

  auto run(const std::uint32_t port) const -> int {
    uWS::LocalCluster({}, [this, port](uWS::SSLApp &app) -> void {

#define UWS_CALLBACK(callback_name)                                            \
  [&](auto *const response_handler,                                            \
      auto *const request_handler) noexcept -> void {                          \
    wrap_route(response_handler, request_handler, this->error_handler,         \
               (callback_name));                                               \
  }
      for (const auto &entry : this->routes) {
        switch (std::get<0>(entry)) {
          case sourcemeta::hydra::http::Method::GET:
            app.get(std::get<1>(entry), UWS_CALLBACK(std::get<2>(entry)));
            break;
          case sourcemeta::hydra::http::Method::HEAD:
            app.head(std::get<1>(entry), UWS_CALLBACK(std::get<2>(entry)));
            break;
          case sourcemeta::hydra::http::Method::POST:
            app.post(std::get<1>(entry), UWS_CALLBACK(std::get<2>(entry)));
            break;
          case sourcemeta::hydra::http::Method::PUT:
            app.put(std::get<1>(entry), UWS_CALLBACK(std::get<2>(entry)));
            break;
          case sourcemeta::hydra::http::Method::DELETE:
            app.del(std::get<1>(entry), UWS_CALLBACK(std::get<2>(entry)));
            break;
          case sourcemeta::hydra::http::Method::CONNECT:
            app.connect(std::get<1>(entry), UWS_CALLBACK(std::get<2>(entry)));
            break;
          case sourcemeta::hydra::http::Method::OPTIONS:
            app.options(std::get<1>(entry), UWS_CALLBACK(std::get<2>(entry)));
            break;
          case sourcemeta::hydra::http::Method::TRACE:
            app.trace(std::get<1>(entry), UWS_CALLBACK(std::get<2>(entry)));
            break;
          case sourcemeta::hydra::http::Method::PATCH:
            app.patch(std::get<1>(entry), UWS_CALLBACK(std::get<2>(entry)));
            break;
        }
      }

      assert(this->fallback);
      app.any("/*", UWS_CALLBACK(this->fallback));
#undef UWS_CALLBACK

      app.listen(static_cast<int>(port),
                 [port, this](us_listen_socket_t *const socket) -> void {
                   if (socket) {
                     const auto socket_port = us_socket_local_port(
                         true, reinterpret_cast<struct us_socket_t *>(socket));
                     assert(socket_port > 0);
                     assert(port == static_cast<std::uint32_t>(socket_port));
                     this->logger
                         << "Listening on port " + std::to_string(socket_port);
                   } else {
                     this->logger
                         << "Failed to listen on port " + std::to_string(port);
                   }
                 });
    });

    // This method only returns on failure
    this->logger << "Failed to listen on port " + std::to_string(port);
    return EXIT_FAILURE;
  }

private:
  std::vector<
      std::tuple<sourcemeta::hydra::http::Method, std::string, RouteCallback>>
      routes;
  RouteCallback fallback;
  ErrorCallback error_handler;
  ServerLogger logger{"global"};
};

auto serve_file(const std::filesystem::path &file_path,
                const ServerRequest &request, ServerResponse &response,
                const sourcemeta::hydra::http::Status code =
                    sourcemeta::hydra::http::Status::OK) -> void {
  assert(request.method() == sourcemeta::hydra::http::Method::GET ||
         request.method() == sourcemeta::hydra::http::Method::HEAD);

  // Its the responsibility of the caller to ensure the file path
  // exists, otherwise we cannot know how the application prefers
  // to react to such case.
  assert(std::filesystem::exists(file_path));
  assert(std::filesystem::is_regular_file(file_path));

  const auto last_write_time{std::filesystem::last_write_time(file_path)};
  const auto last_modified{
      std::chrono::time_point_cast<std::chrono::system_clock::duration>(
          last_write_time - std::filesystem::file_time_type::clock::now() +
          std::chrono::system_clock::now())};

  if (!request.header_if_modified_since(last_modified)) {
    response.status(sourcemeta::hydra::http::Status::NOT_MODIFIED);
    response.end();
    return;
  }

  std::ifstream stream{std::filesystem::canonical(file_path)};
  stream.exceptions(std::ifstream::failbit | std::ifstream::badbit);
  assert(!stream.fail());
  assert(stream.is_open());

  std::ostringstream contents;
  contents << stream.rdbuf();
  std::ostringstream etag;
  sourcemeta::core::md5(contents.str(), etag);

  if (!request.header_if_none_match(etag.str())) {
    response.status(sourcemeta::hydra::http::Status::NOT_MODIFIED);
    response.end();
    return;
  }

  response.status(code);
  response.header("Content-Type", sourcemeta::hydra::mime_type(file_path));
  response.header_etag(etag.str());
  response.header_last_modified(last_modified);

  if (request.method() == sourcemeta::hydra::http::Method::HEAD) {
    response.head(contents.str());
  } else {
    response.end(contents.str());
  }
}

#endif
