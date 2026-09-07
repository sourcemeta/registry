#ifndef SOURCEMETA_ONE_HTTP_HELPERS_H
#define SOURCEMETA_ONE_HTTP_HELPERS_H

#include <sourcemeta/core/http.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/numeric.h>
#include <sourcemeta/core/text.h>
#include <sourcemeta/core/time.h>

#include <sourcemeta/one/http_request.h>
#include <sourcemeta/one/http_response.h>
#include <sourcemeta/one/shared.h>

#include <algorithm>   // std::ranges::equal
#include <array>       // std::array
#include <cassert>     // assert
#include <chrono>      // std::chrono::system_clock, std::chrono::steady_clock
#include <cstddef>     // std::size_t
#include <cstdint>     // std::uint8_t, std::uint16_t
#include <format>      // std::format
#include <mutex>       // std::mutex, std::scoped_lock
#include <optional>    // std::optional
#include <print>       // std::print
#include <span>        // std::span
#include <sstream>     // std::ostringstream
#include <string>      // std::string
#include <string_view> // std::string_view
#include <thread>      // std::this_thread
#include <utility>     // std::pair
#include <vector>      // std::vector

namespace sourcemeta::one {

// Which request fields a cache must key a stored response on (RFC 9110 Section
// 12.5.5), composed once each rather than written out at each site. Content is
// negotiated on the encoding everywhere, and an answer that differs by who
// asked names whatever placed them in their view alongside it, since a cache
// keyed on less would hand one caller's answer to the next

[[nodiscard]] inline auto vary_encoding() -> std::string_view {
  static const std::array<std::string_view, 1> FIELDS{{"Accept-Encoding"}};
  static const std::string VALUE{
      sourcemeta::core::http_format_vary(FIELDS).value()};
  return VALUE;
}

[[nodiscard]] inline auto vary_type_and_encoding() -> std::string_view {
  static const std::array<std::string_view, 2> FIELDS{
      {"Accept", "Accept-Encoding"}};
  static const std::string VALUE{
      sourcemeta::core::http_format_vary(FIELDS).value()};
  return VALUE;
}

[[nodiscard]] inline auto vary_client_and_encoding() -> std::string_view {
  static const std::array<std::string_view, 2> FIELDS{
      {"User-Agent", "Accept-Encoding"}};
  static const std::string VALUE{
      sourcemeta::core::http_format_vary(FIELDS).value()};
  return VALUE;
}

[[nodiscard]] inline auto vary_caller_and_encoding() -> std::string_view {
  static const std::array<std::string_view, 3> FIELDS{
      {"Accept-Encoding", "Authorization", "Cookie"}};
  static const std::string VALUE{
      sourcemeta::core::http_format_vary(FIELDS).value()};
  return VALUE;
}

[[nodiscard]] inline auto vary_origin() -> std::string_view {
  static const std::array<std::string_view, 1> FIELDS{{"Origin"}};
  static const std::string VALUE{
      sourcemeta::core::http_format_vary(FIELDS).value()};
  return VALUE;
}

// Every caching directive this server sends, spelled through the type RFC 9111
// defines them in rather than as a literal at each site. Each is fixed, so
// each is spelled once and handed out as a view from then on

// RFC 9111 Section 5.2.2.5: no cache may store any part of the exchange, which
// is what an answer computed for one request and one caller says
[[nodiscard]] inline auto cache_control_no_store() -> std::string_view {
  static const std::string DIRECTIVES{
      sourcemeta::core::http_serialize_cache_control({.no_store = true})
          .value()};
  return DIRECTIVES;
}

// The same directives under each visibility, since which caches may store a
// response follows from who was admitted to it: one served only to a caller
// carrying a credential must never be handed by a shared cache to the next
class CacheControlPair {
public:
  explicit CacheControlPair(sourcemeta::core::HTTPCacheControl directives) {
    directives.visibility = sourcemeta::core::HTTPCacheVisibility::Public;
    this->shared_ =
        sourcemeta::core::http_serialize_cache_control(directives).value();
    directives.visibility = sourcemeta::core::HTTPCacheVisibility::Private;
    this->personal_ =
        sourcemeta::core::http_serialize_cache_control(directives).value();
  }

