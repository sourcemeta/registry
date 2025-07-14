#include <sourcemeta/registry/resolver_error.h>

namespace sourcemeta::registry {

ResolverOutsideBaseError::ResolverOutsideBaseError(std::string uri,
                                                   std::string base)
    : uri_{std::move(uri)}, base_{std::move(base)} {}

auto ResolverOutsideBaseError::what() const noexcept -> const char * {
  return "The schema identifier is not relative to the corresponding base";
}

auto ResolverOutsideBaseError::uri() const noexcept -> const std::string & {
  return this->uri_;
}

auto ResolverOutsideBaseError::base() const noexcept -> const std::string & {
  return this->base_;
}

} // namespace sourcemeta::registry
