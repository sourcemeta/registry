#include <sourcemeta/registry/resolver.h>
#include <sourcemeta/registry/shared.h>

#include <sourcemeta/core/jsonschema.h>
#include <sourcemeta/core/uri.h>
#include <sourcemeta/core/yaml.h>

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
    auto suffix{maybe_relative.path().value_or("")};
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

static auto
normalise_ref(const sourcemeta::registry::Configuration::Collection &collection,
              const sourcemeta::core::URI &base, sourcemeta::core::JSON &schema,
              const sourcemeta::core::JSON::String &keyword,
              const sourcemeta::core::JSON::String &reference) -> void {
  // We never want to mess with internal references.
  // We assume those are always well formed
  if (reference.starts_with('#')) {
    return;
  }

  // If we have a match in the configuration resolver, then trust that
  const auto match{collection.resolve.find(reference)};
  if (match != collection.resolve.cend()) {
    schema.assign(keyword, sourcemeta::core::JSON{match->second});
    return;
  }

  sourcemeta::core::URI value{reference};
  if (value.is_relative()) {
    schema.assign(keyword, sourcemeta::core::JSON{value.recompose()});
  } else {
    // Lowercase only the path component of the reference, as
    // otherwise `.relative_to` will get confused. Note that
    // are careful about not lowercasing the entire thing,
    // as the reference may include a JSON Pointer in the fragment
    const auto current_path{value.path()};
    if (current_path.has_value()) {
      value.path(to_lowercase(current_path.value()));
    }

    // Turn the reference into a relative one if possible. That way, even
    // if we change the identifiers, its all well
    value.relative_to(base);
    schema.assign(keyword, sourcemeta::core::JSON{value.recompose()});
  }
}

namespace sourcemeta::registry {

auto Resolver::operator()(
    std::string_view raw_identifier,
    const std::function<void(const std::filesystem::path &)> &callback) const
    -> std::optional<sourcemeta::core::JSON> {
  /////////////////////////////////////////////////////////////////////////////
  // (1) Lookup the schema
  /////////////////////////////////////////////////////////////////////////////

  // Internally, we keep all schema URI identifiers as lowercase to avoid
  // tricky cases with case-insensitive operating systems
  const auto identifier{to_lowercase(raw_identifier)};
  auto result{this->views.find(identifier)};
  // Try with a `.json` extension as a fallback, as we do add this
  // extension when a schema doesn't have it by default
  if (result == this->views.cend() && !identifier.ends_with(".json")) {
    result = this->views.find(identifier + ".json");
  }
  // If we don't recognise the schema, try a fallback as a last resort
  if (result == this->views.cend()) {
    return sourcemeta::core::schema_official_resolver(identifier);
  }

  /////////////////////////////////////////////////////////////////////////////
  // (2) Avoid rebasing on the fly if possible
  /////////////////////////////////////////////////////////////////////////////

  if (result->second.cache_path.has_value()) {
    // We can guarantee the cached outcome is JSON, so we don't need to try
    // reading as YAML
    auto schema{
        sourcemeta::registry::read_json(result->second.cache_path.value())};
    assert(sourcemeta::core::is_schema(schema));
    if (callback) {
      callback(result->second.cache_path.value());
    }

    return schema;
  }

  /////////////////////////////////////////////////////////////////////////////
  // (3) Read the original schema file
  /////////////////////////////////////////////////////////////////////////////

  auto schema{sourcemeta::core::read_yaml_or_json(result->second.path)};
  assert(sourcemeta::core::is_schema(schema));
  if (callback) {
    callback(result->second.path);
  }

  // If the schema is not an object schema, then we are done
  if (!schema.is_object()) {
    return schema;
  }

  /////////////////////////////////////////////////////////////////////////////
  // (4) Make sure the schema explicitly declares the intended dialect
  /////////////////////////////////////////////////////////////////////////////

  // Note that we have to do this before attempting to analyse the schema, so
  // we can internally resolve any potential custom meta-schema
  schema.assign("$schema", sourcemeta::core::JSON{result->second.dialect});

  /////////////////////////////////////////////////////////////////////////////
  // (5) Normalise all references, if any, to match the new identifier
  /////////////////////////////////////////////////////////////////////////////

  sourcemeta::core::SchemaFrame frame{
      sourcemeta::core::SchemaFrame::Mode::Locations};
  frame.analyse(
      schema, sourcemeta::core::schema_official_walker,
      [this](const auto subidentifier) {
        return this->operator()(subidentifier);
      },
      result->second.dialect, result->second.original_identifier);
  const auto ref_hash{schema.as_object().hash("$ref")};
  const auto dynamic_ref_hash{schema.as_object().hash("$dynamicRef")};
  for (const auto &entry : frame.locations()) {
    if (entry.second.type ==
            sourcemeta::core::SchemaFrame::LocationType::Resource ||
        entry.second.type ==
            sourcemeta::core::SchemaFrame::LocationType::Subschema) {
      auto &subschema{sourcemeta::core::get(schema, entry.second.pointer)};
      if (subschema.is_object()) {
        const auto maybe_ref{subschema.try_at("$ref", ref_hash)};
        if (maybe_ref) {
          // This is safe, as at this point we have validated all schemas
          // against their meta-schemas
          assert(maybe_ref->is_string());
          normalise_ref(result->second.collection.get(), entry.second.base,
                        subschema, "$ref", maybe_ref->to_string());
        }

        if (entry.second.base_dialect ==
            "https://json-schema.org/draft/2020-12/schema") {
          const auto maybe_dynamic_ref{
              subschema.try_at("$dynamicRef", dynamic_ref_hash)};
          if (maybe_dynamic_ref) {
            // This is safe, as at this point we have validated all schemas
            // against their meta-schemas
            assert(maybe_dynamic_ref->is_string());
            normalise_ref(result->second.collection.get(), entry.second.base,
                          subschema, "$dynamicRef",
                          maybe_dynamic_ref->to_string());
          }
        }
      }
    }
  }

  /////////////////////////////////////////////////////////////////////////////
  // (6) Assign the new final identifier to the schema
  /////////////////////////////////////////////////////////////////////////////

  sourcemeta::core::reidentify(
      schema, result->first,
      [this](const auto subidentifier) {
        return this->operator()(subidentifier);
      },
      result->second.dialect);

  return schema;
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
  // Don't modify references to official meta-schemas
  // TODO: This line may be unnecessarily slow. We should have a different
  // function that just checks for string equality in an `std::unordered_map`
  // of official dialects without constructing the final object
  const auto is_official_dialect{
      sourcemeta::core::schema_official_resolver(raw_dialect.value())
          .has_value()};
  auto current_dialect{is_official_dialect
                           ? raw_dialect.value()
                           : rebase(collection,
                                    to_lowercase(raw_dialect.value()),
                                    server_url, collection_relative_path)};
  // Otherwise we messed things up
  assert(!current_dialect.ends_with("#.json"));

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
