#ifndef SOURCEMETA_REGISTRY_GENERATOR_CONFIGURATION_H_
#define SOURCEMETA_REGISTRY_GENERATOR_CONFIGURATION_H_

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/uri.h>

#include <filesystem> // std::filesystem
#include <utility>    // std::move

namespace sourcemeta::registry {

class Configuration {
public:
  Configuration(std::filesystem::path path,
                sourcemeta::core::JSON configuration_schema)
      : path_{std::move(path)}, base_{this->path_.parent_path()},
        data_{sourcemeta::core::read_json(this->path_)},
        schema_{std::move(configuration_schema)} {
    if (this->data_.is_object()) {
      this->data_.assign_if_missing(
          "title", this->schema_.at("properties").at("title").at("default"));
      this->data_.assign_if_missing(
          "description",
          this->schema_.at("properties").at("description").at("default"));
    }
  }

  // Just to prevent mistakes
  Configuration(const Configuration &) = delete;
  Configuration &operator=(const Configuration &) = delete;
  Configuration(Configuration &&) = delete;
  Configuration &operator=(Configuration &&) = delete;

  auto path() const noexcept -> const std::filesystem::path & {
    return this->path_;
  }

  auto base() const noexcept -> const std::filesystem::path & {
    return this->base_;
  }

  auto path(const std::filesystem::path &other) const -> std::filesystem::path {
    return std::filesystem::canonical(this->base() / other);
  }

  auto get() const noexcept -> const sourcemeta::core::JSON & {
    return this->data_;
  }

  auto schema() const noexcept -> const sourcemeta::core::JSON & {
    return this->schema_;
  }

  auto url() const -> const sourcemeta::core::URI & {
    static const sourcemeta::core::URI server_uri{
        sourcemeta::core::URI{this->data_.at("url").to_string()}
            .canonicalize()};
    return server_uri;
  }

  // For faster processing by the server component
  // TODO: Can we trim this down even more?
  auto summary() const -> sourcemeta::core::JSON {
    auto copy = this->data_;
    copy.erase_keys({"schemas", "pages"});
    return copy;
  }

  auto page(const sourcemeta::core::JSON::String &name) const
      -> const sourcemeta::core::JSON::Object & {
    if (this->data_.defines("pages") && this->data_.at("pages").defines(name) &&
        this->data_.at("pages").at(name).is_object()) {
      return this->data_.at("pages").at(name).as_object();
    } else {
      static const sourcemeta::core::JSON::Object placeholder;
      return placeholder;
    }
  }

private:
  const std::filesystem::path path_;
  const std::filesystem::path base_;
  sourcemeta::core::JSON data_;
  const sourcemeta::core::JSON schema_;
};

} // namespace sourcemeta::registry

#endif
