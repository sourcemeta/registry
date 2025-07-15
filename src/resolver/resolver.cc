#include <sourcemeta/registry/resolver.h>

#include <sourcemeta/core/yaml.h>

#include <algorithm> // std::transform
#include <cassert>   // assert
#include <cctype>    // std::tolower
#include <regex>     // std::regex, std::smatch, std::regex_search
#include <sstream>   // std::ostringstream

static auto to_lowercase(const std::string_view input) -> std::string {
  std::string result{input};
  std::transform(result.cbegin(), result.cend(), result.begin(),
                 [](const auto character) {
                   return static_cast<char>(std::tolower(character));
                 });
  return result;
}

// TODO: Move this up as a utility function of Core's YAML package
static auto is_yaml(const std::filesystem::path &path) -> bool {
  return path.extension() == ".yaml" || path.extension() == ".yml";
}

static auto internal_schema_reader(const std::filesystem::path &path)
    -> sourcemeta::core::JSON {
  return is_yaml(path) ? sourcemeta::core::read_yaml(path)
                       : sourcemeta::core::read_json(path);
}

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

auto Resolver::operator()(std::string_view identifier) const
    -> std::optional<sourcemeta::core::JSON> {
  const std::string string_identifier{to_lowercase(identifier)};

  auto result{this->views.find(string_identifier)};
  if (result == this->views.cend() && !identifier.ends_with(".json")) {
    sourcemeta::core::URI uri_identifier{string_identifier};
    // Try with a `.json` extension as a fallback, as we do add this
    // extension when a schema doesn't have it by default
    uri_identifier.extension("json");
    result = this->views.find(uri_identifier.recompose());
  }

  if (result != this->views.cend()) {
    if (result->second.cache_path.has_value()) {
      return sourcemeta::core::read_json(result->second.cache_path.value());
    } else if (!result->second.path.has_value()) {
      return std::nullopt;
    }

    auto schema{internal_schema_reader(result->second.path.value())};
    assert(sourcemeta::core::is_schema(schema));
    if (schema.is_object() && result->second.dialect.has_value()) {
      // Don't modify references to official meta-schemas
      const auto current{sourcemeta::core::dialect(schema)};
      if (!current.has_value() ||
          !sourcemeta::core::schema_official_resolver(current.value())
               .has_value()) {
        schema.assign("$schema",
                      sourcemeta::core::JSON{result->second.dialect.value()});
      }
    }

    // TODO: Extract the idea of a reference visitor into this project
    // Because we allow re-identification, we can get into issues unless we
    // always try to relativize references
    sourcemeta::core::reference_visit(
        schema, sourcemeta::core::schema_official_walker, *this,
        result->second.reference_visitor, result->second.dialect,
        result->second.original_identifier);
    sourcemeta::core::reidentify(schema, result->first, *this,
                                 result->second.dialect);

    return schema;
  }

  return sourcemeta::core::schema_official_resolver(identifier);
}