  [[nodiscard]] auto of(const bool is_public) const noexcept
      -> std::string_view {
    return is_public ? this->shared_ : this->personal_;
  }

private:
  std::string shared_;
  std::string personal_;
};

// Served registry content, which a cache may hold but never reuse without
// asking again, so that a change reaches a caller on their next request
[[nodiscard]] inline auto cache_control_content(const bool is_public)
    -> std::string_view {
  static const CacheControlPair DIRECTIVES{
      {.max_age = std::chrono::seconds{0}, .must_revalidate = true}};
  return DIRECTIVES.of(is_public);
}

// Search results, where a freshness window amortises the full-text cost across
// the bursts of typing into a search box without serving a stale ranking for
// long
[[nodiscard]] inline auto cache_control_search(const bool is_public)
    -> std::string_view {
  static const CacheControlPair DIRECTIVES{
      {.max_age = std::chrono::seconds{60}}};
  return DIRECTIVES.of(is_public);
}

// A static asset carrying its build in its own name, which is why RFC 8246
// lets a cache keep it for a year without ever asking again
[[nodiscard]] inline auto cache_control_immutable(const bool is_public)
    -> std::string_view {
  static const CacheControlPair DIRECTIVES{
      {.max_age = std::chrono::seconds{31536000}, .immutable = true}};
  return DIRECTIVES.of(is_public);
}

// A line about something that happened, optionally naming the one value it
// happened to, such as the policy a failure concerns. Keeping the value apart
// from the message means neither has to be built into a string to say both
inline auto http_log(const std::string_view message,
                     const std::string_view value = {}) -> void {
  static std::mutex log_mutex;
  std::scoped_lock guard{log_mutex};
  const auto now{
      sourcemeta::core::to_imf_fixdate(std::chrono::system_clock::now())};
  if (value.empty()) {
    std::print(stderr, "[{}] {} {}\n", now, std::this_thread::get_id(),
               message);
  } else {
    std::print(stderr, "[{}] {} {}: {}\n", now, std::this_thread::get_id(),
               message, value);
  }
}

inline auto write_link_header(HTTPResponse &response,
                              const std::string_view schema_path) -> void {
  response.write_header("Link",
                        sourcemeta::core::http_format_link(
                            {.target = schema_path, .rel = "describedby"}));
}

// RFC 9110 §10.1.1: any expectation other than `100-continue` is
// unsupported. uWS auto-acknowledges `100-continue` via router
// middleware before our handler runs, so by the time we read the
// `Expect` header here, the only values that can still appear are
// either empty or something we cannot honour. The expectation
// token is case-insensitive per the same section, so case-fold
// the inbound value before the compare.
inline auto expect_header_unrecognised(const HTTPRequest &request) -> bool {
  const auto expect{request.header("expect")};
  return !expect.empty() &&
         !std::ranges::equal(expect, std::string_view{"100-continue"},
                             [](const char left, const char right) -> bool {
                               return sourcemeta::core::to_lowercase(left) ==
                                      right;
                             });
}

// RFC 9110 §8.6 + §15.5.14: if the client declares a `Content-Length`
// that already exceeds the inbound body cap, refuse before reading
// the body. uWS has already sent its automatic `100 Continue` for
// `Expect: 100-continue` requests, but well-behaved clients abort
// their upload on a mid-stream 4xx, so the fast-fail still saves
// both sides bandwidth versus reading bytes until the cap trips.
inline auto
request_body_too_large(const HTTPRequest &request,
                       const std::size_t max_body = MAX_REQUEST_BODY_BYTES)
    -> bool {
  const auto declared{
      sourcemeta::core::to_uint64_t(request.header("content-length"))};
  return declared.has_value() && declared.value() > max_body;
}

// Answering can be the last thing that happens on a connection, and a request
// read asynchronously is held by the very handler that goes away with it. So
// what is said about a request is taken while it is certainly still there,
// which costs nothing, as the line was built either way
inline auto send_response(const sourcemeta::core::HTTPStatus &status,
                          const HTTPRequest &request, HTTPResponse &response)
    -> void {
  const auto line{
      std::format("{} {} {}", status.wire, request.method(), request.path())};
  response.send_without_content();
  http_log(line);
  request.observation().record(status.code);
}

inline auto send_response(
    const sourcemeta::core::HTTPStatus &status, const HTTPRequest &request,
    HTTPResponse &response, const std::string &message,
    const Encoding current_encoding,
    const std::optional<std::size_t> precomputed_compressed_size = std::nullopt)
    -> void {
  const auto line{
      std::format("{} {} {}", status.wire, request.method(), request.path())};
  response.send(request, message, current_encoding,
                precomputed_compressed_size);
  http_log(line);
  request.observation().record(status.code);
}

// RFC 9110 §9.3.7: OPTIONS responses describe communication options
// for the target resource. Fetch §3.2.2 (CORS preflight): non-simple
// cross-origin requests issue an OPTIONS preflight whose ACK shape
// (status 204 + Access-Control-Allow-*) governs whether the actual
// request fires. The per-surface `allow_methods` and `allow_headers`
// are required so each action declares its own contract explicitly,
// matching the K and L disciplines.
// https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.7
// https://fetch.spec.whatwg.org/#cors-preflight-fetch
inline auto cors_preflight(const HTTPRequest &request, HTTPResponse &response,
                           const std::string_view allow_methods,
                           const std::string_view allow_headers) -> void {
  assert(!allow_methods.empty());
  assert(!allow_headers.empty());
  assert(allow_methods.find_first_of("\r\n") == std::string_view::npos);
  assert(allow_headers.find_first_of("\r\n") == std::string_view::npos);
  response.write_status(sourcemeta::core::HTTP_STATUS_NO_CONTENT);
  response.write_header("Access-Control-Allow-Origin", "*");
  response.write_header("Access-Control-Expose-Headers", "Link, ETag");
  response.write_header("Access-Control-Allow-Methods", allow_methods);
  response.write_header("Access-Control-Allow-Headers", allow_headers);
  response.write_header("Access-Control-Max-Age", "3600");
  // Browser preflight cache is governed by `Access-Control-Max-Age`;
  // `no-store` keeps shared HTTP caches from storing this response.
  response.write_header("Cache-Control", cache_control_no_store());
  // RFC 9110 §9.3.7: OPTIONS responses SHOULD include Allow. Different
  // audience than Access-Control-Allow-Methods (HTTP vs CORS preflight).
  response.write_header("Allow", allow_methods);
  send_response(sourcemeta::core::HTTP_STATUS_NO_CONTENT, request, response);
}

// RFC 6750 Section 3 has the Bearer scheme carry at least one parameter, and
// the realm is the conventional one every denial on this surface names
inline constexpr std::string_view CHALLENGE_SCHEME{"Bearer"};
inline constexpr std::array<std::pair<std::string_view, std::string_view>, 1>
    CHALLENGE_REALM{{{"realm", "registry"}}};

// RFC 9110 Section 15.5.2: a 401 response MUST carry `WWW-Authenticate`. A
// route may name parameters of its own beyond the realm, and one that cannot
// be spelled as a challenge is dropped rather than sent, since the header is
// required whatever the route wanted to add
inline auto write_challenge(
    HTTPResponse &response,
    const std::span<const std::pair<std::string_view, std::string_view>>
        extension) -> void {
  std::string value;
  if (!extension.empty()) {
    std::vector<std::pair<std::string_view, std::string_view>> parameters{
        CHALLENGE_REALM.cbegin(), CHALLENGE_REALM.cend()};
    parameters.insert(parameters.cend(), extension.begin(), extension.end());
    // A refusal leaves nothing behind, so the realm alone answers below
    sourcemeta::core::http_serialize_challenge(
        {.scheme = CHALLENGE_SCHEME, .parameters = parameters}, value);
  }

