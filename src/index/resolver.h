#ifndef SOURCEMETA_REGISTRY_INDEX_RESOLVER_H_
#define SOURCEMETA_REGISTRY_INDEX_RESOLVER_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>

#include "collection.h"
#include "configuration.h"

#include <exception>   // std::exception
#include <filesystem>  // std::filesystem
#include <optional>    // std::optional
#include <string_view> // std::string_view
#include <utility>     // std::pair

class RegistryResolverOutsideBaseError : public std::exception {
public:
  RegistryResolverOutsideBaseError(std::string uri, std::string base);
  [[nodiscard]] auto what() const noexcept -> const char * override;
  [[nodiscard]] auto uri() const noexcept -> const std::string &;
  [[nodiscard]] auto base() const noexcept -> const std::string &;

private:
  const std::string uri_;
  const std::string base_;
};

class RegistryResolver {
public:
  auto operator()(std::string_view identifier) const
      -> std::optional<sourcemeta::core::JSON>;

  auto add(const RegistryConfiguration &configuration,
           const RegistryCollection &collection,
           const std::filesystem::path &path)
      -> std::pair<std::string, std::string>;

  auto begin() const -> auto { return this->fallback_.begin(); }
  auto end() const -> auto { return this->fallback_.end(); }
  auto size() const -> auto { return this->count_; }

private:
  // TODO: Remove this class from Core and inline it in this class
  sourcemeta::core::SchemaFlatFileResolver fallback_{
      sourcemeta::core::schema_official_resolver};
  std::size_t count_{0};
};

#endif
