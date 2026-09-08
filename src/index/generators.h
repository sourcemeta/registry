#ifndef SOURCEMETA_ONE_INDEX_GENERATORS_H_
#define SOURCEMETA_ONE_INDEX_GENERATORS_H_

#include "endpoints.h"
#include "error.h"

#include <sourcemeta/one/actions.h>
#include <sourcemeta/one/authentication.h>
#include <sourcemeta/one/build.h>
#include <sourcemeta/one/metapack.h>
#include <sourcemeta/one/resolver.h>
#include <sourcemeta/one/shared.h>

#include <sourcemeta/blaze/alterschema.h>
#include <sourcemeta/blaze/bundle.h>
#include <sourcemeta/blaze/editor.h>
#include <sourcemeta/blaze/format.h>
#include <sourcemeta/blaze/foundation.h>
#include <sourcemeta/core/io.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>
#include <sourcemeta/core/uritemplate.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/configuration.h>
#include <sourcemeta/blaze/evaluator.h>

#if defined(SOURCEMETA_ONE_ENTERPRISE)
#include <sourcemeta/one/enterprise_index.h>
#endif

#include <array>        // std::array, std::to_array
#include <cassert>      // assert
#include <cstring>      // std::memcpy
#include <filesystem>   // std::filesystem
#include <format>       // std::format
#include <limits>       // std::numeric_limits
#include <memory>       // std::unique_ptr, std::make_unique
#include <mutex>        // std::once_flag, std::call_once
#include <optional>     // std::optional
#include <ostream>      // std::ostream
#include <shared_mutex> // std::shared_mutex, std::shared_lock, std::unique_lock
#include <sstream>      // std::ostringstream
#include <string>       // std::string
#include <string_view>  // std::string_view
#include <unordered_map> // std::unordered_map
#include <unordered_set> // std::unordered_set
#include <utility>       // std::move, std::unreachable
#include <variant>       // std::holds_alternative, std::get
#include <vector>        // std::vector

namespace sourcemeta::one {

#pragma pack(push, 1)
struct MetapackDialectExtension {
  std::uint16_t dialect_length;
};
#pragma pack(pop)

static auto make_dialect_extension(const std::string_view dialect)
    -> std::vector<std::uint8_t> {
  assert(dialect.size() <= std::numeric_limits<std::uint16_t>::max());
  std::vector<std::uint8_t> result;
  result.resize(sizeof(MetapackDialectExtension) + dialect.size());
  MetapackDialectExtension header{};
  header.dialect_length = static_cast<std::uint16_t>(dialect.size());
  std::memcpy(result.data(), &header, sizeof(header));
  std::memcpy(result.data() + sizeof(header), dialect.data(), dialect.size());
  return result;
}

// The name a location kind answers to outside this program, which is a name
// this project promises rather than one it happens to use
static auto
location_type_name(const sourcemeta::blaze::SchemaFrame::LocationType type)
    -> std::string_view {
  switch (type) {
    case sourcemeta::blaze::SchemaFrame::LocationType::Resource:
      return "resource";
    case sourcemeta::blaze::SchemaFrame::LocationType::Anchor:
      return "anchor";
    case sourcemeta::blaze::SchemaFrame::LocationType::Pointer:
      return "pointer";
    case sourcemeta::blaze::SchemaFrame::LocationType::Subschema:
      return "subschema";
  }

  std::unreachable();
}

// Which vocabulary a keyword belongs to, as a name a report is keyed by, with
// keywords no vocabulary claims gathered under one of their own
static auto
vocabulary_name(const sourcemeta::blaze::SchemaWalkerResult &walker_result)
    -> sourcemeta::core::JSON::String {
  if (!walker_result.vocabulary.has_value()) {
    return "unknown";
  }

  const auto &vocabulary{walker_result.vocabulary.value()};
  if (std::holds_alternative<sourcemeta::blaze::SchemaVocabularies::Known>(
          vocabulary)) {
    return std::format(
        "{}",
        std::get<sourcemeta::blaze::SchemaVocabularies::Known>(vocabulary));
  }

  return sourcemeta::core::JSON::String{std::get<std::string_view>(vocabulary)};
}

// A metaschema that insists on a vocabulary this build does not implement is
// one it cannot honour, so saying so is better than quietly ignoring half of
// what the metaschema asks for.
//
// Only these dialects give `$vocabulary` that meaning. Anywhere else it is an
// ordinary keyword that happens to share the name, which is why the dialect is
// established before the declaration is read at all
static auto throw_if_unknown_required_vocabulary(
    const sourcemeta::core::JSON &schema,
    const sourcemeta::blaze::SchemaResolver &resolver,
    const std::string_view dialect) -> void {
  const sourcemeta::blaze::SchemaFrame frame{
      sourcemeta::blaze::SchemaFrame::Mode::Root, schema,
      sourcemeta::blaze::schema_walker, resolver, dialect};
  const auto base{frame.root_location().value().get().base_dialect};

  if (base != sourcemeta::blaze::SchemaBaseDialect::JSON_SCHEMA_2020_12 &&
      base != sourcemeta::blaze::SchemaBaseDialect::JSON_SCHEMA_2020_12_HYPER &&
      base != sourcemeta::blaze::SchemaBaseDialect::JSON_SCHEMA_2019_09 &&
      base != sourcemeta::blaze::SchemaBaseDialect::JSON_SCHEMA_2019_09_HYPER) {
    return;
  }

  const auto *declared{schema.try_at("$vocabulary")};
  if (declared == nullptr || !declared->is_object()) {
    return;
  }

  // A declaration that is not shaped like one says nothing here, as what a
  // malformed metaschema is worth was already decided against the metaschema
  // it declares itself against
  for (const auto &entry : declared->as_object()) {
    if (!entry.second.is_boolean()) {
      return;
    }
  }

  for (const auto &entry : declared->as_object()) {
    // Not implementing an optional vocabulary is what optional means
    if (!entry.second.to_boolean()) {
      continue;
    }

    // Whether a vocabulary is one this build knows is a question only the set
    // that holds them can answer, so it is asked one vocabulary at a time in
    // order to name the one that could not be honoured
    sourcemeta::blaze::SchemaVocabularies vocabulary;
    vocabulary.insert(entry.first, true);
    if (vocabulary.has_unknown()) {
      throw sourcemeta::blaze::SchemaVocabularyError(
          entry.first, "The metaschema requires an unrecognised vocabulary");
    }
  }
}

struct GenerateVersion {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &,
                      sourcemeta::one::Resolver &,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    sourcemeta::core::atomic_write_file(
        action.destination, [&](std::ostream &stream) {
          sourcemeta::core::stringify(sourcemeta::core::JSON{action.data},
                                      stream);
        });
  }
};

