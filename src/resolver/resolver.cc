#include <sourcemeta/one/metapack.h>
#include <sourcemeta/one/resolver.h>
#include <sourcemeta/one/shared.h>

#include <sourcemeta/blaze/foundation.h>
#include <sourcemeta/core/error.h>
#include <sourcemeta/core/text.h>
#include <sourcemeta/core/uri.h>
#include <sourcemeta/core/yaml.h>

#include <algorithm>     // std::ranges::find_if
#include <cassert>       // assert
#include <mutex>         // std::mutex, std::lock_guard
#include <optional>      // std::optional, std::nullopt
#include <shared_mutex>  // std::shared_lock
#include <sstream>       // std::ostringstream
#include <string>        // std::string
#include <system_error>  // std::error_code
#include <unordered_set> // std::unordered_set

static auto
pre_resolve(const sourcemeta::one::Configuration::Collection &collection,
            const std::string_view uri, const sourcemeta::core::URI &server)
    -> std::optional<std::string> {
  const auto match{collection.resolve.find(std::string{uri})};
  if (match == collection.resolve.cend()) {
    return std::nullopt;
  }
  sourcemeta::core::URI target{match->second};
  if (target.is_relative()) {
    sourcemeta::core::URI merged{server};
    merged.append_path(std::move(target));
    return merged.recompose();
  }
  return target.recompose();
}

static auto rebase(const sourcemeta::one::Configuration::Collection &collection,
                   const sourcemeta::core::JSON::String &uri,
                   const sourcemeta::core::URI &new_base,
                   const sourcemeta::core::JSON::String &new_prefix)
    -> sourcemeta::core::JSON::String {
  // A collection owns a whole path prefix of its base URI, so what an absolute
  // identifier is measured against is containment on component boundaries, and
  // not the relative reference that resolution would take back to it
  const sourcemeta::core::URI current{uri};
  std::optional<std::string> suffix;
  if (current.is_relative()) {
    suffix = current.path().value_or("");
  } else if (current.scheme() == collection.base_uri.scheme() &&
             current.has_same_authority(collection.base_uri)) {
    suffix = sourcemeta::core::URI::strip_path_prefix(
        current.path().value_or(""), collection.base_uri.path().value_or(""));
  }

  if (!suffix.has_value()) {
    return current.recompose();
  }

  assert(!suffix.value().empty());
  return sourcemeta::core::URI{new_base}
      .append_path(new_prefix)
      .append_path(suffix.value())
      .canonicalize()
      .recompose();
}

// The identifier a schema declares, or the given default when it declares
// none. A schema whose dialect cannot be determined or resolved also takes the
// default, as what such a schema is worth is settled further along, where the
// file it came from is still at hand
static auto
declared_identifier(const sourcemeta::core::JSON &schema,
                    const sourcemeta::blaze::SchemaResolver &resolver,
                    const std::string_view default_dialect,
                    const std::string_view default_identifier)
    -> sourcemeta::core::JSON::String {
  try {
    const sourcemeta::blaze::SchemaFrame frame{
        sourcemeta::blaze::SchemaFrame::Mode::Root,
        schema,
        sourcemeta::blaze::schema_walker,
        resolver,
        default_dialect,
        default_identifier,
        sourcemeta::blaze::SchemaFrame::IdentifierMode::Fallback};
    return frame.root();
  } catch (const sourcemeta::blaze::SchemaUnknownBaseDialectError &) {
    return sourcemeta::core::JSON::String{default_identifier};
  } catch (const sourcemeta::blaze::SchemaResolutionError &) {
    return sourcemeta::core::JSON::String{default_identifier};
  }
}

