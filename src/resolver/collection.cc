#include <sourcemeta/registry/resolver_collection.h>

namespace {
// TODO: We should be able to use `sourcemeta::core::from_json` here
auto parse_rebase(const sourcemeta::core::JSON &entry)
    -> std::vector<std::pair<sourcemeta::core::URI, sourcemeta::core::URI>> {
  std::vector<std::pair<sourcemeta::core::URI, sourcemeta::core::URI>> result;
  if (entry.defines("rebase")) {
    for (const auto &pair : entry.at("rebase").as_array()) {
      result.emplace_back(
          sourcemeta::core::URI{pair.at("from").to_string()}.canonicalize(),
          sourcemeta::core::URI{pair.at("to").to_string()}.canonicalize());
    }
  }

  return result;
}
} // namespace

namespace sourcemeta::registry {

ResolverCollection::ResolverCollection(
    const std::filesystem::path &base_path,
    sourcemeta::core::JSON::String entry_name,
    const sourcemeta::core::JSON &entry)
    : path{std::filesystem::canonical(base_path /
                                      entry.at("path").to_string())},
      name{std::move(entry_name)},
      base_uri{
          sourcemeta::core::URI{entry.at("base").to_string()}.canonicalize()},
      default_dialect{
          entry.defines("defaultDialect")
              ? entry.at("defaultDialect").to_string()
              : static_cast<std::optional<sourcemeta::core::JSON::String>>(
                    std::nullopt)},
      rebase{parse_rebase(entry)} {}

auto ResolverCollection::default_identifier(
    const std::filesystem::path &schema_path) const -> std::string {
  return sourcemeta::core::URI{this->base_uri}
      .append_path(std::filesystem::relative(schema_path, this->path).string())
      .canonicalize()
      .recompose();
}

} // namespace sourcemeta::registry
