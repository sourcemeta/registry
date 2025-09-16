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

#include "validator.h"

#include <cassert>    // assert
#include <filesystem> // std::filesystem
#include <utility>    // std::move

namespace sourcemeta::registry {

auto GENERATE_MATERIALISED_SCHEMA(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path> &,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const std::tuple<std::string_view,
                     std::reference_wrapper<sourcemeta::registry::Validator>,
                     std::reference_wrapper<sourcemeta::registry::Resolver>>
        &data) -> void {
  const auto schema{std::get<2>(data).get()(std::get<0>(data))};
  assert(schema.has_value());
  const auto dialect_identifier{sourcemeta::core::dialect(schema.value())};
  assert(dialect_identifier.has_value());
  const auto metaschema{std::get<2>(data).get()(dialect_identifier.value())};
  assert(metaschema.has_value());
  std::get<1>(data).get().validate_or_throw(
      dialect_identifier.value(), metaschema.value(), schema.value(),
      "The schema does not adhere to its metaschema");

  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_pretty_json(
      destination, schema.value(), "application/schema+json",
      sourcemeta::registry::Encoding::GZIP,
      sourcemeta::core::JSON{dialect_identifier.value()},
      sourcemeta::core::schema_format_compare);
}

auto GENERATE_POINTER_POSITIONS(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const sourcemeta::registry::Resolver &) -> void {
  sourcemeta::core::PointerPositionTracker tracker;
  sourcemeta::registry::read_json(dependencies.front(), std::ref(tracker));
  const auto result{sourcemeta::core::to_json(tracker)};
  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_pretty_json(
      destination, result, "application/json",
      sourcemeta::registry::Encoding::GZIP, sourcemeta::core::JSON{nullptr});
}

auto GENERATE_FRAME_LOCATIONS(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
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

auto GENERATE_DEPENDENCIES(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
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

auto GENERATE_HEALTH(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
  const auto contents{sourcemeta::registry::read_json(dependencies.front())};

  sourcemeta::core::SchemaTransformer bundle;
  sourcemeta::core::add(bundle, sourcemeta::core::AlterSchemaMode::Readability);
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

auto GENERATE_BUNDLE(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
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

auto GENERATE_UNIDENTIFIED(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
  auto schema{sourcemeta::registry::read_json(dependencies.front())};
  sourcemeta::core::for_editor(schema, sourcemeta::core::schema_official_walker,
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

auto GENERATE_BLAZE_TEMPLATE_EXHAUSTIVE(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const sourcemeta::registry::Resolver &) -> void {
  const auto contents{sourcemeta::registry::read_json(dependencies.front())};
  const auto schema_template{sourcemeta::blaze::compile(
      contents, sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::blaze::default_schema_compiler,
      sourcemeta::blaze::Mode::Exhaustive)};
  const auto result{sourcemeta::blaze::to_json(schema_template)};
  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_json(
      destination, result, "application/json",
      // Don't compress, as we only need to internally read from disk
      sourcemeta::registry::Encoding::Identity,
      sourcemeta::core::JSON{nullptr});
}

auto GENERATE_MARKER(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path> &,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const sourcemeta::core::JSON &value) -> void {
  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_pretty_json(
      destination, value, "application/json",
      sourcemeta::registry::Encoding::Identity,
      sourcemeta::core::JSON{nullptr});
}

} // namespace sourcemeta::registry

#endif
