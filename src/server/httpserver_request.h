#ifndef SOURCEMETA_REGISTRY_HTTPSERVER_REQUEST_H
#define SOURCEMETA_REGISTRY_HTTPSERVER_REQUEST_H

#include <sourcemeta/hydra/http.h>

#include "uwebsockets.h"

#include <cassert>     // assert
#include <chrono>      // std::chrono::system_clock::time_point
#include <cstdint>     // std::uint8_t
#include <optional>    // std::optional
#include <sstream>     // std::ostringstream
#include <stdexcept>   // std::invalid_argument
#include <string>      // std::string
#include <string_view> // std::string_view

class ServerRequest {
public:
  ServerRequest(uWS::HttpRequest *data) : handler{data} {
    assert(this->handler);
  }

  ~ServerRequest() {}

  auto method() const -> sourcemeta::hydra::http::Method {
    return sourcemeta::hydra::http::to_method(this->handler->getMethod());
  }

  auto header(std::string_view key) const -> std::optional<std::string> {
    const std::string_view value{this->handler->getHeader(key)};
    if (value.empty()) {
      return std::nullopt;
    } else {
      return std::string{value};
    }
  }

  auto header_list(std::string_view key) const -> std::optional<
      std::vector<sourcemeta::hydra::http::HeaderListElement>> {
    const auto header_string{this->header(key)};
    if (!header_string.has_value()) {
      return std::nullopt;
    }

    return sourcemeta::hydra::http::header_list(header_string.value());
  }

  auto header_gmt(std::string_view key) const
      -> std::optional<std::chrono::system_clock::time_point> {
    const auto header_string{this->header(key)};
    if (!header_string.has_value()) {
      return std::nullopt;
    }

    return sourcemeta::hydra::http::header_gmt(header_string.value());
  }

  auto header_if_modified_since(
      const std::chrono::system_clock::time_point last_modified) const -> bool {
    // `If-Modified-Since` can only be used with a `GET` or `HEAD`.
    // See
    // https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/If-Modified-Since
    if (this->method() != sourcemeta::hydra::http::Method::GET &&
        this->method() != sourcemeta::hydra::http::Method::HEAD) {
      return true;
    }

    try {
      const auto if_modified_since{this->header_gmt("if-modified-since")};
      // If the client didn't express a modification baseline to compare to,
      // then we just tell it that it has been modified
      if (!if_modified_since.has_value()) {
        return true;
      }

      // Time comparison can be flaky, but adding a bit of tolerance leads
      // to more consistent behavior.
      return (if_modified_since.value() + std::chrono::seconds(1)) <
             last_modified;
      // If there is an error parsing the `If-Modified-Since` timestamp, don't
      // abort, but lean on the safe side: the requested resource has been
      // modified
    } catch (const std::invalid_argument &) {
      return true;
    }
  }

  auto header_if_none_match(std::string_view value) const -> bool {
    assert(!value.starts_with('W'));

    const auto if_none_match{this->header_list("if-none-match")};
    if (!if_none_match.has_value()) {
      // Serve real content
      return true;
    }

    std::ostringstream etag_value;
    std::ostringstream etag_value_weak;

    if (value.starts_with('"') && value.ends_with('"')) {
      etag_value << value;
      etag_value_weak << 'W' << '/' << value;
    } else {
      etag_value << '"' << value << '"';
      etag_value_weak << 'W' << '/' << '"' << value << '"';
    }

    for (const auto &etag : if_none_match.value()) {
      if (etag.first == "*") {
        // Cache hit
        return false;
      } else if (etag.first.starts_with('W') &&
                 etag.first == etag_value_weak.str()) {
        // Cache hit
        return false;
      } else if (etag.first.starts_with('"') &&
                 etag.first == etag_value.str()) {
        // Cache hit
        return false;
      }
    }

    // As a fallback, serve real content
    return true;
  }

  auto query(std::string_view key) const -> std::optional<std::string> {
    const std::string_view value{this->handler->getQuery(key)};
    if (value.empty()) {
      return std::nullopt;
    } else {
      return std::string{value};
    }
  }

  auto path() const -> std::string {
    return std::string{this->handler->getUrl()};
  }

  auto parameter(const std::uint8_t index) const -> std::string {
    return std::string{this->handler->getParameter(index)};
  }

private:
  uWS::HttpRequest *handler;
};

#endif