struct GenerateComment {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &,
                      sourcemeta::one::Resolver &,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    sourcemeta::core::atomic_write_file(
        action.destination, [&](std::ostream &stream) {
          sourcemeta::core::stringify(sourcemeta::core::JSON{action.data},
                                      stream);
        });
  }
};

struct GenerateConfiguration {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &,
                      sourcemeta::one::Resolver &,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &raw_configuration) -> void {
    sourcemeta::core::atomic_write_file(
        action.destination, [&](std::ostream &stream) {
          sourcemeta::core::stringify(raw_configuration, stream);
        });
  }
};

struct GenerateMaterialisedSchema {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &callback,
                      sourcemeta::one::Resolver &resolver,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    auto schema{resolver(action.data)};
    assert(schema.has_value());
    const auto *declared_dialect{schema->is_object() ? schema->try_at("$schema")
                                                     : nullptr};
    const std::string_view dialect_identifier{
        declared_dialect != nullptr && declared_dialect->is_string()
            ? std::string_view{declared_dialect->to_string()}
            : std::string_view{}};
    assert(!dialect_identifier.empty());
    const auto metaschema{resolver(dialect_identifier, callback)};
    assert(metaschema.has_value());

    // Validate the schemas against their meta-schemas
    sourcemeta::blaze::SimpleOutput output{schema.value()};
    sourcemeta::blaze::Evaluator evaluator;
    const auto result{evaluator.validate(
        GenerateMaterialisedSchema::compile(std::string{dialect_identifier},
                                            metaschema.value(), resolver),
        schema.value(), std::ref(output))};
    if (!result) {
      throw MetaschemaError(output);
    }

    // Most schemas are not metaschemas, so this check is a nice
    // heuristic to avoid the cost of resolving the base dialect
    // on most of them
    if (schema->is_object() && schema->defines("$vocabulary")) {
      throw_if_unknown_required_vocabulary(
          schema.value(),
          [&callback, &resolver](const auto identifier) {
            return resolver(identifier, callback);
          },
          dialect_identifier);
    }

    sourcemeta::blaze::format(
        schema.value(), sourcemeta::blaze::schema_walker,
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        },
        dialect_identifier);
    const auto timestamp_end{std::chrono::steady_clock::now()};

    const auto extension_bytes{make_dialect_extension(dialect_identifier)};
    sourcemeta::one::metapack_write_pretty_json(
        action.destination, schema.value(), "application/schema+json",
        sourcemeta::one::MetapackEncoding::GZIP,
        std::span<const std::uint8_t>{extension_bytes},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
    resolver.cache_path(action.data, action.destination);
  }

private:
  static auto compile(const std::string &cache_key,
                      const sourcemeta::core::JSON &schema,
                      const sourcemeta::one::Resolver &resolver)
      -> const sourcemeta::blaze::Template & {
    struct Slot {
      std::once_flag flag;
      sourcemeta::blaze::Template value;
    };

    // Wave 0 is exclusively schema materialisation, so a single lock across the
    // exhaustive compile would serialise every worker. A shared lock lets cache
    // hits proceed without contending, and a per-dialect `once_flag` compiles
    // each dialect exactly once while distinct dialects compile concurrently
    static std::shared_mutex mutex;
    static std::unordered_map<std::string, std::unique_ptr<Slot>> cache;

    Slot *slot{nullptr};
    {
      const std::shared_lock lock{mutex};
      const auto match{cache.find(cache_key)};
      if (match != cache.cend()) {
        slot = match->second.get();
      }
    }

    if (slot == nullptr) {
      const std::unique_lock lock{mutex};
      auto &entry{cache[cache_key]};
      if (!entry) {
        entry = std::make_unique<Slot>();
      }
      slot = entry.get();
    }

    std::call_once(slot->flag, [&] {
      slot->value = sourcemeta::blaze::compile(
          schema, sourcemeta::blaze::schema_walker,
          [&resolver](const auto identifier) { return resolver(identifier); },
          sourcemeta::blaze::default_schema_compiler,
          // The point of this class is to show nice errors to the user
          sourcemeta::blaze::Mode::Exhaustive);
    });
    return slot->value;
  }
};

struct GeneratePointerPositions {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &,
                      sourcemeta::one::Resolver &,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    const auto schema_option{
        sourcemeta::one::metapack_read_json(action.dependencies.front())};
    assert(schema_option.has_value());
    const auto &schema{schema_option.value()};
    std::ostringstream schema_stream;
    sourcemeta::core::prettify(schema, schema_stream);
    sourcemeta::core::PointerPositionTracker tracker;
    sourcemeta::core::JSON parsed{nullptr};
    sourcemeta::core::parse_json(schema_stream.str(), parsed,
                                 std::ref(tracker));
    const auto result{sourcemeta::core::to_json(tracker)};
    const auto timestamp_end{std::chrono::steady_clock::now()};
    sourcemeta::one::metapack_write_pretty_json(
        action.destination, result, "application/json",
        sourcemeta::one::MetapackEncoding::GZIP, {},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }
};

