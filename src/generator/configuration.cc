#include <sourcemeta/registry/generator_configuration.h>

#include <utility> // std::move

namespace sourcemeta::registry {

Configuration::Configuration(std::filesystem::path path,
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

auto Configuration::path() const noexcept -> const std::filesystem::path & {
  return this->path_;
}

auto Configuration::base() const noexcept -> const std::filesystem::path & {
  return this->base_;
}

auto Configuration::path(const std::filesystem::path &other) const
    -> std::filesystem::path {
  return std::filesystem::canonical(this->base() / other);
}

auto Configuration::get() const noexcept -> const sourcemeta::core::JSON & {
  return this->data_;
}

auto Configuration::schema() const noexcept -> const sourcemeta::core::JSON & {
  return this->schema_;
}

auto Configuration::url() const -> const sourcemeta::core::URI & {
  static const sourcemeta::core::URI server_uri{
      sourcemeta::core::URI{this->data_.at("url").to_string()}.canonicalize()};
  return server_uri;
}

// For faster processing by the server component
auto Configuration::summary() const -> sourcemeta::core::JSON {
  auto copy = this->data_;
  copy.erase_keys({"schemas", "pages"});
  return copy;
}

} // namespace sourcemeta::registry
