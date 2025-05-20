#include "resolver.h"

#include <sourcemeta/core/yaml.h>

#include <cassert> // assert
#include <cctype>  // std::tolower
#include <sstream> // std::ostringstream

RegistryResolverOutsideBaseError::RegistryResolverOutsideBaseError(
    std::string uri, std::string base)
    : uri_{std::move(uri)}, base_{std::move(base)} {}

auto RegistryResolverOutsideBaseError::what() const noexcept -> const char * {
  return "The schema identifier is not relative to the corresponding base";
}

auto RegistryResolverOutsideBaseError::uri() const noexcept
    -> const std::string & {
  return this->uri_;
}

auto RegistryResolverOutsideBaseError::base() const noexcept
    -> const std::string & {
  return this->base_;
}

auto RegistryResolver::operator()(std::string_view identifier) const
    -> std::optional<sourcemeta::core::JSON> {
  const auto result{this->fallback_(identifier)};
  // Try with a `.json` extension as a fallback, as we do add this
  // extension when a schema doesn't have it by default
  if (!result.has_value() && !identifier.starts_with(".json")) {
    return this->fallback_(std::string{identifier} + ".json");
  }

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

auto RegistryResolver::add(const RegistryConfiguration &configuration,
                           const RegistryCollection &collection,
                           const std::filesystem::path &path)
    -> std::pair<std::string, std::string> {
  const auto default_identifier{collection.default_identifier(path)};

  const auto &current_identifier{this->fallback_.add(
      path, collection.default_dialect, default_identifier,
      internal_schema_reader,
      // TODO: We should avoid this vector / string copy
      [rebases = collection.rebase](
          sourcemeta::core::JSON &schema, const sourcemeta::core::URI &base,
          const sourcemeta::core::JSON::String &vocabulary,
          const sourcemeta::core::JSON::String &keyword,
          sourcemeta::core::URI &value) {
        sourcemeta::core::reference_visitor_relativize(schema, base, vocabulary,
                                                       keyword, value);

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
      })};
  auto identifier_uri{sourcemeta::core::URI{
      current_identifier == collection.base_uri.recompose()
          ? default_identifier
          : current_identifier}
                          .canonicalize()};
  auto current{identifier_uri.recompose()};
  identifier_uri.relative_to(collection.base_uri);
  if (identifier_uri.is_absolute()) {
    throw RegistryResolverOutsideBaseError(current,
                                           collection.base_uri.recompose());
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
  this->fallback_.reidentify(current_identifier, new_identifier);
  this->count_ += 1;
  return {std::move(current), std::move(new_identifier)};
}