struct GenerateFrameLocations {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &callback,
                      sourcemeta::one::Resolver &resolver,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    const auto contents_option{
        sourcemeta::one::metapack_read_json(action.dependencies.front())};
    assert(contents_option.has_value());
    const auto &contents{contents_option.value()};
    std::ostringstream contents_stream;
    sourcemeta::core::prettify(contents, contents_stream);
    sourcemeta::core::PointerPositionTracker tracker;
    sourcemeta::core::JSON parsed{nullptr};
    sourcemeta::core::parse_json(contents_stream.str(), parsed,
                                 std::ref(tracker));
    const sourcemeta::blaze::SchemaResolver schema_resolver{
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        }};
    const sourcemeta::blaze::SchemaFrame frame{
        sourcemeta::blaze::SchemaFrame::Mode::Locations, contents,
        sourcemeta::blaze::schema_walker, schema_resolver};
    auto result{sourcemeta::core::JSON::make_object()};
    result.assign("static", sourcemeta::core::JSON::make_object());
    result.assign("dynamic", sourcemeta::core::JSON::make_object());
    frame.for_each_location(
        [&frame, &tracker, &result](
            const sourcemeta::blaze::SchemaReferenceType type,
            const std::string_view uri,
            const sourcemeta::blaze::SchemaFrame::Location &location) -> void {
          auto entry{sourcemeta::core::JSON::make_object()};
          entry.assign("parent",
                       location.parent.has_value()
                           ? sourcemeta::core::JSON{sourcemeta::core::to_string(
                                 location.parent.value())}
                           : sourcemeta::core::JSON{nullptr});
          entry.assign("type",
                       sourcemeta::core::JSON{sourcemeta::core::JSON::String{
                           location_type_name(location.type)}});
          entry.assign("root", frame.root().empty()
                                   ? sourcemeta::core::JSON{nullptr}
                                   : sourcemeta::core::JSON{frame.root()});
          entry.assign("base",
                       sourcemeta::core::JSON{
                           sourcemeta::core::JSON::String{location.base}});
          entry.assign("pointer",
                       sourcemeta::core::JSON{
                           sourcemeta::core::to_string(location.pointer)});
          entry.assign("position",
                       sourcemeta::core::to_json(tracker.get(
                           sourcemeta::core::to_pointer(location.pointer))));
          entry.assign("relativePointer",
                       sourcemeta::core::JSON{sourcemeta::core::to_string(
                           frame.relative_instance_location(location))});
          entry.assign("dialect",
                       sourcemeta::core::JSON{
                           sourcemeta::core::JSON::String{location.dialect}});
          entry.assign("baseDialect", sourcemeta::core::JSON{std::format(
                                          "{}", location.base_dialect)});
          entry.assign("propertyName",
                       sourcemeta::core::JSON{location.property_name});
          entry.assign("orphan", sourcemeta::core::JSON{location.orphan});
          switch (type) {
            case sourcemeta::blaze::SchemaReferenceType::Static:
              result.at("static").assign(sourcemeta::core::JSON::String{uri},
                                         std::move(entry));
              break;
            case sourcemeta::blaze::SchemaReferenceType::Dynamic:
              result.at("dynamic").assign(sourcemeta::core::JSON::String{uri},
                                          std::move(entry));
              break;
          }
        });
    const auto timestamp_end{std::chrono::steady_clock::now()};
    sourcemeta::one::metapack_write_pretty_json(
        action.destination, result, "application/json",
        sourcemeta::one::MetapackEncoding::GZIP, {},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }
};

struct GenerateDependencies {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &callback,
                      sourcemeta::one::Resolver &resolver,
                      const sourcemeta::one::Configuration &configuration,
                      const sourcemeta::core::JSON &) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    const auto contents_option{
        sourcemeta::one::metapack_read_json(action.dependencies.front())};
    assert(contents_option.has_value());
    const auto &contents{contents_option.value()};
    auto result{sourcemeta::core::JSON::make_array()};
    sourcemeta::blaze::dependencies(
        contents, sourcemeta::blaze::schema_walker,
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        },
        [&result](const auto &origin, const auto &pointer, const auto &target,
                  const auto &) {
          auto trace{sourcemeta::core::JSON::make_object()};
          trace.assign("from", without_json_extension(origin));
          trace.assign("to", without_json_extension(target));
          trace.assign("at", sourcemeta::core::JSON{
                                 sourcemeta::core::to_string(pointer)});
          result.push_back(std::move(trace));
        });
    // Otherwise we are returning non-sense
    assert(result.unique());

    if (!result.empty()) {
      const sourcemeta::one::Authentication::Table authentication{
          action.dependencies.at(1)};
      for (const auto &edge : result.as_array()) {
        const auto &referrer_uri{edge.at("from").to_string()};
        const auto &referent_uri{edge.at("to").to_string()};
        const auto referrer{sourcemeta::one::Authentication::Path::parse(
            referrer_uri, configuration.url)};
        const auto referent{sourcemeta::one::Authentication::Path::parse(
            referent_uri, configuration.url)};
        if (referrer.has_value() && referent.has_value() &&
            !authentication.reference_permitted(referrer.value(),
                                                referent.value())) {
          throw CrossPolicyReferenceError(configuration.path, referrer_uri,
                                          referent_uri);
        }
      }
    }

    const auto timestamp_end{std::chrono::steady_clock::now()};

    sourcemeta::one::metapack_write_pretty_json(
        action.destination, result, "application/json",
        sourcemeta::one::MetapackEncoding::GZIP, {},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }

private:
  static auto without_json_extension(const std::string_view uri)
      -> sourcemeta::core::JSON {
    if (uri.ends_with(".json")) {
      return sourcemeta::core::JSON{uri.substr(0, uri.size() - 5)};
    }

    return sourcemeta::core::JSON{uri};
  }
};

struct GenerateHealth {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &callback,
                      sourcemeta::one::Resolver &resolver,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    const auto contents_option{
        sourcemeta::one::metapack_read_json(action.dependencies.front())};
    assert(contents_option.has_value());
    const auto &contents{contents_option.value()};
    const auto &collection{*resolver.entry(action.data).collection};
    auto errors{sourcemeta::core::JSON::make_array()};
    auto report{sourcemeta::core::JSON::make_object()};

