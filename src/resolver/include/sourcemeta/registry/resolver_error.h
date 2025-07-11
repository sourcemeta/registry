#ifndef SOURCEMETA_REGISTRY_RESOLVER_ERROR_H_
#define SOURCEMETA_REGISTRY_RESOLVER_ERROR_H_

#include <exception> // std::exception
#include <string>    // std::string

namespace sourcemeta::registry {

class ResolverOutsideBaseError : public std::exception {
public:
  ResolverOutsideBaseError(std::string uri, std::string base);
  [[nodiscard]] auto what() const noexcept -> const char * override;
  [[nodiscard]] auto uri() const noexcept -> const std::string &;
  [[nodiscard]] auto base() const noexcept -> const std::string &;

private:
  const std::string uri_;
  const std::string base_;
};

} // namespace sourcemeta::registry

#endif