  if (value.empty()) {
    sourcemeta::core::http_serialize_challenge(
        {.scheme = CHALLENGE_SCHEME, .parameters = CHALLENGE_REALM}, value);
  }

  response.write_header("WWW-Authenticate", value);
}

// CORS scope is required at every error site. No default for `origin` so a
// caller cannot silently widen a restricted-origin handler to wildcard. An
// empty origin means the route is CORS-disabled and no Allow-Origin or
// Expose-Headers should appear on the error response.
inline auto
json_error(const HTTPRequest &request, HTTPResponse &response,
           const sourcemeta::core::HTTPStatus &status,
           const std::string_view type, const std::string_view detail,
           const std::string_view schema, const std::string_view origin,
           const std::string_view allow = {},
           const std::span<const std::pair<std::string_view, std::string_view>>
               challenge = {}) -> void {
  // Header values are written to the wire verbatim. CR/LF would split
  // headers, enabling response header injection or CORS widening. Today's
  // callers pass string literals, but the asserts catch future untrusted
  // forwards. The challenge is spelled by a serialiser that refuses whatever
  // a header cannot carry, so it needs no guard of its own
  assert(origin.find_first_of("\r\n") == std::string_view::npos);
  assert(allow.find_first_of("\r\n") == std::string_view::npos);
  const auto body{sourcemeta::core::http_make_problem_details(
      {.status = status, .type = type, .detail = detail})};

  response.write_status(status);
  response.write_header("Content-Type", "application/problem+json");
  // RFC 9111 §5.2.2.5: a stale error response is a footgun for both
  // shared caches and the client. The error condition is dynamic
  // (the request shape, server state, the moment) and a 500 cached
  // even briefly turns a transient hiccup into a sticky outage.
  // Apply uniformly across every error envelope.
  response.write_header("Cache-Control", cache_control_no_store());
  if (!origin.empty()) {
    response.write_header("Access-Control-Allow-Origin", origin);
    // A challenge a browser cannot read is a challenge it cannot answer, so
    // the header a 401 carries is exposed alongside the rest
    response.write_header("Access-Control-Expose-Headers",
                          status == sourcemeta::core::HTTP_STATUS_UNAUTHORIZED
                              ? "Link, ETag, WWW-Authenticate"
                              : "Link, ETag");
    // RFC 9110 §12.5.5: when the response origin is anything other than
    // the wildcard, CORS-aware caches must key on the request's Origin
    // header. Otherwise origin A's cached response can be served to
    // origin B.
    // https://datatracker.ietf.org/doc/html/rfc9110#section-12.5.5
    if (origin != "*") {
      response.write_header("Vary", vary_origin());
    }
  }
  // RFC 9110 §15.5.6: 405 responses MUST carry Allow listing supported methods.
  // https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.6
  if (!allow.empty() &&
      status == sourcemeta::core::HTTP_STATUS_METHOD_NOT_ALLOWED) {
    response.write_header("Allow", allow);
  }
  // The machine surface authenticates with bearer credentials only, so the
  // scheme is constant and only the parameters a route names vary
  // https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.2
  // https://datatracker.ietf.org/doc/html/rfc6750#section-3
  if (status == sourcemeta::core::HTTP_STATUS_UNAUTHORIZED) {
    write_challenge(response, challenge);
  }
  if (!schema.empty()) {
    write_link_header(response, schema);
  }

  std::ostringstream output;
  sourcemeta::core::prettify(body, output);
  send_response(status, request, response, output.str(), Encoding::Identity);
}

// Whether the caller prefers an HTML representation over JSON. The Accept
// header is negotiated with quality values rather than matched literally, so a
// browser presenting its full Accept list is recognised, while a client that
// asks for JSON, or asks for nothing, is not
[[nodiscard]] inline auto prefers_html(const std::string_view accept) -> bool {
  return sourcemeta::core::http_match_accept(
             accept, {"application/json", "text/html"}) == "text/html";
}

// The single shape of an authentication denial on the HTTP surface, so
// every protected resource answers identically
inline auto json_error_unauthorized(
    const HTTPRequest &request, HTTPResponse &response,
    const std::string_view schema, const std::string_view origin,
    const std::span<const std::pair<std::string_view, std::string_view>>
        challenge = {}) -> void {
  json_error(request, response, sourcemeta::core::HTTP_STATUS_UNAUTHORIZED,
             "urn:sourcemeta:one:authentication-required",
             "This resource requires authentication", schema, origin, {},
             challenge);
}

} // namespace sourcemeta::one

#endif
