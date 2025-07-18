#ifndef SOURCEMETA_JSONSCHEMA_HTTP_REQUEST_H
#define SOURCEMETA_JSONSCHEMA_HTTP_REQUEST_H

#ifndef SOURCEMETA_JSONSCHEMA_HTTP_EXPORT
#include <sourcemeta/jsonschema/http_export.h>
#endif

#include <sourcemeta/jsonschema/http_response.h>
#include <sourcemeta/jsonschema/http_stream.h>

#include <initializer_list> // std::initializer_list
#include <istream>          // std::istream
#include <set>              // std::set
#include <string>           // std::string
#include <string_view>      // std::string_view

namespace sourcemeta::jsonschema::http {

/// @ingroup http
/// This class is used to perform a non-streaming HTTP request.
class SOURCEMETA_JSONSCHEMA_HTTP_EXPORT ClientRequest {
public:
  /// Construct an HTTP request to a given URL. For example:
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <cassert>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"};
  /// request.method(sourcemeta::jsonschema::http::Method::GET);
  /// sourcemeta::jsonschema::http::ClientResponse
  /// response{request.send().get()}; assert(response.status() ==
  /// sourcemeta::jsonschema::http::Status::OK);
  /// ```
  ClientRequest(std::string url);

  /// Specify the HTTP method to use for the request. If not set, it defauls to
  /// `GET`. For example:
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <cassert>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"};
  ///
  /// // Send a POST request
  /// request.method(sourcemeta::jsonschema::http::Method::POST);
  ///
  /// sourcemeta::jsonschema::http::ClientResponse
  /// response{request.send().get()}; assert(response.status() ==
  /// sourcemeta::jsonschema::http::Status::OK);
  /// ```
  auto method(const Method method) noexcept -> void;

  /// Retrieve the HTTP method that the request will be sent with. For example:
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <iostream>
  /// #include <cassert>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"};
  /// request.method(sourcemeta::jsonschema::http::Method::HEAD);
  /// assert(request.method() == sourcemeta::jsonschema::http::Method::HEAD);
  /// ```
  auto method() const noexcept -> Method;

  /// Express a desire of capturing a specific response header, if sent by the
  /// server.
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <cassert>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"};
  /// request.method(sourcemeta::jsonschema::http::Method::GET);
  /// request.capture("content-type");
  /// sourcemeta::jsonschema::http::ClientResponse
  /// response{request.send().get()};
  /// assert(response.header("content-type").has_value());
  /// assert(response.header("content-type").value()
  ///   == "text/html; charset=UTF-8");
  /// ```
  auto capture(std::string header) -> void;

  /// Express a desire of capturing a set of response headers, if sent by the
  /// server.
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <cassert>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"};
  /// request.method(sourcemeta::jsonschema::http::Method::GET);
  /// request.capture({ "content-type", "content-encoding", "x-foo" });
  /// sourcemeta::jsonschema::http::ClientResponse
  /// response{request.send().get()};
  /// assert(response.header("content-type").has_value());
  /// assert(response.header("content-encoding").has_value());
  /// assert(!response.header("x-foo").has_value());
  /// ```
  auto capture(std::initializer_list<std::string> headers) -> void;

  /// Express a desire of capturing every response headers. For example:
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <cassert>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"};
  /// request.method(sourcemeta::jsonschema::http::Method::GET);
  /// request.capture();
  /// sourcemeta::jsonschema::http::ClientResponse
  /// response{request.send().get()};
  /// assert(response.header("content-type").has_value());
  /// assert(response.header("content-encoding").has_value());
  /// ```
  auto capture() -> void;

  /// Set an HTTP request header. For example:
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <cassert>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"}; request.header("X-Send-With",
  /// "jsonschema"); sourcemeta::jsonschema::http::ClientResponse
  /// response{request.send().get()}; assert(response.status() ==
  /// sourcemeta::jsonschema::http::Status::OK);
  /// ```
  auto header(std::string_view key, std::string_view value) -> void;

  /// Set an HTTP request header whose value is an integer. For example:
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <cassert>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"}; request.header("X-Favourite-Number",
  /// 3); sourcemeta::jsonschema::http::ClientResponse
  /// response{request.send().get()}; assert(response.status() ==
  /// sourcemeta::jsonschema::http::Status::OK);
  /// ```
  auto header(std::string_view key, int value) -> void;

  /// Retrieve the URL that the request will be sent to. For example:
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <iostream>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"}; std::cout << request.url() << "\n";
  /// ```
  auto url() const -> std::string_view;

  /// Perform the HTTP request without a body. For example:
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <cassert>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"};
  /// request.method(sourcemeta::jsonschema::http::Method::GET);
  /// sourcemeta::jsonschema::http::ClientResponse response{request.send()};
  /// assert(response.status() == sourcemeta::jsonschema::http::Status::OK);
  /// ```
  auto send() -> ClientResponse;

  /// Perform the HTTP request with a body. For example:
  ///
  /// ```cpp
  /// #include <sourcemeta/jsonschema/http.h>
  /// #include <cassert>
  /// #include <sstream>
  ///
  /// sourcemeta::jsonschema::http::ClientRequest
  /// request{"https://www.example.com"};
  /// request.method(sourcemeta::jsonschema::http::Method::GET);
  /// std::istringstream body{"hello world"};
  /// sourcemeta::jsonschema::http::ClientResponse response{
  ///   request.send(body)};
  /// assert(response.status() == sourcemeta::jsonschema::http::Status::OK);
  /// ```
  auto send(std::istream &body) -> ClientResponse;

private:
  ClientStream stream;
// Exporting symbols that depends on the standard C++ library is considered
// safe.
// https://learn.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-2-c4275?view=msvc-170&redirectedfrom=MSDN
#if defined(_MSC_VER)
#pragma warning(disable : 4251)
#endif
  std::set<std::string> capture_;
#if defined(_MSC_VER)
#pragma warning(default : 4251)
#endif
  bool capture_all_{false};
};

} // namespace sourcemeta::jsonschema::http

#endif
