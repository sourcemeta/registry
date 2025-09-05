#include <sourcemeta/registry/resolver.h>
#include <sourcemeta/registry/shared.h>

#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>
#include <sourcemeta/core/yaml.h>

#include "visitor.h"

#include <algorithm> // std::transform
#include <cassert>   // assert
#include <cctype>    // std::tolower
#include <mutex>     // std::mutex, std::lock_guard
#include <sstream>   // std::ostringstream

static auto to_lowercase(const std::string_view input) -> std::string {
  std::string result{input};
  std::ranges::transform(result, result.begin(), [](const auto character) {
    return static_cast<char>(std::tolower(character));
  });
  return result;
}

static auto
rebase(const sourcemeta::registry::Configuration::Collection &collection,
       const sourcemeta::core::JSON::String &uri,
       const sourcemeta::core::JSON::String &new_base,
       const sourcemeta::core::JSON::String &new_prefix)
    -> sourcemeta::core::JSON::String {
  sourcemeta::core::URI maybe_relative{uri};
  maybe_relative.relative_to(collection.base);
  if (maybe_relative.is_relative()) {
    auto suffix{maybe_relative.recompose()};
    assert(!suffix.empty());
    return sourcemeta::core::URI{new_base}
        .append_path(new_prefix)
        // TODO: Let `append_path` take a URI
        // TODO: Also implement a move overload
        .append_path(suffix)
        .canonicalize()
        .extension(".json")
        .recompose();
  } else {
    return maybe_relative.recompose();
  }
}

namespace sourcemeta::registry {

auto Resolver::operator()(
    std::string_view identifier,
    const std::function<void(const std::filesystem::path &)> &callback) const
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
      if (callback) {
        callback(result->second.cache_path.value());
      }

      return sourcemeta::registry::read_json(result->second.cache_path.value());
    }

    if (callback) {
      callback(result->second.path);
    }

    auto schema{sourcemeta::core::read_yaml_or_json(result->second.path)};
    assert(sourcemeta::core::is_schema(schema));
    if (schema.is_object()) {
      // Don't modify references to official meta-schemas
      const auto current{sourcemeta::core::dialect(schema)};
      if (!current.has_value() ||
          !sourcemeta::core::schema_official_resolver(current.value())
               .has_value()) {
        schema.assign("$schema",
                      sourcemeta::core::JSON{result->second.dialect});
      }
    }

    // TODO: This is only to workaround this existing framing bug:
    // See: https://github.com/sourcemeta/core/pull/1979
    auto current_identifier{sourcemeta::core::identify(
        schema,
        [this](const auto subidentifier) {
          return this->operator()(subidentifier);
        },
        sourcemeta::core::SchemaIdentificationStrategy::Strict,
        result->second.dialect)};
    if (current_identifier.has_value()) {
      if (sourcemeta::core::URI{current_identifier.value()}.is_relative()) {
        sourcemeta::core::anonymize(schema, result->second.dialect);
      }
    }

    reference_visit(
        schema, sourcemeta::core::schema_official_walker,
        [this](const auto subidentifier) {
          return this->operator()(subidentifier);
        },
        [&result](sourcemeta::core::JSON &subschema,
                  const sourcemeta::core::URI &base,
                  const sourcemeta::core::JSON::String &vocabulary,
                  const sourcemeta::core::JSON::String &keyword,
                  sourcemeta::core::URI &value) {
          const auto match{result->second.collection.get().resolve.find(
              subschema.at(keyword).to_string())};
          if (match != result->second.collection.get().resolve.cend()) {
            subschema.assign(keyword, sourcemeta::core::JSON{match->second});
            return;
          }

          const auto current_path{value.path()};
          if (current_path.has_value()) {
            value.path(to_lowercase(current_path.value()));
            subschema.assign(keyword,
                             sourcemeta::core::JSON{value.recompose()});
          }

          reference_visitor_relativize(subschema, base, vocabulary, keyword,
                                       value);
        },
        result->second.dialect, result->second.original_identifier);

    sourcemeta::core::reidentify(
        schema, result->first,
        [this](const auto subidentifier) {
          return this->operator()(subidentifier);
        },
        result->second.dialect);

    return schema;
  }

  return sourcemeta::core::schema_official_resolver(identifier);
}

