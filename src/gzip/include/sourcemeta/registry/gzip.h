#ifndef SOURCEMETA_REGISTRY_GZIP_H_
#define SOURCEMETA_REGISTRY_GZIP_H_

#include <sourcemeta/registry/gzip_error.h>

#include <istream>     // std::istream
#include <ostream>     // std::ostream
#include <string>      // std::string
#include <string_view> // std::string_view

namespace sourcemeta::registry {

auto gzip(std::istream &input, std::ostream &output) -> void;

auto gzip(std::istream &stream) -> std::string;

auto gzip(const std::string &input) -> std::string;

auto gunzip(std::istream &input, std::ostream &output) -> void;

auto gunzip(std::istream &stream) -> std::string;

auto gunzip(const std::string &input) -> std::string;

} // namespace sourcemeta::registry

#endif