    // The bundle carries mutable per-rule state, so a single instance cannot be
    // checked from multiple threads at once. Rather than serialise the whole
    // health wave behind one lock, keep a bundle per worker thread so linting
    // runs concurrently
    {
      auto &cache_entry{bundle_for(collection, resolver, callback)};
      const auto result{cache_entry.bundle.check(
          contents, sourcemeta::blaze::schema_walker,
          [&callback, &resolver](const auto identifier) {
            return resolver(identifier, callback);
          },
          [&errors, &cache_entry](const auto &pointer, const auto &name,
                                  const auto &message, const auto &outcome,
                                  const bool) {
            auto entry{sourcemeta::core::JSON::make_object()};
            entry.assign("name", sourcemeta::core::JSON{name});
            entry.assign("message", sourcemeta::core::JSON{message});
            entry.assign("description",
                         sourcemeta::core::to_json(outcome.description));
            entry.assign("custom",
                         sourcemeta::core::JSON{
                             cache_entry.custom_names.contains(name)});

            auto pointers{sourcemeta::core::JSON::make_array()};
            if (outcome.locations.empty()) {
              pointers.push_back(
                  sourcemeta::core::JSON{sourcemeta::core::to_string(pointer)});
            } else {
              for (const auto &location : outcome.locations) {
                pointers.push_back(sourcemeta::core::JSON{
                    sourcemeta::core::to_string(pointer.concat(location))});
              }
            }

            entry.assign("pointers", std::move(pointers));
            errors.push_back(std::move(entry));
          })};
      report.assign("score", sourcemeta::core::to_json(result.second));
    }

    report.assign("errors", std::move(errors));
    const auto timestamp_end{std::chrono::steady_clock::now()};

    sourcemeta::one::metapack_write_pretty_json(
        action.destination, report, "application/json",
        sourcemeta::one::MetapackEncoding::GZIP, {},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }

private:
  struct CacheEntry {
    sourcemeta::blaze::SchemaTransformer bundle;
    std::unordered_set<std::string_view> custom_names;
  };

  // Built once per configuration per worker thread. Each thread owns its bundle
  // so checks against the bundle's mutable per-rule state never race, which
  // lets the health wave run concurrently rather than behind a single lock
  static auto bundle_for(
      const sourcemeta::blaze::Configuration &configuration,
      [[maybe_unused]] const sourcemeta::one::Resolver &resolver,
      [[maybe_unused]] const sourcemeta::one::BuildDynamicCallback &callback)
      -> CacheEntry & {
    thread_local std::unordered_map<const void *, std::unique_ptr<CacheEntry>>
        cache;
    const auto *key{static_cast<const void *>(&configuration)};
    const auto match{cache.find(key)};
    if (match != cache.cend()) {
      return *match->second;
    }

    auto entry{std::make_unique<CacheEntry>()};
    sourcemeta::blaze::add(entry->bundle,
                           sourcemeta::blaze::AlterSchemaMode::Linter);

#if defined(SOURCEMETA_ONE_ENTERPRISE)
    sourcemeta::one::load_custom_lint_rules(entry->bundle, entry->custom_names,
                                            configuration, resolver, callback);
#else
    if (!configuration.lint.rules.empty()) {
      const auto *config_path{
          configuration.extra.try_at("x-sourcemeta-one:path")};
      assert(config_path);
      throw EnterpriseOnlyFeatureError(
          std::filesystem::path{config_path->to_string()},
          "Custom linter rules are only available on the enterprise edition");
    }
#endif

    return *cache.emplace(key, std::move(entry)).first->second;
  }
};

// Inlining happens with no containment check here, so nothing in this handler
// stops a reference reaching content the schema's own path does not admit. What
// stops it is that such a reference fails the build one step earlier, when the
// outgoing edges are recorded. That is what keeps every artifact beside this
// one exactly as visible as the schema it belongs to, and therefore gated
// wholesale on that schema's path, so relaxing the earlier rule to permit the
// reference and merely omit it here would be a leak rather than a narrowing
struct GenerateBundle {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &callback,
                      sourcemeta::one::Resolver &resolver,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    auto schema_option{
        sourcemeta::one::metapack_read_json(action.dependencies.front())};
    assert(schema_option.has_value());
    auto schema{std::move(schema_option.value())};
    // The registry serves every meta-schema a schema may declare, so
    // bundles only need to embed references and can skip meta-schemas
    sourcemeta::blaze::bundle(
        schema, sourcemeta::blaze::schema_walker,
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        },
        sourcemeta::blaze::BundleMode::References);
    const auto *declared_dialect{schema.is_object() ? schema.try_at("$schema")
                                                    : nullptr};
    const std::string_view dialect_identifier{
        declared_dialect != nullptr && declared_dialect->is_string()
            ? std::string_view{declared_dialect->to_string()}
            : std::string_view{}};
    assert(!dialect_identifier.empty());
    sourcemeta::blaze::format(
        schema, sourcemeta::blaze::schema_walker,
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        },
        dialect_identifier);
    const auto timestamp_end{std::chrono::steady_clock::now()};

    const auto extension_bytes{make_dialect_extension(dialect_identifier)};
    sourcemeta::one::metapack_write_pretty_json(
        action.destination, schema, "application/schema+json",
        sourcemeta::one::MetapackEncoding::GZIP,
        std::span<const std::uint8_t>{extension_bytes},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }
};

struct GenerateEditor {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &callback,
                      sourcemeta::one::Resolver &resolver,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    auto schema_option{
        sourcemeta::one::metapack_read_json(action.dependencies.front())};
    assert(schema_option.has_value());
    auto schema{std::move(schema_option.value())};
    sourcemeta::blaze::for_editor(
        schema, sourcemeta::blaze::schema_walker,
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        });
    const auto *declared_dialect{schema.is_object() ? schema.try_at("$schema")
                                                    : nullptr};
    const std::string_view dialect_identifier{
        declared_dialect != nullptr && declared_dialect->is_string()
            ? std::string_view{declared_dialect->to_string()}
            : std::string_view{}};
    assert(!dialect_identifier.empty());
    sourcemeta::blaze::format(
        schema, sourcemeta::blaze::schema_walker,
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        },
        dialect_identifier);
    const auto timestamp_end{std::chrono::steady_clock::now()};

    const auto extension_bytes{make_dialect_extension(dialect_identifier)};
    sourcemeta::one::metapack_write_pretty_json(
        action.destination, schema, "application/schema+json",
        sourcemeta::one::MetapackEncoding::GZIP,
        std::span<const std::uint8_t>{extension_bytes},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }
};

