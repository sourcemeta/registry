#ifndef SOURCEMETA_REGISTRY_RESOLVER_ERROR_H_
#define SOURCEMETA_REGISTRY_RESOLVER_ERROR_H_

#include <sourcemeta/core/json.h>

#include <exception> // std::exception
#include <utility>   // std::move

namespace sourcemeta::registry {

class ResolverOutsideBaseError : public std::exception {
public:
  ResolverOutsideBaseError(sourcemeta::core::JSON::String uri,
                           sourcemeta::core::JSON::String base)
      : uri_{std::move(uri)}, base_{std::move(base)} {}

  [[nodiscard]] auto what() const noexcept -> const char * override {
    return "The schema identifier is not relative to the corresponding base";
  }

  [[nodiscard]] auto uri() const noexcept
      -> const sourcemeta::core::JSON::String & {
    return this->uri_;
  }

  [[nodiscard]] auto base() const noexcept
      -> const sourcemeta::core::JSON::String & {
    return this->base_;
  }

private:
  const sourcemeta::core::JSON::String uri_;
  const sourcemeta::core::JSON::String base_;
};

} // namespace sourcemeta::registry

#endif
