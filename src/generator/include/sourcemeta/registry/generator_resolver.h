#ifndef SOURCEMETA_REGISTRY_GENERATOR_RESOLVER_H_
#define SOURCEMETA_REGISTRY_GENERATOR_RESOLVER_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>

#include <sourcemeta/registry/generator_collection.h>
#include <sourcemeta/registry/generator_configuration.h>

#include <exception>     // std::exception
#include <filesystem>    // std::filesystem
#include <optional>      // std::optional
#include <string_view>   // std::string_view
#include <unordered_map> // std::unordered_map
#include <utility>       // std::pair

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

  auto add(const Configuration &configuration, const Collection &collection,
           const std::filesystem::path &path)
      -> std::pair<std::string, std::string>;

  auto materialise(const std::string &uri, const std::filesystem::path &path)
      -> void;

  auto begin() const -> auto { return this->views.begin(); }
  auto end() const -> auto { return this->views.end(); }
  auto size() const -> auto { return this->count_; }

  struct Entry {
    std::optional<std::filesystem::path> cache_path;
    std::optional<std::filesystem::path> path;
    std::optional<std::string> dialect;
    std::filesystem::path relative_path;
    // TODO: Do we really need this member?
    std::string original_identifier;
    sourcemeta::core::SchemaVisitorReference reference_visitor;
  };

private:
  std::unordered_map<std::string, Entry> views;
  std::size_t count_{0};
};

} // namespace sourcemeta::registry

#endif