static auto normalise_identifier(const std::string_view identifier)
    -> std::string {
  std::string lowercase{identifier};
  sourcemeta::core::to_lowercase(lowercase);

  while (true) {
    if (lowercase.ends_with("#")) {
      lowercase.resize(lowercase.size() - 1);
    } else if (lowercase.ends_with(".json") || lowercase.ends_with(".yaml")) {
      lowercase.resize(lowercase.size() - 5);
    } else if (lowercase.ends_with(".yml")) {
      lowercase.resize(lowercase.size() - 4);
    } else if (lowercase.ends_with(".schema")) {
      lowercase.resize(lowercase.size() - 7);
    } else {
      break;
    }
  }

  return lowercase;
}

static auto
normalise_ref(const sourcemeta::one::Configuration::Collection &collection,
              const sourcemeta::core::URI &base, sourcemeta::core::JSON &schema,
              const sourcemeta::core::JSON::String &keyword,
              const sourcemeta::core::JSON::String &reference,
              const sourcemeta::core::URI &server) -> void {
  // We never want to mess with internal references.
  // We assume those are always well formed
  if (reference.starts_with('#')) {
    return;
  }

  // If we have a match in the configuration resolver, then trust that.
  const auto match{collection.resolve.find(reference)};
  if (match != collection.resolve.cend()) {
    sourcemeta::core::URI target{match->second};
    if (target.is_relative()) {
      sourcemeta::core::URI merged{server};
      merged.append_path(std::move(target));
      target = std::move(merged);
    }
    const auto target_path{target.path()};
    if (target_path.has_value()) {
      target.path(normalise_identifier(target_path.value()));
    }
    // For targets in the instance URL's namespace, store the served value
    // as a relative reference so the schema body stays portable across
    // deployments. For foreign authorities, keep the full URI so reference
    // resolution sees it as-is (and fails honestly if unregistered).
    if (target.has_same_authority(server)) {
      schema.assign(keyword,
                    sourcemeta::core::JSON{target.recompose_relative()});
    } else {
      schema.assign(keyword, sourcemeta::core::JSON{target.recompose()});
    }
    return;
  }

  sourcemeta::core::URI value{reference};
  // Lowercase only the path component of the reference. Note that are careful
  // about not lowercasing the entire thing, as the reference may include a
  // JSON Pointer in the fragment
  const auto current_path{value.path()};
  if (current_path.has_value()) {
    value.path(normalise_identifier(current_path.value()));
  }

  if (value.is_absolute()) {
    // Turn the reference into a relative one if possible. That way, everything
    // is good even if we change the identifiers
    value.relative_to(base);
  }

  schema.assign(keyword, sourcemeta::core::JSON{value.recompose()});
}

