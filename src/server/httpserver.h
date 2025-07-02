#ifndef SOURCEMETA_REGISTRY_HTTPSERVER_H
#define SOURCEMETA_REGISTRY_HTTPSERVER_H

#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/md5.h>
#include <sourcemeta/core/uuid.h>

#include <sourcemeta/hydra/http.h>

#if defined(__clang__)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
#pragma clang diagnostic ignored "-Wshadow"
#pragma clang diagnostic ignored "-Wnewline-eof"
#pragma clang diagnostic ignored "-Wsign-compare"
#pragma clang diagnostic ignored "-Wunused-variable"
#pragma clang diagnostic ignored "-Wunused-parameter"
#elif defined(__GNUC__)
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wshadow"
#pragma GCC diagnostic ignored "-Wsign-compare"
#pragma GCC diagnostic ignored "-Wunused-parameter"
#endif
#include <src/App.h>
#include <src/LocalCluster.h>
#if defined(__clang__)
#pragma clang diagnostic pop
#elif defined(__GNUC__)
#pragma GCC diagnostic pop
#endif

#include <cassert>     // assert
#include <chrono>      // std::chrono::system_clock
#include <cstdint>     // std::uint32_t
#include <cstdlib>     // EXIT_FAILURE
#include <cstring>     // memset
#include <exception>   // std::exception_ptr
#include <filesystem>  // std::filesystem::path
#include <fstream>     // std::ifstream
#include <functional>  // std::function
#include <iostream>    // std::cerr
#include <map>         // std::map
#include <mutex>       // std::mutex, std::lock_guard
#include <optional>    // std::optional
#include <ostream>     // std::ostream
#include <sstream>     // std::ostringstream
#include <stdexcept>   // std::invalid_argument
#include <string>      // std::string
#include <string_view> // std::string_view
#include <thread>      // std::this_thread
#include <tuple>       // std::tuple
#include <utility>     // std::move
#include <vector>      // std::vector

enum class ServerContentEncoding { Identity, GZIP };

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

auto header_if_none_match(uWS::HttpRequest *handler, std::string_view value)
    -> bool {
  assert(!value.starts_with('W'));

  const auto if_none_match{handler->getHeader("if-none-match")};
  if (if_none_match.empty()) {
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

  for (const auto &etag :
       sourcemeta::hydra::http::header_list(std::string{if_none_match})) {
    if (etag.first == "*") {
      // Cache hit
      return false;
    } else if (etag.first.starts_with('W') &&
               etag.first == etag_value_weak.str()) {
      // Cache hit
      return false;
    } else if (etag.first.starts_with('"') && etag.first == etag_value.str()) {
      // Cache hit
      return false;
    }
  }

  // As a fallback, serve real content
  return true;
}

auto header_if_modified_since(
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

auto serve_file(const std::filesystem::path &file_path,
                uWS::HttpRequest *request, ServerResponse &response,
                const sourcemeta::hydra::http::Status code =
                    sourcemeta::hydra::http::Status::OK) -> void {
  assert(request->getMethod() == "get" || request->getMethod() == "head");

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

  if (!header_if_modified_since(request, last_modified)) {
    response.status = sourcemeta::hydra::http::Status::NOT_MODIFIED;
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
  etag << '"';
  sourcemeta::core::md5(contents.str(), etag);
  etag << '"';

  if (!header_if_none_match(request, etag.str())) {
    response.status = sourcemeta::hydra::http::Status::NOT_MODIFIED;
    response.end();
    return;
  }

  response.status = code;
  response.header("Content-Type", sourcemeta::hydra::mime_type(file_path));
  response.header("ETag", etag.str());
  response.header("Last-Modified",
                  sourcemeta::hydra::http::to_gmt(last_modified));

  if (request->getMethod() == "head") {
    response.head(contents.str());
  } else {
    response.end(contents.str());
  }
}

#endif
