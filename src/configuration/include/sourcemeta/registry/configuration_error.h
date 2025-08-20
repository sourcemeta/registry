#ifndef SOURCEMETA_REGISTRY_CONFIGURATION_ERROR_H_
#define SOURCEMETA_REGISTRY_CONFIGURATION_ERROR_H_

#include <sourcemeta/blaze/compiler.h>

#include <exception> // std::exception
#include <sstream>   // std::ostringstream
#include <string>    // std::string

namespace sourcemeta::registry {

class ConfigurationValidationError : public std::exception {
public:
  ConfigurationValidationError(const sourcemeta::blaze::SimpleOutput &output) {
    std::ostringstream stream;
    output.stacktrace(stream);
    this->stacktrace_ = stream.str();
  }

  [[nodiscard]] auto what() const noexcept -> const char * {
    return "Invalid configuration";
  }

  [[nodiscard]] auto stacktrace() const noexcept -> const auto & {
    return stacktrace_;
  }

private:
  std::string stacktrace_;
};

} // namespace sourcemeta::registry

#endif