namespace sourcemeta::one {

Resolver::Resolver(const std::string_view url)
    : server_url_{url}, server_uri_{std::string{url}} {}

auto Resolver::operator()(
    std::string_view raw_identifier,
    const std::function<void(const std::filesystem::path &)> &callback) const
    -> std::optional<sourcemeta::core::JSON> {
  /////////////////////////////////////////////////////////////////////////////
  // (1) Lookup the schema
  /////////////////////////////////////////////////////////////////////////////

  // Internally, we keep all schema URI identifiers as lowercase to avoid
  // tricky cases with case-insensitive operating systems
  const auto identifier{normalise_identifier(raw_identifier)};

  // When resolving a schema, the resolver needs to determine its dialect in
  // order to normalise references. This involves resolving the schema's
  // metaschema, which may itself be a schema managed by this resolver. That
  // triggers a re-entrant resolution call, and if the metaschema chain is
  // circular, the resolver recurses infinitely. This set tracks which
  // identifiers are currently being resolved so we can detect the cycle and
  // return nullopt instead, letting the caller handle the missing metaschema.
  thread_local std::unordered_set<std::string> resolving;
  if (!resolving.emplace(identifier).second) {
    return std::nullopt;
  }

  struct ResolveGuard {
    std::string uri;
    ~ResolveGuard() { resolving.erase(uri); }
  } resolve_guard{std::string{identifier}};

  // The cached materialisation path is the only part of an entry that is
  // mutated after registration, and those writes happen concurrently with
  // resolution, so it must be snapshotted under the shared lock. The rest
  // of the entry is immutable by the time concurrent resolution starts, so
  // it can be safely referenced after releasing the lock. Note that growing
  // an unordered container invalidates iterators but never pointers or
  // references to its elements, and entries are never erased, so the
  // addresses captured here outlive concurrent registrations
  const Entry *view{nullptr};
  const sourcemeta::core::JSON::String *new_identifier{nullptr};
  std::optional<std::filesystem::path> cached_path;
  {
    std::shared_lock lock{this->mutex_};
    const auto result{this->views_.find(identifier)};
    if (result != this->views_.cend()) {
      view = &result->second;
      new_identifier = &result->first;
      cached_path = result->second.cache_path;
    }
  }

  // If we don't recognise the schema, try a fallback as a last resort
  if (view == nullptr) {
    auto fallback{sourcemeta::blaze::schema_resolver(identifier)};
    if (!fallback.has_value()) {
      return std::nullopt;
    }

    return std::move(fallback).to_owned();
  }

  auto cached{this->cached_dialect(identifier)};
  if (cached.has_value()) {
    if (callback) {
      callback(cached_path.has_value() ? cached_path.value() : view->path);
    }

    return cached;
  }

  /////////////////////////////////////////////////////////////////////////////
  // (2) Avoid rebasing on the fly if possible
  /////////////////////////////////////////////////////////////////////////////

  if (cached_path.has_value()) {
    // We can guarantee the cached outcome is JSON, so we don't need to try
    // reading as YAML
    auto schema_option{
        sourcemeta::one::metapack_read_json(cached_path.value())};
    assert(schema_option.has_value());
    auto schema{std::move(schema_option.value())};
    assert(schema.is_object() || schema.is_boolean());
    if (callback) {
      callback(cached_path.value());
    }

    this->cache_dialect(identifier, schema);
    return schema;
  }

  /////////////////////////////////////////////////////////////////////////////
  // (3) Read the original schema file
  /////////////////////////////////////////////////////////////////////////////

  auto schema{sourcemeta::core::read_yaml_or_json(view->path)};
  assert(schema.is_object() || schema.is_boolean());
  if (callback) {
    callback(view->path);
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
  schema.assign("$schema", sourcemeta::core::JSON{view->dialect});

  /////////////////////////////////////////////////////////////////////////////
  // (5) Normalise all references, if any, to match the new identifier
  /////////////////////////////////////////////////////////////////////////////

  const sourcemeta::blaze::SchemaFrame frame{
      sourcemeta::blaze::SchemaFrame::Mode::Locations,
      schema,
      sourcemeta::blaze::schema_walker,
      [this](
          const auto subidentifier) -> std::optional<sourcemeta::core::JSON> {
        return this->operator()(subidentifier);
      },
      view->dialect,
      view->original_identifier,
      sourcemeta::blaze::SchemaFrame::IdentifierMode::Fallback};

  const auto ref_hash{schema.as_object().hash("$ref")};
  const auto dynamic_ref_hash{schema.as_object().hash("$dynamicRef")};
  frame.for_each_subschema([this, &schema, &view, ref_hash,
                            dynamic_ref_hash](const auto &location) -> void {
    auto &subschema{sourcemeta::core::get(schema, location.pointer)};
    if (!subschema.is_object()) {
      return;
    }

    const auto maybe_ref{subschema.try_at("$ref", ref_hash)};
    const auto maybe_dynamic_ref{
        location.base_dialect ==
                sourcemeta::blaze::SchemaBaseDialect::JSON_SCHEMA_2020_12
            ? subschema.try_at("$dynamicRef", dynamic_ref_hash)
            : nullptr};
    const auto has_ref{maybe_ref && maybe_ref->is_string()};
    const auto has_dynamic_ref{maybe_dynamic_ref &&
                               maybe_dynamic_ref->is_string()};
    if (!has_ref && !has_dynamic_ref) {
      return;
    }

    const sourcemeta::core::URI subschema_base{std::string{location.base}};
    if (has_ref) {
      normalise_ref(*view->collection, subschema_base, subschema, "$ref",
                    maybe_ref->to_string(), this->server_uri_);
    }
    if (has_dynamic_ref) {
      normalise_ref(*view->collection, subschema_base, subschema, "$dynamicRef",
                    maybe_dynamic_ref->to_string(), this->server_uri_);
    }
  });

  /////////////////////////////////////////////////////////////////////////////
  // (6) Assign the new final identifier to the schema
  /////////////////////////////////////////////////////////////////////////////

  sourcemeta::blaze::schema_reidentify(
      schema, *new_identifier,
      [this](
          const auto subidentifier) -> std::optional<sourcemeta::core::JSON> {
        return this->operator()(subidentifier);
      },
      view->dialect);

  this->cache_dialect(identifier, schema);
  return schema;
}

auto Resolver::track_dialect(const sourcemeta::core::JSON::String &dialect)
    -> void {
  // Official dialects are resolved through the static fallback resolver
  // rather than through this resolver, so we never get the chance to cache
  // them anyway
  if (sourcemeta::blaze::schema_is_known(dialect)) {
    return;
  }

  std::unique_lock lock{this->dialect_mutex_};
  const auto match{std::ranges::find_if(this->dialects_,
                                        [&dialect](const auto &entry) -> bool {
                                          return entry.first == dialect;
                                        })};
  if (match == this->dialects_.cend()) {
    this->dialects_.emplace_back(dialect, std::nullopt);
  }
}

auto Resolver::cache_dialect(const sourcemeta::core::JSON::String &uri,
                             const sourcemeta::core::JSON &schema) const
    -> void {
  // Most schemas are not dialects, so we first check whether there is
  // anything to do while only holding the shared lock
  {
    std::shared_lock lock{this->dialect_mutex_};
    const auto match{std::ranges::find_if(
        this->dialects_,
        [&uri](const auto &entry) -> bool { return entry.first == uri; })};
    if (match == this->dialects_.cend() || match->second.has_value()) {
      return;
    }
  }

  std::unique_lock lock{this->dialect_mutex_};
  const auto match{
      std::ranges::find_if(this->dialects_, [&uri](const auto &entry) -> bool {
        return entry.first == uri;
      })};
  if (match != this->dialects_.cend() && !match->second.has_value()) {
    match->second = schema;
  }
}

auto Resolver::cached_dialect(const sourcemeta::core::JSON::String &uri) const
    -> std::optional<sourcemeta::core::JSON> {
  std::shared_lock lock{this->dialect_mutex_};
  const auto match{
      std::ranges::find_if(this->dialects_, [&uri](const auto &entry) -> bool {
        return entry.first == uri;
      })};
  if (match != this->dialects_.cend() && match->second.has_value()) {
    return match->second;
  }

  return std::nullopt;
}

auto Resolver::add(const std::filesystem::path &collection_relative_path,
                   const Configuration::Collection &collection,
                   const std::filesystem::path &path,
                   const std::filesystem::file_time_type mtime) -> Result {
  /////////////////////////////////////////////////////////////////////////////
  // (1) Read the schema file
  /////////////////////////////////////////////////////////////////////////////
  assert(path.is_absolute());
  try {
    const auto schema{sourcemeta::core::read_yaml_or_json(path)};
    if (!schema.is_object() && !schema.is_boolean()) {
      throw ResolverNotASchemaError(path);
    }

    const std::string default_dialect_str{
        collection.default_dialect.value_or("")};

    /////////////////////////////////////////////////////////////////////////////
    // (2) Try our best to determine the identifier of the schema, defaulting to
    // a file-system-based identifier based on the *current* URI
    /////////////////////////////////////////////////////////////////////////////
    const auto default_identifier{
        sourcemeta::core::URI{collection.base_uri}
            .append_path(normalise_identifier(
                std::filesystem::relative(path, collection.absolute_path)
                    .string()))
            .canonicalize()
            .recompose()};
    sourcemeta::core::URI identifier_uri{
        normalise_identifier(declared_identifier(
            schema,
            [this, &collection](const auto subidentifier)
                -> std::optional<sourcemeta::core::JSON> {
              const auto rewritten{
                  pre_resolve(collection, subidentifier, this->server_uri_)};
              if (rewritten.has_value()) {
                return this->operator()(*rewritten);
              }
              return this->operator()(subidentifier);
            },
            default_dialect_str, default_identifier))};
    identifier_uri.canonicalize();
    auto identifier{identifier_uri.is_relative()
                        ? sourcemeta::core::URI{collection.base_uri}
                              .append_path(std::move(identifier_uri))
                              .canonicalize()
                              .recompose()
                        : identifier_uri.recompose()};
    // We have to do something if the schema is the base. Note that URI
    // canonicalisation technically cannot remove trailing slashes as they might
    // have meaning in certain use cases. But we still consider them equal in
    // the context of the One
    if (identifier == collection.base || identifier == collection.base + "/") {
      identifier = default_identifier;
    }
    // A final check that everything went well
    if (!identifier.starts_with(collection.base)) {
      throw ResolverOutsideBaseError(path, identifier, collection.base);
    }
    // Otherwise we have things like "../" that should not be there
    assert(identifier.find("..") == std::string::npos);

    /////////////////////////////////////////////////////////////////////////////
    // (3) Determine the new URI of the schema, from the one base URI
    /////////////////////////////////////////////////////////////////////////////
    const auto new_identifier{rebase(collection, identifier, this->server_uri_,
                                     collection_relative_path)};
    // Otherwise we have things like "../" that should not be there
    assert(new_identifier.find("..") == std::string::npos);

    /////////////////////////////////////////////////////////////////////////////
    // (4) Determine the dialect of the schema, which we also need to make sure
    // we rebase according to the one base URI, etc
    /////////////////////////////////////////////////////////////////////////////
    const auto *declared_dialect{schema.is_object() ? schema.try_at("$schema")
                                                    : nullptr};
    std::string raw_dialect{declared_dialect != nullptr &&
                                    declared_dialect->is_string()
                                ? declared_dialect->to_string()
                                : default_dialect_str};
    if (raw_dialect.empty()) {
      throw sourcemeta::blaze::SchemaUnknownDialectError();
    }
    auto rewritten{pre_resolve(collection, raw_dialect, this->server_uri_)};
    bool resolved_to_instance{false};
    if (rewritten.has_value()) {
      raw_dialect = std::move(*rewritten);
      // If pre_resolve yielded a URI already in the instance URL's authority,
      // it is already in the canonical registry form. The rebase machinery
      // exists to translate baseUri-canonical identifiers into server-URL
      // form, and would only mangle a URI that is already there.
      resolved_to_instance =
          sourcemeta::core::URI{raw_dialect}.has_same_authority(
              this->server_uri_);
    }
    const auto is_known_dialect{
        !resolved_to_instance &&
        sourcemeta::blaze::schema_is_known(raw_dialect)};
    auto current_dialect{
        resolved_to_instance ? normalise_identifier(raw_dialect)
        : is_known_dialect
            ? raw_dialect
            : rebase(collection, normalise_identifier(raw_dialect),
                     this->server_uri_, collection_relative_path)};
    // Otherwise we messed things up
    assert(!current_dialect.ends_with("#.json"));

    /////////////////////////////////////////////////////////////////////////////
    // (5) Safely one the schema entry in the resolver
    /////////////////////////////////////////////////////////////////////////////

    const auto evaluate{Configuration::should_evaluate(collection)};

    std::unique_lock lock{this->mutex_};
    auto result{this->views_.emplace(
        new_identifier,
        Entry{.path = path,
              .relative_path = sourcemeta::core::URI{new_identifier}
                                   .relative_to(this->server_uri_)
                                   .recompose(),
              .mtime = mtime,
              .evaluate = evaluate,
              .cache_path = std::nullopt,
              .dialect = std::move(current_dialect),
              .original_identifier = identifier,
              .collection = &collection})};
    lock.unlock();
    if (!result.second && result.first->second.path != path) {
      throw sourcemeta::core::FileError<sourcemeta::blaze::SchemaFrameError>(
          path, result.first->first,
          "Cannot register the same identifier twice");
    }
    this->track_dialect(result.first->second.dialect);
    return {result.first->first, result.first->second};
  } catch (const sourcemeta::blaze::SchemaKeywordError &error) {
    throw sourcemeta::core::FileError<sourcemeta::blaze::SchemaKeywordError>(
        path, error.keyword(), error.value(), error.what());
  } catch (const sourcemeta::blaze::SchemaUnknownDialectError &) {
    throw sourcemeta::core::FileError<
        sourcemeta::blaze::SchemaUnknownDialectError>(path);
  } catch (const sourcemeta::core::URIParseError &) {
    const auto reread{sourcemeta::core::read_yaml_or_json(path)};
    const auto &id_keyword{reread.defines("$id") ? "$id" : "id"};
    std::ostringstream value_stream;
    sourcemeta::core::stringify(reread.at(id_keyword), value_stream);
    throw sourcemeta::core::FileError<sourcemeta::blaze::SchemaKeywordError>(
        path, id_keyword, value_stream.str(),
        "The schema identifier is not a valid URI");
  } catch (const sourcemeta::core::YAMLParseError &error) {
    throw sourcemeta::core::FileError<sourcemeta::core::YAMLParseError>(
        path, error.line(), error.column(), error.what());
  }
}

auto Resolver::emplace(std::string new_identifier, Entry entry) -> void {
  assert(std::filesystem::exists(entry.path));
  assert(entry.cache_path.has_value());
  // A cache hit means a finished build wrote this artifact, so it being gone
  // means the output directory was modified from outside. That violates the
  // one assumption the cache rests on, and it has to fail the same way in
  // every build type rather than trip an assertion only where those exist.
  // The check must not itself throw, since a path the build cannot examine,
  // whatever the reason, is equally a record it cannot honour
  std::error_code existence_error;
  if (!std::filesystem::exists(entry.cache_path.value(), existence_error)) {
    throw ResolverMissingCachedArtifactError{entry.cache_path.value()};
  }

  assert(entry.collection);
  const auto path{entry.path};
  auto result{
      this->views_.emplace(std::move(new_identifier), std::move(entry))};
  if (!result.second && result.first->second.path != path) {
    throw sourcemeta::blaze::SchemaFrameError(
        result.first->first, "Cannot register the same identifier twice");
  }
  this->track_dialect(result.first->second.dialect);
}

auto Resolver::entry(const std::string_view identifier) const -> const Entry & {
  const auto result{this->views_.find(std::string{identifier})};
  assert(result != this->views_.cend());
  assert(!result->second.dialect.empty());
  assert(!result->second.original_identifier.empty());
  assert(result->second.collection != nullptr);
  return result->second;
}

auto Resolver::cache_path(const std::string_view uri,
                          const std::filesystem::path &path) -> void {
  assert(std::filesystem::exists(path));
  // As we are modifying the actual map
  std::unique_lock lock{this->mutex_};
  auto entry{this->views_.find(std::string{uri})};
  assert(entry != this->views_.cend());
  assert(!entry->second.cache_path.has_value());
  entry->second.cache_path = path;
}

} // namespace sourcemeta::one