static auto generate_blaze_template(
    const std::filesystem::path &destination,
    const sourcemeta::one::BuildPlan::Action::Dependencies &dependencies,
    const sourcemeta::one::BuildDynamicCallback &callback,
    sourcemeta::one::Resolver &resolver, const sourcemeta::blaze::Mode mode)
    -> void {
  const auto timestamp_start{std::chrono::steady_clock::now()};
  const auto contents_option{
      sourcemeta::one::metapack_read_json(dependencies.front())};
  assert(contents_option.has_value());
  const auto &contents{contents_option.value()};
  const sourcemeta::blaze::SchemaFrame frame{
      sourcemeta::blaze::SchemaFrame::Mode::References, contents,
      sourcemeta::blaze::schema_walker,
      [&callback, &resolver](const auto identifier) {
        return resolver(identifier, callback);
      }};
  const auto schema_template{sourcemeta::blaze::compile(
      contents, sourcemeta::blaze::schema_walker,
      [&callback, &resolver](const auto identifier) {
        return resolver(identifier, callback);
      },
      sourcemeta::blaze::default_schema_compiler, frame, frame.root(), mode)};
  const auto result{sourcemeta::blaze::to_json(schema_template)};
  const auto timestamp_end{std::chrono::steady_clock::now()};
  sourcemeta::one::metapack_write_json(
      destination, result, "application/json",
      sourcemeta::one::MetapackEncoding::GZIP, {},
      std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                            timestamp_start));
}

struct GenerateBlazeTemplateExhaustive {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &callback,
                      sourcemeta::one::Resolver &resolver,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    generate_blaze_template(action.destination, action.dependencies, callback,
                            resolver, sourcemeta::blaze::Mode::Exhaustive);
  }
};

struct GenerateBlazeTemplateFast {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &callback,
                      sourcemeta::one::Resolver &resolver,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    generate_blaze_template(action.destination, action.dependencies, callback,
                            resolver, sourcemeta::blaze::Mode::FastValidation);
  }
};

struct GenerateStats {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &callback,
                      sourcemeta::one::Resolver &resolver,
                      const sourcemeta::one::Configuration &,
                      const sourcemeta::core::JSON &) -> void {
    const auto timestamp_start{std::chrono::steady_clock::now()};
    const auto schema_option{
        sourcemeta::one::metapack_read_json(action.dependencies.front())};
    assert(schema_option.has_value());
    const auto &schema{schema_option.value()};
    std::map<sourcemeta::core::JSON::String,
             std::map<sourcemeta::core::JSON::String, std::uint64_t>>
        result;
    const sourcemeta::blaze::SchemaResolver schema_resolver{
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        }};
    const sourcemeta::blaze::SchemaFrame frame{
        sourcemeta::blaze::SchemaFrame::Mode::Locations, schema,
        sourcemeta::blaze::schema_walker, schema_resolver};

    // A subschema is located once for every URI that reaches it, and what is
    // counted here is the keywords it holds rather than the names it answers
    // to, so each one is counted once however many ways there are to ask for it
    std::unordered_set<sourcemeta::core::Pointer,
                       sourcemeta::core::Pointer::Hasher>
        visited;
    frame.for_each_subschema(
        [&frame, &schema, &schema_resolver, &result, &visited](
            const sourcemeta::blaze::SchemaFrame::Location &location) -> void {
          const auto [pointer, inserted]{
              visited.insert(sourcemeta::core::to_pointer(location.pointer))};
          if (!inserted) {
            return;
          }

          const auto &subschema{sourcemeta::core::get(schema, *pointer)};
          if (!subschema.is_object()) {
            return;
          }

          const auto &vocabularies{
              frame.vocabularies(location, schema_resolver)};
          for (const auto &property : subschema.as_object()) {
            const auto &walker_result{
                sourcemeta::blaze::schema_walker(property.first, vocabularies)};
            result[vocabulary_name(walker_result)][property.first] += 1;
          }
        });

    const auto timestamp_end{std::chrono::steady_clock::now()};
    sourcemeta::one::metapack_write_pretty_json(
        action.destination, sourcemeta::core::to_json(result),
        "application/json", sourcemeta::one::MetapackEncoding::GZIP, {},
        std::chrono::duration_cast<std::chrono::milliseconds>(timestamp_end -
                                                              timestamp_start));
  }
};

