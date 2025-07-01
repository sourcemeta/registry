#include <sourcemeta/core/gzip.h>
#include <sourcemeta/hydra/httpserver_response.h>

#include "uwebsockets.h"

#include <cassert>     // assert
#include <cstring>     // memset
#include <sstream>     // std::ostringstream
#include <stdexcept>   // std::runtime_error
#include <string>      // std::string
#include <string_view> // std::string_view

namespace sourcemeta::hydra::http {

struct ServerResponse::Internal {
  uWS::HttpResponse<true> *handler;
};

ServerResponse::ServerResponse(void *const handler)
    : internal{std::make_unique<ServerResponse::Internal>()} {
  assert(handler);
  this->internal->handler = static_cast<uWS::HttpResponse<true> *>(handler);
}

ServerResponse::~ServerResponse() {}

auto ServerResponse::status(const Status status_code) -> void {
  this->code = status_code;
}

auto ServerResponse::status() const -> Status { return this->code; }

auto ServerResponse::header(std::string_view key, std::string_view value)
    -> void {
  this->headers.emplace(key, value);
}

auto ServerResponse::header_last_modified(
    const std::chrono::system_clock::time_point time) -> void {
  this->header("Last-Modified", to_gmt(time));
}

auto ServerResponse::header_etag(std::string_view value) -> void {
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

auto ServerResponse::header_etag_weak(std::string_view value) -> void {
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

auto ServerResponse::encoding(const ServerContentEncoding encoding) -> void {
  switch (encoding) {
    case ServerContentEncoding::GZIP:
      this->header("Content-Encoding", "gzip");
      break;
    case ServerContentEncoding::Identity:
      break;
  }

  this->content_encoding = encoding;
}

auto ServerResponse::end(const std::string_view message) -> void {
  std::ostringstream code_string;
  code_string << this->code;
  this->internal->handler->writeStatus(code_string.str());

  for (const auto &[key, value] : this->headers) {
    this->internal->handler->writeHeader(key, value);
  }

  if (this->content_encoding == ServerContentEncoding::GZIP) {
    auto result{sourcemeta::core::gzip(message)};
    if (!result.has_value()) {
      throw std::runtime_error("Compression failed");
    }

    this->internal->handler->end(result.value());
  } else if (this->content_encoding == ServerContentEncoding::Identity) {
    this->internal->handler->end(message);
  }
}

auto ServerResponse::head(const std::string_view message) -> void {
  std::ostringstream code_string;
  code_string << this->code;
  this->internal->handler->writeStatus(code_string.str());

  for (const auto &[key, value] : this->headers) {
    this->internal->handler->writeHeader(key, value);
  }

  if (this->content_encoding == ServerContentEncoding::GZIP) {
    auto result{sourcemeta::core::gzip(message)};
    if (!result.has_value()) {
      throw std::runtime_error("Compression failed");
    }

    this->internal->handler->endWithoutBody(result.value().size());
    this->internal->handler->end();
  } else if (this->content_encoding == ServerContentEncoding::Identity) {
    this->internal->handler->endWithoutBody(message.size());
    this->internal->handler->end();
  }
}

auto ServerResponse::end(const sourcemeta::core::JSON &document) -> void {
  std::ostringstream output;
  sourcemeta::core::prettify(document, output);
  this->end(output.str());
}

auto ServerResponse::head(const sourcemeta::core::JSON &document) -> void {
  std::ostringstream output;
  sourcemeta::core::prettify(document, output);
  this->head(output.str());
}

auto ServerResponse::end(const sourcemeta::core::JSON &document,
                         const sourcemeta::core::JSON::KeyComparison &compare)
    -> void {
  std::ostringstream output;
  sourcemeta::core::prettify(document, output, compare);
  this->end(output.str());
}

auto ServerResponse::head(const sourcemeta::core::JSON &document,
                          const sourcemeta::core::JSON::KeyComparison &compare)
    -> void {
  std::ostringstream output;
  sourcemeta::core::prettify(document, output, compare);
  this->head(output.str());
}

auto ServerResponse::end() -> void {
  std::ostringstream code_string;
  code_string << this->code;
  this->internal->handler->writeStatus(code_string.str());

  for (const auto &[key, value] : this->headers) {
    this->internal->handler->writeHeader(key, value);
  }

  this->internal->handler->end();
}

} // namespace sourcemeta::hydra::http
