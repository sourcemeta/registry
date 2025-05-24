#ifndef SOURCEMETA_REGISTRY_GENERATOR_RESOLVER_H_
#define SOURCEMETA_REGISTRY_GENERATOR_RESOLVER_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>

#include <sourcemeta/registry/generator_collection.h>
#include <sourcemeta/registry/generator_configuration.h>

#include <exception>   // std::exception
#include <filesystem>  // std::filesystem
#include <map>         // std::map
#include <optional>    // std::optional
#include <string_view> // std::string_view
#include <utility>     // std::pair

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

class Resolver {
public:
  auto operator()(std::string_view identifier) const
      -> std::optional<sourcemeta::core::JSON>;

  // TODO: To optimise this class, we can have an additional method to
  // "materialise" a schema. That means we write it back to an output location
  // and record that output location in a new map, which is resolved without
  // runtime transformation.
  // Then, the callable operator can always prefer the materialised map
  auto add(const Configuration &configuration, const Collection &collection,
           const std::filesystem::path &path)
      -> std::pair<std::string, std::string>;

  auto begin() const -> auto { return this->schemas.begin(); }
  auto end() const -> auto { return this->schemas.end(); }
  auto size() const -> auto { return this->count_; }

  struct Entry {
    std::filesystem::path path;
    std::optional<std::string> dialect;
    std::string original_identifier;
    sourcemeta::core::SchemaVisitorReference reference_visitor;
  };

private:
  std::map<std::string, Entry> schemas;
  std::size_t count_{0};
};

} // namespace sourcemeta::registry

#endif