struct GenerateURITemplateRoutes {
  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &,
                      sourcemeta::one::Resolver &,
                      const sourcemeta::one::Configuration &configuration,
                      const sourcemeta::core::JSON &) -> void {
    sourcemeta::core::URITemplateRouter router{{}, configuration.url};

    constexpr std::string_view LIST_SCHEMA{
        "/self/v1/schemas/api/list/response"};
    constexpr std::string_view DEPENDENCIES_SCHEMA{
        "/self/v1/schemas/api/schemas/dependencies/response"};
    constexpr std::string_view DEPENDENTS_SCHEMA{
        "/self/v1/schemas/api/schemas/dependents/response"};
    constexpr std::string_view HEALTH_SCHEMA{
        "/self/v1/schemas/api/schemas/health/response"};
    constexpr std::string_view LOCATIONS_SCHEMA{
        "/self/v1/schemas/api/schemas/locations/response"};
    constexpr std::string_view POSITIONS_SCHEMA{
        "/self/v1/schemas/api/schemas/positions/response"};
    constexpr std::string_view STATS_SCHEMA{
        "/self/v1/schemas/api/schemas/stats/response"};
    constexpr std::string_view METADATA_SCHEMA{
        "/self/v1/schemas/api/schemas/metadata/response"};
    constexpr std::string_view EVALUATE_REQUEST_SCHEMA{
        "/self/v1/schemas/api/schemas/evaluate/request"};
    constexpr std::string_view EVALUATE_RESPONSE_SCHEMA{
        "/self/v1/schemas/api/schemas/evaluate/response"};
    constexpr std::string_view RDF_REQUEST_SCHEMA{
        "/self/v1/schemas/api/schemas/rdf/request"};
    constexpr std::string_view RDF_RESPONSE_SCHEMA{
        "/self/v1/schemas/api/schemas/rdf/response"};
    constexpr std::string_view TRACE_REQUEST_SCHEMA{
        "/self/v1/schemas/api/schemas/trace/request"};
    constexpr std::string_view PLAYGROUND_SCHEMA_TRACE_REQUEST_SCHEMA{
        "/self/v1/schemas/api/playground/schemas/trace/request"};
    constexpr std::string_view PLAYGROUND_SCHEMA_TRACE_RESPONSE_SCHEMA{
        "/self/v1/schemas/api/playground/schemas/trace/response"};
    constexpr std::string_view TRACE_RESPONSE_SCHEMA{
        "/self/v1/schemas/api/schemas/trace/response"};
    constexpr std::string_view SEARCH_RESPONSE_SCHEMA{
        "/self/v1/schemas/api/schemas/search/response"};
    constexpr std::string_view AUTH_LOGIN_PAGE_RESPONSE_SCHEMA{
        "/self/v1/schemas/api/auth/login/response"};
    constexpr std::string_view LIST_DIRECTORY_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/list-directory/request"};
    constexpr std::string_view LIST_DIRECTORY_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/list-directory/response"};
    constexpr std::string_view GET_SCHEMA_DEPENDENCIES_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-dependencies/request"};
    constexpr std::string_view GET_SCHEMA_DEPENDENCIES_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-dependencies/response"};
    constexpr std::string_view GET_SCHEMA_DEPENDENTS_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-dependents/request"};
    constexpr std::string_view GET_SCHEMA_DEPENDENTS_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-dependents/response"};
    constexpr std::string_view GET_SCHEMA_HEALTH_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-health/request"};
    constexpr std::string_view GET_SCHEMA_HEALTH_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-health/response"};
    constexpr std::string_view GET_SCHEMA_LOCATIONS_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-locations/request"};
    constexpr std::string_view GET_SCHEMA_LOCATIONS_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-locations/response"};
    constexpr std::string_view GET_SCHEMA_POSITIONS_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-positions/request"};
    constexpr std::string_view GET_SCHEMA_POSITIONS_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-positions/response"};
    constexpr std::string_view GET_SCHEMA_STATS_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-stats/request"};
    constexpr std::string_view GET_SCHEMA_STATS_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-stats/response"};
    constexpr std::string_view GET_SCHEMA_METADATA_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-metadata/request"};
    constexpr std::string_view GET_SCHEMA_METADATA_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/get-schema-metadata/response"};
    constexpr std::string_view EVALUATE_SCHEMA_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/evaluate-schema/request"};
    constexpr std::string_view EVALUATE_SCHEMA_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/evaluate-schema/response"};
    constexpr std::string_view INSTANCE_TO_RDF_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/instance-to-rdf/request"};
    constexpr std::string_view INSTANCE_TO_RDF_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/instance-to-rdf/response"};
    constexpr std::string_view TRACE_SCHEMA_EVALUATION_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"};
    constexpr std::string_view TRACE_SCHEMA_EVALUATION_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"};
    constexpr std::string_view SEARCH_SCHEMAS_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/search-schemas/request"};
    constexpr std::string_view SEARCH_SCHEMAS_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/tools/call/search-schemas/response"};
    constexpr std::string_view ERROR_SCHEMA{"/self/v1/schemas/api/error"};
    constexpr std::string_view MCP_REQUEST_SCHEMA{
        "/self/v1/schemas/mcp/request"};
    constexpr std::string_view MCP_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/response"};
    constexpr std::string_view MCP_PROTECTED_RESOURCE_METADATA_RESPONSE_SCHEMA{
        "/self/v1/schemas/mcp/prm/response"};

    sourcemeta::core::URITemplateRouter::Identifier next_id{1};

    if (configuration.api) {
      const auto otherwise_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.otherwise(sourcemeta::one::ACTION_TYPE_DEFAULT_V1,
                       otherwise_arguments);

      const auto list_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema", std::string_view{LIST_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{LIST_DIRECTORY_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{LIST_DIRECTORY_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_LIST_DIRECTORY, "list_directory",
                 next_id++, sourcemeta::one::ACTION_TYPE_LIST_DIRECTORY_V1,
                 list_arguments);

      const auto dependencies_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema", std::string_view{DEPENDENCIES_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{GET_SCHEMA_DEPENDENCIES_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{GET_SCHEMA_DEPENDENCIES_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_DEPENDENCIES,
                 "get_schema_dependencies", next_id++,
                 sourcemeta::one::ACTION_TYPE_GET_SCHEMA_DEPENDENCIES_V1,
                 dependencies_arguments);

      const auto dependents_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema", std::string_view{DEPENDENTS_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{GET_SCHEMA_DEPENDENTS_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{GET_SCHEMA_DEPENDENTS_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_DEPENDENTS,
                 "get_schema_dependents", next_id++,
                 sourcemeta::one::ACTION_TYPE_GET_SCHEMA_DEPENDENTS_V1,
                 dependents_arguments);

      const auto health_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema", std::string_view{HEALTH_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{GET_SCHEMA_HEALTH_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{GET_SCHEMA_HEALTH_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_HEALTH, "get_schema_health",
                 next_id++, sourcemeta::one::ACTION_TYPE_GET_SCHEMA_HEALTH_V1,
                 health_arguments);

      const auto locations_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema", std::string_view{LOCATIONS_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{GET_SCHEMA_LOCATIONS_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{GET_SCHEMA_LOCATIONS_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_LOCATIONS,
                 "get_schema_locations", next_id++,
                 sourcemeta::one::ACTION_TYPE_GET_SCHEMA_LOCATIONS_V1,
                 locations_arguments);

      const auto positions_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema", std::string_view{POSITIONS_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{GET_SCHEMA_POSITIONS_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{GET_SCHEMA_POSITIONS_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_POSITIONS,
                 "get_schema_positions", next_id++,
                 sourcemeta::one::ACTION_TYPE_GET_SCHEMA_POSITIONS_V1,
                 positions_arguments);

      const auto stats_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema", std::string_view{STATS_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{GET_SCHEMA_STATS_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{GET_SCHEMA_STATS_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_STATS, "get_schema_stats",
                 next_id++, sourcemeta::one::ACTION_TYPE_GET_SCHEMA_STATS_V1,
                 stats_arguments);

      const auto metadata_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema", std::string_view{METADATA_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{GET_SCHEMA_METADATA_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{GET_SCHEMA_METADATA_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_METADATA,
                 "get_schema_metadata", next_id++,
                 sourcemeta::one::ACTION_TYPE_GET_SCHEMA_METADATA_V1,
                 metadata_arguments);

      const auto evaluate_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"requestSchema", std::string_view{EVALUATE_REQUEST_SCHEMA}},
               {"responseSchema", std::string_view{EVALUATE_RESPONSE_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{EVALUATE_SCHEMA_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{EVALUATE_SCHEMA_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_EVALUATE, "evaluate_schema",
                 next_id++, sourcemeta::one::ACTION_TYPE_JSONSCHEMA_EVALUATE_V1,
                 evaluate_arguments);

      const auto rdf_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"requestSchema", std::string_view{RDF_REQUEST_SCHEMA}},
               {"responseSchema", std::string_view{RDF_RESPONSE_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{INSTANCE_TO_RDF_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{INSTANCE_TO_RDF_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_RDF, "instance_to_rdf",
                 next_id++, sourcemeta::one::ACTION_TYPE_JSONSCHEMA_RDF_V1,
                 rdf_arguments);

      const auto trace_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"requestSchema", std::string_view{TRACE_REQUEST_SCHEMA}},
               {"responseSchema", std::string_view{TRACE_RESPONSE_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{TRACE_SCHEMA_EVALUATION_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{TRACE_SCHEMA_EVALUATION_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_TRACE,
                 "trace_schema_evaluation", next_id++,
                 sourcemeta::one::ACTION_TYPE_JSONSCHEMA_TRACE_V1,
                 trace_arguments);

      const auto playground_schema_trace_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"requestSchema",
                std::string_view{PLAYGROUND_SCHEMA_TRACE_REQUEST_SCHEMA}},
               {"responseSchema",
                std::string_view{PLAYGROUND_SCHEMA_TRACE_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_PLAYGROUND_SCHEMA_TRACE,
                 "playground_trace_schema", next_id++,
                 sourcemeta::one::ACTION_TYPE_PLAYGROUND_SCHEMA_TRACE_V1,
                 playground_schema_trace_arguments);

      const auto search_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema", std::string_view{SEARCH_RESPONSE_SCHEMA}},
               {"mcpRequestSchema",
                std::string_view{SEARCH_SCHEMAS_REQUEST_SCHEMA}},
               {"mcpResponseSchema",
                std::string_view{SEARCH_SCHEMAS_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_SCHEMA_SEARCH, "search_schemas",
                 next_id++, sourcemeta::one::ACTION_TYPE_SCHEMA_SEARCH_V1,
                 search_arguments);

      const auto health_check_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_HEALTH, "check_server_health",
                 next_id++, sourcemeta::one::ACTION_TYPE_HEALTH_CHECK_V1,
                 health_check_arguments);

      const auto metrics_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_METRICS, "server_metrics", next_id++,
                 sourcemeta::one::ACTION_TYPE_METRICS_V1, metrics_arguments);

      const auto auth_logout_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_AUTH_LOGOUT, "auth_logout",
                 next_id++, sourcemeta::one::ACTION_TYPE_AUTH_LOGOUT_V1,
                 auth_logout_arguments);

      const auto auth_login_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_AUTH_LOGIN, "auth_login", next_id++,
                 sourcemeta::one::ACTION_TYPE_AUTH_LOGIN_V1,
                 auth_login_arguments);

      const auto auth_callback_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_AUTH_CALLBACK, "auth_callback",
                 next_id++, sourcemeta::one::ACTION_TYPE_AUTH_CALLBACK_V1,
                 auth_callback_arguments);

      const auto mcp_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"requestSchema", std::string_view{MCP_REQUEST_SCHEMA}},
               {"responseSchema", std::string_view{MCP_RESPONSE_SCHEMA}},
               {"metadataPath", sourcemeta::one::ENDPOINT_MCP_PRM}})};
      router.add(sourcemeta::one::ENDPOINT_MCP, "handle_mcp_request", next_id++,
                 sourcemeta::one::ACTION_TYPE_MCP_V1, mcp_arguments);
      router.add(sourcemeta::one::ENDPOINT_MCP_TRAILING_SLASH,
                 "handle_mcp_request_trailing_slash", next_id++,
                 sourcemeta::one::ACTION_TYPE_MCP_V1, mcp_arguments);

      const auto mcp_protected_resource_metadata_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"errorSchema", std::string_view{ERROR_SCHEMA}},
               {"responseSchema",
                std::string_view{
                    MCP_PROTECTED_RESOURCE_METADATA_RESPONSE_SCHEMA}}})};
      router.add(
          sourcemeta::one::ENDPOINT_MCP_PRM, "mcp_protected_resource_metadata",
          next_id++,
          sourcemeta::one::ACTION_TYPE_MCP_PROTECTED_RESOURCE_METADATA_V1,
          mcp_protected_resource_metadata_arguments);
      router.add(
          sourcemeta::one::ENDPOINT_MCP_PRM_TRAILING_SLASH,
          "mcp_protected_resource_metadata_trailing_slash", next_id++,
          sourcemeta::one::ACTION_TYPE_MCP_PROTECTED_RESOURCE_METADATA_V1,
          mcp_protected_resource_metadata_arguments);

      const auto not_found_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_API_NOT_FOUND, "handle_not_found",
                 next_id++, sourcemeta::one::ACTION_TYPE_NOT_FOUND_V1,
                 not_found_arguments);

      const auto auth_login_page_arguments{
          std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
              {{"responseSchema",
                std::string_view{AUTH_LOGIN_PAGE_RESPONSE_SCHEMA}},
               {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
      router.add(sourcemeta::one::ENDPOINT_AUTH_LOGIN_PAGE, "auth_login_page",
                 next_id++, sourcemeta::one::ACTION_TYPE_AUTH_LOGIN_PAGE_V1,
                 auth_login_page_arguments);

      if (action.data == "Full") {
        const auto static_arguments{
            std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
                {{"path", std::string_view{SOURCEMETA_ONE_STATIC}},
                 {"errorSchema", std::string_view{ERROR_SCHEMA}}})};
        router.add(sourcemeta::one::ENDPOINT_STATIC, "serve_static_asset",
                   next_id++, sourcemeta::one::ACTION_TYPE_SERVE_STATIC_V1,
                   static_arguments);
      } else {
        const auto static_arguments{
            std::to_array<sourcemeta::core::URITemplateRouter::Argument>(
                {{"errorSchema", std::string_view{ERROR_SCHEMA}}})};
        router.add(sourcemeta::one::ENDPOINT_STATIC, "serve_static_asset",
                   next_id++, sourcemeta::one::ACTION_TYPE_SERVE_STATIC_V1,
                   static_arguments);
      }
    } else {
      router.otherwise(sourcemeta::one::ACTION_TYPE_DEFAULT_V1);
    }

    std::filesystem::create_directories(action.destination.parent_path());
    sourcemeta::core::URITemplateRouterView::save(router, action.destination);
  }
};