auto Resolver::add(const sourcemeta::core::JSON::String &server_url,
                   const std::filesystem::path &collection_relative_path,
                   const Configuration::Collection &collection,
                   const std::filesystem::path &path)
    -> std::pair<std::reference_wrapper<const sourcemeta::core::JSON::String>,
                 std::reference_wrapper<const sourcemeta::core::JSON::String>> {
  /////////////////////////////////////////////////////////////////////////////
  // (1) Read the schema file
  /////////////////////////////////////////////////////////////////////////////
  assert(path.is_absolute());
  const auto schema{sourcemeta::core::read_yaml_or_json(path)};
  assert(sourcemeta::core::is_schema(schema));

  /////////////////////////////////////////////////////////////////////////////
  // (2) Try our best to determine the identifier of the schema, defaulting to a
  // file-system-based identifier based on the *current* URI
  /////////////////////////////////////////////////////////////////////////////
  const auto default_identifier{
      sourcemeta::core::URI{collection.base}
          .append_path(std::filesystem::relative(path, collection.absolute_path)
                           .string())
          .canonicalize()
          .recompose()};
  sourcemeta::core::URI identifier_uri{to_lowercase(
      sourcemeta::core::identify(
          schema,
          [this](const auto subidentifier) {
            return this->operator()(subidentifier);
          },
          sourcemeta::core::SchemaIdentificationStrategy::Loose,
          collection.default_dialect, default_identifier)
          // We can safely assume this as we pass a default identifier
          .value())};
  identifier_uri.canonicalize();
  auto identifier{
      identifier_uri.is_relative()
          // TODO: Becase with `try_resolve_from`, `https://example.com/foo` +
          // `bar.json` will be `https://example.com/bar.json` instead of
          // `https://example.com/foo/bar.json`. Maybe we need an `append_from`?
          ? (collection.base + "/" + identifier_uri.recompose())
          : identifier_uri.recompose()};
  // We have to do something if the schema is the base. Note that URI
  // canonicalisation technically cannot remove trailing slashes as they might
  // have meaning in certain use cases. But we still consider them equal in the
  // context of the Registry
  if (identifier == collection.base || identifier == collection.base + "/") {
    identifier = default_identifier;
  }
  // A final check that everything went well
  if (!identifier.starts_with(collection.base)) {
    throw ResolverOutsideBaseError(identifier, collection.base);
  }
  // Otherwise we have things like "../" that should not be there
  assert(identifier.find("..") == std::string::npos);

  /////////////////////////////////////////////////////////////////////////////
  // (3) Determine the new URI of the schema, from the registry base URI
  /////////////////////////////////////////////////////////////////////////////
  const auto new_identifier{
      rebase(collection, identifier, server_url, collection_relative_path)};
  // Otherwise we have things like "../" that should not be there
  assert(new_identifier.find("..") == std::string::npos);

  /////////////////////////////////////////////////////////////////////////////
  // (4) Determine the dialect of the schema, which we also need to make sure
  // we rebase according to the registry base URI, etc
  /////////////////////////////////////////////////////////////////////////////
  const auto raw_dialect{
      sourcemeta::core::dialect(schema, collection.default_dialect)};
  // If we couldn't determine the dialect, we would be in trouble!
  assert(raw_dialect.has_value());
  auto current_dialect{rebase(collection, to_lowercase(raw_dialect.value()),
                              server_url, collection_relative_path)};

  /////////////////////////////////////////////////////////////////////////////
  // (5) Safely registry the schema entry in the resolver
  /////////////////////////////////////////////////////////////////////////////
  std::unique_lock lock{this->mutex};
  auto result{this->views.emplace(
      new_identifier,
      Entry{.cache_path = std::nullopt,
            .path = path,
            .dialect = std::move(current_dialect),
            .relative_path = sourcemeta::core::URI{new_identifier}
                                 .relative_to(server_url)
                                 .recompose(),
            .original_identifier = identifier,
            .collection = collection})};
  lock.unlock();
  if (!result.second && result.first->second.path != path) {
    std::ostringstream error;
    error << "Cannot register the same identifier twice: "
          << result.first->first;
    throw sourcemeta::core::SchemaError(error.str());
  }

  return {result.first->second.original_identifier, result.first->first};
}

auto Resolver::cache_path(const sourcemeta::core::JSON::String &uri,
                          const std::filesystem::path &path) -> void {
  assert(std::filesystem::exists(path));
  // As we are modifying the actual map
  std::unique_lock lock{this->mutex};
  auto entry{this->views.find(uri)};
  assert(entry != this->views.cend());
  assert(!entry->second.cache_path.has_value());
  entry->second.cache_path = path;
}

} // namespace sourcemeta::registry
