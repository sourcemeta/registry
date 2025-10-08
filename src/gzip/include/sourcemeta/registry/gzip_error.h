#ifndef SOURCEMETA_REGISTRY_GZIP_ERROR_H_
#define SOURCEMETA_REGISTRY_GZIP_ERROR_H_

#include <exception> // std::exception
#include <string>    // std::string
#include <utility>   // std::move

namespace sourcemeta::registry {

class GZIPError : public std::exception {
public:
  GZIPError(std::string message) : message_{std::move(message)} {}
  [[nodiscard]] auto what() const noexcept -> const char * override {
    return this->message_.c_str();
  }

private:
  std::string message_;
};

} // namespace sourcemeta::registry

#endif