struct GenerateAuthentication {
  // The policies borrow the paths, keys and session secrets they are declared
  // with, so the vectors that hold those must outlive the policies that point
  // into them
  static auto make_policies(
      const sourcemeta::one::Configuration &configuration,
      std::vector<std::vector<std::string_view>> &policy_paths,
      std::vector<std::vector<std::string_view>> &policy_keys,
      std::vector<std::vector<std::string_view>> &policy_session_secrets,
      std::vector<std::string> &policy_claims,
      std::vector<std::vector<std::string_view>> &policy_email_domains)
      -> std::vector<sourcemeta::one::Authentication::Policy> {
    std::vector<sourcemeta::one::Authentication::Policy> policies;
    policies.reserve(configuration.authentication.size());
    policy_paths.reserve(configuration.authentication.size());
    policy_keys.reserve(configuration.authentication.size());
    policy_session_secrets.reserve(configuration.authentication.size());
    // The views a policy carries point into here, so this must not grow while
    // one is held
    policy_claims.reserve(configuration.authentication.size());
    policy_email_domains.reserve(configuration.authentication.size());
    for (const auto &entry : configuration.authentication) {
      std::vector<std::string_view> paths;
      paths.reserve(entry.paths.size());
      for (const auto &path : entry.paths) {
        paths.push_back(path);
      }

      policy_paths.push_back(std::move(paths));

      using Entry = sourcemeta::one::Configuration::AuthenticationEntry;
      if (entry.type == Entry::Type::JWT) {
        // The rules are canonical by the time they arrive, so serialising them
        // is all that is left to do with them
        std::ostringstream claims;
        if (!entry.claims.is_null()) {
          sourcemeta::core::stringify(entry.claims, claims);
        }

        policy_claims.push_back(claims.str());
        policies.push_back(
            {.paths = policy_paths.back(),
             .name = entry.name,
             .credential = sourcemeta::one::Authentication::Policy::Token{
                 .issuer = entry.issuer,
                 .audience = entry.audience,
                 .jwks_uri = entry.jwks_uri.has_value()
                                 ? std::string_view{entry.jwks_uri.value()}
                                 : std::string_view{},
                 .algorithms = entry.algorithms,
                 .token_type = entry.token_type,
                 .claims = policy_claims.back()}});
      } else if (entry.type == Entry::Type::OIDC) {
        std::vector<std::string_view> session_secrets;
        session_secrets.reserve(entry.session_secret_variables.size());
        for (const auto &variable : entry.session_secret_variables) {
          session_secrets.push_back(variable);
        }

        policy_session_secrets.push_back(std::move(session_secrets));

        std::ostringstream claims;
        if (!entry.claims.is_null()) {
          sourcemeta::core::stringify(entry.claims, claims);
        }

        policy_claims.push_back(claims.str());

        std::vector<std::string_view> domains;
        domains.reserve(entry.email_domains.size());
        for (const auto &domain : entry.email_domains) {
          domains.push_back(domain);
        }

        policy_email_domains.push_back(std::move(domains));
        policies.push_back(
            {.paths = policy_paths.back(),
             .name = entry.name,
             .credential = sourcemeta::one::Authentication::Policy::Interactive{
                 .issuer = entry.issuer,
                 .client_id = entry.client_id,
                 .client_secret_variable = entry.client_secret_variable,
                 .claims = policy_claims.back(),
                 .email_domains = policy_email_domains.back(),
                 .session_secrets = policy_session_secrets.back()}});
      } else {
        std::vector<std::string_view> keys;
        keys.reserve(entry.keys.size());
        for (const auto &key : entry.keys) {
          keys.push_back(key);
        }

        policy_keys.push_back(std::move(keys));
        const auto algorithm{
            entry.algorithm == Entry::Algorithm::Sha256
                ? sourcemeta::one::Authentication::Algorithm::Sha256
                : sourcemeta::one::Authentication::Algorithm::Identity};
        policies.push_back(
            {.paths = policy_paths.back(),
             .name = entry.name,
             .credential = sourcemeta::one::Authentication::Policy::ApiKey{
                 .keys = policy_keys.back(), .algorithm = algorithm}});
      }
    }

    return policies;
  }

