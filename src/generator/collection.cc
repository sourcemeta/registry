#include <sourcemeta/registry/generator_collection.h>

#include <cassert> // assert
#include <sstream> // std::ostringstream

namespace sourcemeta::registry {

Collection::Collection(const std::filesystem::path &base_path,
                       const sourcemeta::core::JSON::String &entry_name,
                       const sourcemeta::core::JSON &entry)
    : path{std::filesystem::canonical(base_path /
                                      entry.at("path").to_string())},
      name{entry_name},
      base_uri{
          sourcemeta::core::URI{entry.at("base").to_string()}.canonicalize()},
      default_dialect{
          entry.defines("defaultDialect")
              ? entry.at("defaultDialect").to_string()
              : static_cast<std::optional<sourcemeta::core::JSON::String>>(
                    std::nullopt)} {
  if (entry.defines("rebase")) {
    for (const auto &pair : entry.at("rebase").as_array()) {
      this->rebase.emplace_back(
          sourcemeta::core::URI{pair.at("from").to_string()}.canonicalize(),
          sourcemeta::core::URI{pair.at("to").to_string()}.canonicalize());
    }
  }
}

auto Collection::default_identifier(
    const std::filesystem::path &schema_path) const -> std::string {
  // TODO: Extract this into a URI::append_path() method
  std::ostringstream result;
  const auto base{this->base_uri.recompose()};
  result << base;
  if (!base.ends_with('/')) {
    result << '/';
  }
  const auto relative_path{
      std::filesystem::relative(schema_path, this->path).string()};
  assert(!relative_path.starts_with('/'));
  result << relative_path;
  return result.str();
}

} // namespace sourcemeta::registry
