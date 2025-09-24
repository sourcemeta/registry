#ifndef SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_
#define SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_

#include <sourcemeta/registry/resolver.h>
#include <sourcemeta/registry/shared.h>

#include <sourcemeta/core/alterschema.h>
#include <sourcemeta/core/build.h>
#include <sourcemeta/core/editorschema.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>
#include <sourcemeta/core/jsonschema.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>
#include <sourcemeta/blaze/linter.h>

#include <cassert>    // assert
#include <filesystem> // std::filesystem
#include <utility>    // std::move

namespace sourcemeta::registry {

// TODO: Use this struct pattern for the other generators
struct GENERATE_MATERIALISED_SCHEMA {
  using Context =
      std::pair<std::string_view,
                std::reference_wrapper<sourcemeta::registry::Resolver>>;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path> &,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
          const Context &data) -> void {
    const auto schema{data.second.get()(data.first)};
    assert(schema.has_value());
    const auto dialect_identifier{sourcemeta::core::dialect(schema.value())};
    assert(dialect_identifier.has_value());
    const auto metaschema{data.second.get()(dialect_identifier.value())};
    assert(metaschema.has_value());

    // Validate the schemas against their meta-schemas
    sourcemeta::blaze::SimpleOutput output{schema.value()};
    sourcemeta::blaze::Evaluator evaluator;
    const auto result{evaluator.validate(
        GENERATE_MATERIALISED_SCHEMA::compile(dialect_identifier.value(),
                                              metaschema.value(), data.second),
        schema.value(), std::ref(output))};
    if (!result) {
      throw MetaschemaError(output);
    }

    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, schema.value(), "application/schema+json",
        sourcemeta::registry::Encoding::GZIP,
        sourcemeta::core::JSON{dialect_identifier.value()},
        sourcemeta::core::schema_format_compare);
  }

  class MetaschemaError : public std::exception {
  public:
    MetaschemaError(const sourcemeta::blaze::SimpleOutput &output) {
      std::ostringstream stream;
      output.stacktrace(stream);
      this->stacktrace_ = stream.str();
    }

    [[nodiscard]] auto what() const noexcept -> const char * {
      return "The schema does not adhere to its metaschema";
    }

    [[nodiscard]] auto stacktrace() const noexcept -> const std::string & {
      return stacktrace_;
    }

  private:
    std::string stacktrace_;
  };

private:
  static auto compile(const std::string &cache_key,
                      const sourcemeta::core::JSON &schema,
                      const sourcemeta::registry::Resolver &resolver)
      -> const sourcemeta::blaze::Template & {
    static std::mutex mutex;
    static std::unordered_map<std::string, sourcemeta::blaze::Template> cache;
    std::lock_guard<std::mutex> lock{mutex};
    const auto match{cache.find(cache_key)};
    if (match == cache.cend()) {
      auto schema_template{sourcemeta::blaze::compile(
          schema, sourcemeta::core::schema_official_walker,
          [&resolver](const auto identifier) { return resolver(identifier); },
          sourcemeta::blaze::default_schema_compiler,
          // The point of this class is to show nice errors to the user
          sourcemeta::blaze::Mode::Exhaustive)};
      return cache.emplace(cache_key, std::move(schema_template)).first->second;
    } else {
      return match->second;
    }
  }
};

struct GENERATE_MARKER {
  using Context = sourcemeta::registry::Resolver;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path> &,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
          const Context &) -> void {
    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, sourcemeta::core::JSON{true}, "application/json",
        sourcemeta::registry::Encoding::Identity,
        sourcemeta::core::JSON{nullptr});
  }
};

struct GENERATE_POINTER_POSITIONS {
  using Context = sourcemeta::registry::Resolver;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
          const Context &) -> void {
    sourcemeta::core::PointerPositionTracker tracker;
    sourcemeta::registry::read_json(dependencies.front(), std::ref(tracker));
    const auto result{sourcemeta::core::to_json(tracker)};
    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, result, "application/json",
        sourcemeta::registry::Encoding::GZIP, sourcemeta::core::JSON{nullptr});
  }
};

struct GENERATE_FRAME_LOCATIONS {
  using Context = sourcemeta::registry::Resolver;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
              &callback,
          const Context &resolver) -> void {
    const auto contents{sourcemeta::registry::read_json(dependencies.front())};
    sourcemeta::core::SchemaFrame frame{
        sourcemeta::core::SchemaFrame::Mode::Locations};
    frame.analyse(contents, sourcemeta::core::schema_official_walker,
                  [&callback, &resolver](const auto identifier) {
                    return resolver(identifier, callback);
                  });
    const auto result{frame.to_json().at("locations")};
    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, result, "application/json",
        sourcemeta::registry::Encoding::GZIP, sourcemeta::core::JSON{nullptr});
  }
};

