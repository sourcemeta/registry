#include <sourcemeta/registry/generator_resolver.h>

#include <sourcemeta/core/yaml.h>

#include <algorithm> // std::transform
#include <cassert>   // assert
#include <cctype>    // std::tolower
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

template <typename T>
static auto write_lower_except_trailing(T &stream, const std::string &input,
                                        const char trailing) -> void {
  for (auto iterator = input.cbegin(); iterator != input.cend(); ++iterator) {
    if (std::next(iterator) != input.cend() || *iterator != trailing) {
      stream << static_cast<char>(std::tolower(*iterator));
    }
  }
}

static auto url_join(const std::string &first, const std::string &second,
                     const std::string &third, const std::string &extension)
    -> std::string {
  std::ostringstream result;
  write_lower_except_trailing(result, first, '/');
  result << '/';
  write_lower_except_trailing(result, second, '/');
  result << '/';
  write_lower_except_trailing(result, third, '.');
  if (!result.str().ends_with(extension)) {
    std::filesystem::path current{result.str()};
    if (is_yaml(current)) {
      current.replace_extension(std::string{"."} + extension);
      return current.string();
    }

    result << '.';
    result << extension;
  }

  return result.str();
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

  auto result{this->schemas.find(string_identifier)};
  if (result == this->schemas.cend() && !identifier.ends_with(".json")) {
    // Try with a `.json` extension as a fallback, as we do add this
    // extension when a schema doesn't have it by default
    result = this->schemas.find(string_identifier + ".json");
  }

  if (result != this->schemas.cend()) {
    auto schema{internal_schema_reader(result->second.path)};
    assert(sourcemeta::core::is_schema(schema));
    if (schema.is_object() && result->second.dialect.has_value()) {
      schema.assign("$schema",
                    sourcemeta::core::JSON{result->second.dialect.value()});
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

auto Resolver::add(const Configuration &configuration,
                   const Collection &collection,
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
      current_dialect =
          url_join(configuration.url().recompose(), collection.name,
                   dialect_uri.recompose(),
                   // We want to guarantee identifiers end with a JSON
                   // extension, as we want to use the non-extension URI to
                   // potentially metadata about schemas, etc
                   "json");
    }
  }

  const auto result{this->schemas.emplace(
      effective_identifier,
      Entry{
          canonical, current_dialect, effective_identifier,
          // TODO: We should avoid this vector / string copy
          [rebases = collection.rebase](
              sourcemeta::core::JSON &schema, const sourcemeta::core::URI &base,
              const sourcemeta::core::JSON::String &vocabulary,
              const sourcemeta::core::JSON::String &keyword,
              sourcemeta::core::URI &value) {
            sourcemeta::core::reference_visitor_relativize(
                schema, base, vocabulary, keyword, value);

            if (!value.is_absolute()) {
              return;
            }

            for (const auto &rebase : rebases) {
              // TODO: We need a method in URI to check if a URI
              // is a base of another one without mutating either
              auto value_copy = value;
              value_copy.relative_to(rebase.first);
              if (value_copy.is_relative()) {
                auto value_other = value;
                value_other.rebase(rebase.first, rebase.second);
                schema.assign(keyword,
                              sourcemeta::core::JSON{value_other.recompose()});
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
  // TODO: Make this part of the URI class as a concat method. For the
  // extension, we should have a method for setting an extension in the path
  // component
  auto new_identifier{
      url_join(configuration.url().recompose(), collection.name,
               identifier_uri.recompose(),
               // We want to guarantee identifiers end with a JSON
               // extension, as we want to use the non-extension URI to
               // potentially metadata about schemas, etc
               "json")};

  // Otherwise we have things like "../" that should not be there
  assert(new_identifier.find("..") == std::string::npos);
  if (to_lowercase(current_identifier) != to_lowercase(new_identifier)) {
    const auto match{this->schemas.find(to_lowercase(current_identifier))};
    assert(match != this->schemas.cend());

    const auto target{this->schemas.find(to_lowercase(new_identifier))};
    const auto ignore_error{target != this->schemas.cend() &&
                            target->second.path == match->second.path};
    const auto subresult{this->schemas.insert_or_assign(
        to_lowercase(new_identifier), std::move(match->second))};

    if (!subresult.second && !ignore_error) {
      std::ostringstream error;
      error << "Cannot register the same identifier twice: " << new_identifier;
      throw sourcemeta::core::SchemaError(error.str());
    }

    this->schemas.erase(match);
  }

  this->count_ += 1;
  return {std::move(current), std::move(new_identifier)};
}

} // namespace sourcemeta::registry