  static auto handler(const sourcemeta::one::BuildState &,
                      const sourcemeta::one::BuildPlan::Action &action,
                      const sourcemeta::one::BuildDynamicCallback &,
                      sourcemeta::one::Resolver &,
                      const sourcemeta::one::Configuration &configuration,
                      const sourcemeta::core::JSON &) -> void {
    const sourcemeta::core::URITemplateRouterView routes{
        action.dependencies.at(0)};
    std::vector<std::vector<std::string_view>> policy_paths;
    std::vector<std::vector<std::string_view>> policy_keys;
    std::vector<std::vector<std::string_view>> policy_session_secrets;
    std::vector<std::string> policy_claims;
    std::vector<std::vector<std::string_view>> policy_email_domains;
    const auto policies{make_policies(configuration, policy_paths, policy_keys,
                                      policy_session_secrets, policy_claims,
                                      policy_email_domains)};

    // A policy gates a route or a declared collection or page (or a namespace
    // above one), never a path inside a collection. A route is named where it
    // begins rather than at some expansion of it: a scope reaching into a
    // template would be honoured where the route is matched literally and
    // nowhere else, which is a gate that holds on one surface and not the next
    sourcemeta::one::Authentication::Table::write(
        sourcemeta::one::Authentication::Table::compile(
            policies, configuration.path,
            [&routes, &configuration](const std::string_view path) {
              for (std::size_t index{0}; index < routes.size(); index++) {
                const auto route{routes.path(routes.at(index))};
                const auto scope{sourcemeta::one::route_scope(route)};
                if (scope == path ||
                    (scope.size() > path.size() && scope.starts_with(path) &&
                     scope[path.size()] == '/')) {
                  return true;
                }
              }

              return configuration.covers_entry(path);
            }),
        action.destination);
  }
};

} // namespace sourcemeta::one

#endif
