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
  ConfigurationValidationError(std::filesystem::path configuration_path,
                               sourcemeta::core::Pointer pointer,
                               std::string description)
      : path_{std::move(configuration_path)}, pointer_{std::move(pointer)},
        description_{std::move(description)} {}

  [[nodiscard]] auto what() const noexcept -> const char * override {
    return "Invalid configuration";
  }

  [[nodiscard]] auto path() const noexcept -> const auto & {
    return this->path_;
  }
  [[nodiscard]] auto pointer() const noexcept -> const auto & {
    return this->pointer_;
  }
  [[nodiscard]] auto description() const noexcept -> const auto & {
    return this->description_;
  }

private:
  const std::filesystem::path path_;
  const sourcemeta::core::Pointer pointer_;
  const std::string description_;
};

} // namespace sourcemeta::registry

#endif