auto Resolver::add(const sourcemeta::core::URI &server_url,
                   const ResolverCollection &collection,
                   const std::filesystem::path &path)
    -> std::pair<std::string, std::string> {
  const auto default_identifier{collection.default_identifier(path)};

  const auto canonical{std::filesystem::weakly_canonical(path)};
  const auto schema{internal_schema_reader(canonical)};
  assert(sourcemeta::core::is_schema(schema));
  const auto identifier{sourcemeta::core::identify(
      schema, *this, sourcemeta::core::SchemaIdentificationStrategy::Loose,
      collection.default_dialect, default_identifier)};

  // Filesystems behave differently with regards to casing. To unify
  // them, assume they are case-insensitive.
  const auto effective_identifier{
      to_lowercase(identifier.value_or(default_identifier))};

  std::optional<std::string> current_dialect{
      schema.is_object() && schema.defines("$schema") &&
              schema.at("$schema").is_string()
          ? schema.at("$schema").to_string()
          : collection.default_dialect};

  // TODO: We also need to try to apply "rebase" arrays to the meta-schema and
  // test that
  if (current_dialect.has_value()) {
    sourcemeta::core::URI dialect_uri{current_dialect.value()};
    dialect_uri.canonicalize();
    dialect_uri.relative_to(collection.base_uri);
    if (dialect_uri.is_relative()) {
      current_dialect = sourcemeta::core::URI{server_url}
                            .append_path(collection.name)
                            // TODO: Let `append_path` take a URI
                            .append_path(dialect_uri.recompose())
                            .canonicalize()
                            .extension(".json")
                            .recompose();
    }
  }

  auto result{this->views.emplace(
      effective_identifier,
      Entry{std::nullopt, canonical, current_dialect, "", effective_identifier,
            collection.name,
            // TODO: We should avoid this vector / string copy
            [rebases = collection.rebase](
                sourcemeta::core::JSON &subschema,
                const sourcemeta::core::URI &base,
                const sourcemeta::core::JSON::String &vocabulary,
                const sourcemeta::core::JSON::String &keyword,
                sourcemeta::core::URI &value) {
              const auto current_path{value.path()};
              if (current_path.has_value()) {
                value.path(to_lowercase(current_path.value()));
                subschema.assign(keyword,
                                 sourcemeta::core::JSON{value.recompose()});
              }

              sourcemeta::core::reference_visitor_relativize(
                  subschema, base, vocabulary, keyword, value);

              if (!value.is_absolute()) {
                return;
              }

              for (const auto &rebase : rebases) {
                auto value_other = value;
                value_other.rebase(rebase.first, rebase.second);
                if (value_other != value) {
                  subschema.assign(
                      keyword, sourcemeta::core::JSON{value_other.recompose()});
                  return;
                }
              }
            }})};

  if (!result.second && result.first->second.path != canonical) {
    std::ostringstream error;
    error << "Cannot register the same identifier twice: "
          << effective_identifier;
    throw sourcemeta::core::SchemaError(error.str());
  }

  const auto &current_identifier{result.first->first};

  auto identifier_uri{sourcemeta::core::URI{
      current_identifier == collection.base_uri.recompose()
          ? default_identifier
          : current_identifier}
                          .canonicalize()};
  auto current{identifier_uri.recompose()};
  identifier_uri.relative_to(collection.base_uri);
  if (identifier_uri.is_absolute()) {
    throw ResolverOutsideBaseError(current, collection.base_uri.recompose());
  }

  assert(!identifier_uri.recompose().empty());
  auto new_identifier = sourcemeta::core::URI{server_url}
                            .append_path(collection.name)
                            // TODO: Let `append_path` take a URI
                            .append_path(identifier_uri.recompose())
                            .canonicalize()
                            .extension(".json")
                            .recompose();

  sourcemeta::core::URI schema_uri{new_identifier};
  schema_uri.relative_to(server_url);
  result.first->second.relative_path = to_lowercase(schema_uri.recompose());

  // Otherwise we have things like "../" that should not be there
  assert(new_identifier.find("..") == std::string::npos);
  if (to_lowercase(current_identifier) != to_lowercase(new_identifier)) {
    const auto match{this->views.find(to_lowercase(current_identifier))};
    assert(match != this->views.cend());

    const auto target{this->views.find(to_lowercase(new_identifier))};
    const auto ignore_error{target != this->views.cend() &&
                            target->second.path == match->second.path};
    const auto subresult{this->views.insert_or_assign(
        to_lowercase(new_identifier), std::move(match->second))};

    if (!subresult.second && !ignore_error) {
      std::ostringstream error;
      error << "Cannot register the same identifier twice: " << new_identifier;
      throw sourcemeta::core::SchemaError(error.str());
    }

    this->views.erase(match);
  }

  this->count_ += 1;
  return {std::move(current), std::move(new_identifier)};
}

auto Resolver::materialise(const std::string &uri,
                           const std::filesystem::path &path) -> void {
  assert(std::filesystem::exists(path));
  auto entry{this->views.find(uri)};
  assert(entry != this->views.cend());
  assert(!entry->second.cache_path.has_value());
  entry->second.cache_path = path;
  entry->second.path = std::nullopt;
  entry->second.dialect = std::nullopt;
  entry->second.reference_visitor = nullptr;
}

} // namespace sourcemeta::registry
