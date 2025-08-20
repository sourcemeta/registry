#ifndef SOURCEMETA_REGISTRY_CONFIGURATION_ERROR_H_
#define SOURCEMETA_REGISTRY_CONFIGURATION_ERROR_H_

#include <sourcemeta/core/jsonpointer.h>

#include <exception>  // std::exception
#include <filesystem> // std::filesystem::path
#include <string>     // std::string
#include <utility>    // std::move

namespace sourcemeta::registry {

class ConfigurationValidationError : public std::exception {
public:
  ConfigurationValidationError(sourcemeta::core::Pointer pointer,
                               std::string description)
      : pointer_{std::move(pointer)}, description_{std::move(description)} {}

  [[nodiscard]] auto what() const noexcept -> const char * override {
    return "Invalid configuration";
  }

  [[nodiscard]] auto pointer() const noexcept -> const auto & {
    return this->pointer_;
  }

  [[nodiscard]] auto description() const noexcept -> const auto & {
    return this->description_;
  }

private:
  const sourcemeta::core::Pointer pointer_;
  const std::string description_;
};

} // namespace sourcemeta::registry

#endif
