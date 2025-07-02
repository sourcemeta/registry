#ifndef SOURCEMETA_REGISTRY_HTTPSERVER_RESPONSE_H
#define SOURCEMETA_REGISTRY_HTTPSERVER_RESPONSE_H

#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/hydra/http.h>

#include "uwebsockets.h"

#include <cassert>     // assert
#include <chrono>      // std::chrono::system_clock::time_point
#include <cstring>     // memset
#include <map>         // std::map
#include <sstream>     // std::ostringstream
#include <stdexcept>   // std::runtime_error
#include <string>      // std::string
#include <string_view> // std::string_view

enum class ServerContentEncoding { Identity, GZIP };

class ServerResponse {
public:
  ServerResponse(uWS::HttpResponse<true> *data) : handler{data} {
    assert(this->handler);
  }

  ~ServerResponse() {}

  auto status(const sourcemeta::hydra::http::Status status_code) -> void {
    this->code = status_code;
  }

  auto status() const -> sourcemeta::hydra::http::Status { return this->code; }

  auto header(std::string_view key, std::string_view value) -> void {
    this->headers.emplace(key, value);
  }

  auto header_last_modified(const std::chrono::system_clock::time_point time)
      -> void {
    this->header("Last-Modified", sourcemeta::hydra::http::to_gmt(time));
  }

  auto header_etag(std::string_view value) -> void {
    assert(!value.empty());
    assert(!value.starts_with('W'));

    if (value.starts_with('"') && value.ends_with('"')) {
      this->header("ETag", value);
    } else {
      std::ostringstream etag;
      etag << '"' << value << '"';
      this->header("ETag", etag.str());
    }
  }

  auto header_etag_weak(std::string_view value) -> void {
    assert(!value.empty());

    if (value.starts_with('W')) {
      this->header("ETag", value);
    } else if (value.starts_with('"') && value.ends_with('"')) {
      std::ostringstream etag;
      etag << 'W' << '/' << value;
      this->header("ETag", etag.str());
    } else {
      std::ostringstream etag;
      etag << 'W' << '/' << '"' << value << '"';
      this->header("ETag", etag.str());
    }
  }

  auto encoding(const ServerContentEncoding encoding) -> void {
    switch (encoding) {
      case ServerContentEncoding::GZIP:
        this->header("Content-Encoding", "gzip");
        break;
      case ServerContentEncoding::Identity:
        break;
    }

    this->content_encoding = encoding;
  }

  auto end(const std::string_view message) -> void {
    std::ostringstream code_string;
    code_string << this->code;
    this->handler->writeStatus(code_string.str());

    for (const auto &[key, value] : this->headers) {
      this->handler->writeHeader(key, value);
    }

    if (this->content_encoding == ServerContentEncoding::GZIP) {
      auto result{sourcemeta::core::gzip(message)};
      if (!result.has_value()) {
        throw std::runtime_error("Compression failed");
      }

      this->handler->end(result.value());
    } else if (this->content_encoding == ServerContentEncoding::Identity) {
      this->handler->end(message);
    }
  }

  auto head(const std::string_view message) -> void {
    std::ostringstream code_string;
    code_string << this->code;
    this->handler->writeStatus(code_string.str());

    for (const auto &[key, value] : this->headers) {
      this->handler->writeHeader(key, value);
    }

    if (this->content_encoding == ServerContentEncoding::GZIP) {
      auto result{sourcemeta::core::gzip(message)};
      if (!result.has_value()) {
        throw std::runtime_error("Compression failed");
      }

      this->handler->endWithoutBody(result.value().size());
      this->handler->end();
    } else if (this->content_encoding == ServerContentEncoding::Identity) {
      this->handler->endWithoutBody(message.size());
      this->handler->end();
    }
  }

  auto end(const sourcemeta::core::JSON &document) -> void {
    std::ostringstream output;
    sourcemeta::core::prettify(document, output);
    this->end(output.str());
  }

  auto head(const sourcemeta::core::JSON &document) -> void {
    std::ostringstream output;
    sourcemeta::core::prettify(document, output);
    this->head(output.str());
  }

  auto end(const sourcemeta::core::JSON &document,
           const sourcemeta::core::JSON::KeyComparison &compare) -> void {
    std::ostringstream output;
    sourcemeta::core::prettify(document, output, compare);
    this->end(output.str());
  }

  auto head(const sourcemeta::core::JSON &document,
            const sourcemeta::core::JSON::KeyComparison &compare) -> void {
    std::ostringstream output;
    sourcemeta::core::prettify(document, output, compare);
    this->head(output.str());
  }

  auto end() -> void {
    std::ostringstream code_string;
    code_string << this->code;
    this->handler->writeStatus(code_string.str());

    for (const auto &[key, value] : this->headers) {
      this->handler->writeHeader(key, value);
    }

    this->handler->end();
  }

  uWS::HttpResponse<true> *handler;

private:
  sourcemeta::hydra::http::Status code{sourcemeta::hydra::http::Status::OK};
  std::map<std::string, std::string> headers;
  ServerContentEncoding content_encoding = ServerContentEncoding::Identity;
};

#endif