struct GENERATE_DEPENDENCIES {
  using Context = sourcemeta::registry::Resolver;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
              &callback,
          const Context &resolver) -> void {
    const auto contents{sourcemeta::registry::read_json(dependencies.front())};
    auto result{sourcemeta::core::JSON::make_array()};
    sourcemeta::core::dependencies(
        contents, sourcemeta::core::schema_official_walker,
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        },
        [&result](const auto &origin, const auto &pointer, const auto &target,
                  const auto &) {
          auto trace{sourcemeta::core::JSON::make_object()};
          trace.assign("from", sourcemeta::core::to_json(origin));
          trace.assign("to", sourcemeta::core::to_json(target));
          trace.assign("at", sourcemeta::core::to_json(pointer));
          result.push_back(std::move(trace));
        });

    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, result, "application/json",
        sourcemeta::registry::Encoding::GZIP, sourcemeta::core::JSON{nullptr});
  }
};

struct GENERATE_HEALTH {
  using Context = sourcemeta::registry::Resolver;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
              &callback,
          const Context &resolver) -> void {
    const auto contents{sourcemeta::registry::read_json(dependencies.front())};

    sourcemeta::core::SchemaTransformer bundle;
    sourcemeta::core::add(bundle,
                          sourcemeta::core::AlterSchemaMode::Readability);
    bundle.add<sourcemeta::blaze::ValidExamples>(
        sourcemeta::blaze::default_schema_compiler);
    bundle.add<sourcemeta::blaze::ValidDefault>(
        sourcemeta::blaze::default_schema_compiler);

    auto errors{sourcemeta::core::JSON::make_array()};
    const auto result = bundle.check(
        contents, sourcemeta::core::schema_official_walker,
        [&callback, &resolver](const auto identifier) {
          return resolver(identifier, callback);
        },
        [&errors](const auto &pointer, const auto &name, const auto &message,
                  const auto &outcome) {
          auto entry{sourcemeta::core::JSON::make_object()};
          entry.assign("name", sourcemeta::core::JSON{name});
          entry.assign("message", sourcemeta::core::JSON{message});
          entry.assign("description",
                       sourcemeta::core::to_json(outcome.description));

          auto pointers{sourcemeta::core::JSON::make_array()};
          if (outcome.locations.empty()) {
            pointers.push_back(sourcemeta::core::to_json(pointer));
          } else {
            for (const auto &location : outcome.locations) {
              pointers.push_back(
                  sourcemeta::core::to_json(pointer.concat(location)));
            }
          }

          entry.assign("pointers", std::move(pointers));
          errors.push_back(std::move(entry));
        });

    auto report{sourcemeta::core::JSON::make_object()};
    report.assign("score", sourcemeta::core::to_json(result.second));
    report.assign("errors", std::move(errors));

    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, report, "application/json",
        sourcemeta::registry::Encoding::GZIP, sourcemeta::core::JSON{nullptr});
  }
};

struct GENERATE_BUNDLE {
  using Context = sourcemeta::registry::Resolver;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
              &callback,
          const Context &resolver) -> void {
    auto schema{sourcemeta::registry::read_json(dependencies.front())};
    sourcemeta::core::bundle(schema, sourcemeta::core::schema_official_walker,
                             [&callback, &resolver](const auto identifier) {
                               return resolver(identifier, callback);
                             });
    const auto dialect_identifier{sourcemeta::core::dialect(schema)};
    assert(dialect_identifier.has_value());
    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, schema, "application/schema+json",
        sourcemeta::registry::Encoding::GZIP,
        sourcemeta::core::JSON{dialect_identifier.value()},
        sourcemeta::core::schema_format_compare);
  }
};

struct GENERATE_EDITOR {
  using Context = sourcemeta::registry::Resolver;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
              &callback,
          const Context &resolver) -> void {
    auto schema{sourcemeta::registry::read_json(dependencies.front())};
    sourcemeta::core::for_editor(schema,
                                 sourcemeta::core::schema_official_walker,
                                 [&callback, &resolver](const auto identifier) {
                                   return resolver(identifier, callback);
                                 });
    const auto dialect_identifier{sourcemeta::core::dialect(schema)};
    assert(dialect_identifier.has_value());
    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_pretty_json(
        destination, schema, "application/schema+json",
        sourcemeta::registry::Encoding::GZIP,
        sourcemeta::core::JSON{dialect_identifier.value()},
        sourcemeta::core::schema_format_compare);
  }
};

struct GENERATE_BLAZE_TEMPLATE {
  using Context = sourcemeta::blaze::Mode;
  static auto
  handler(const std::filesystem::path &destination,
          const sourcemeta::core::BuildDependencies<std::filesystem::path>
              &dependencies,
          const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
          const Context &mode) -> void {
    const auto contents{sourcemeta::registry::read_json(dependencies.front())};
    const auto schema_template{sourcemeta::blaze::compile(
        contents, sourcemeta::core::schema_official_walker,
        sourcemeta::core::schema_official_resolver,
        sourcemeta::blaze::default_schema_compiler, mode)};
    const auto result{sourcemeta::blaze::to_json(schema_template)};
    std::filesystem::create_directories(destination.parent_path());
    sourcemeta::registry::write_json(
        destination, result, "application/json",
        // Don't compress, as we only need to internally read from disk
        sourcemeta::registry::Encoding::Identity,
        sourcemeta::core::JSON{nullptr});
  }
};

} // namespace sourcemeta::registry

#endif
