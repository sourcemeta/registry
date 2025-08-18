#ifndef SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_
#define SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_

#include <sourcemeta/registry/metapack.h>
#include <sourcemeta/registry/resolver.h>

#include <sourcemeta/core/alterschema.h>
#include <sourcemeta/core/build.h>
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
  sourcemeta::registry::write_stream(
      destination, "application/schema+json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{dialect_identifier.value()},
      [&schema](auto &stream) {
        sourcemeta::core::prettify(schema.value(), stream,
                                   sourcemeta::core::schema_format_compare);
      });
}

auto GENERATE_POINTER_POSITIONS(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const sourcemeta::registry::Resolver &) -> void {
  assert(dependencies.size() == 1);
  sourcemeta::core::PointerPositionTracker tracker;
  auto contents{sourcemeta::registry::read_contents(dependencies.front())};
  assert(contents.has_value());
  sourcemeta::core::parse_json(contents.value().data, std::ref(tracker));
  const auto result{sourcemeta::core::to_json(tracker)};
  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_stream(
      destination, "application/json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{nullptr},
      [&result](auto &stream) { sourcemeta::core::prettify(result, stream); });
}

auto GENERATE_FRAME_LOCATIONS(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
  assert(dependencies.size() == 1);
  auto contents{sourcemeta::registry::read_contents(dependencies.front())};
  assert(contents.has_value());
  sourcemeta::core::SchemaFrame frame{
      sourcemeta::core::SchemaFrame::Mode::Locations};
  frame.analyse(sourcemeta::core::parse_json(contents.value().data),
                sourcemeta::core::schema_official_walker,
                [&callback, &resolver](const auto identifier) {
                  return resolver(identifier, callback);
                });
  const auto result{frame.to_json().at("locations")};
  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_stream(
      destination, "application/json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{nullptr},
      [&result](auto &stream) { sourcemeta::core::prettify(result, stream); });
}

auto GENERATE_DEPENDENCIES(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
  assert(dependencies.size() == 1);
  auto contents{sourcemeta::registry::read_contents(dependencies.front())};
  assert(contents.has_value());
  auto result{sourcemeta::core::JSON::make_array()};
  sourcemeta::core::dependencies(
      sourcemeta::core::parse_json(contents.value().data),
      sourcemeta::core::schema_official_walker,
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
  sourcemeta::registry::write_stream(
      destination, "application/json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{nullptr},
      [&result](auto &stream) { sourcemeta::core::prettify(result, stream); });
}

auto GENERATE_HEALTH(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
  assert(dependencies.size() == 2);
  auto contents{sourcemeta::registry::read_contents(dependencies.front())};
  assert(contents.has_value());

  sourcemeta::core::SchemaTransformer bundle;
  sourcemeta::core::add(bundle, sourcemeta::core::AlterSchemaMode::Readability);
  bundle.add<sourcemeta::blaze::ValidExamples>(
      sourcemeta::blaze::default_schema_compiler);
  bundle.add<sourcemeta::blaze::ValidDefault>(
      sourcemeta::blaze::default_schema_compiler);

  auto errors{sourcemeta::core::JSON::make_array()};
  const auto result = bundle.check(
      sourcemeta::core::parse_json(contents.value().data),
      sourcemeta::core::schema_official_walker,
      [&callback, &resolver](const auto identifier) {
        return resolver(identifier, callback);
      },
      [&errors](const auto &pointer, const auto &name, const auto &message,
                const auto &description) {
        auto entry{sourcemeta::core::JSON::make_object()};
        entry.assign("pointer", sourcemeta::core::to_json(pointer));
        entry.assign("name", sourcemeta::core::JSON{name});
        entry.assign("message", sourcemeta::core::JSON{message});
        if (description.empty()) {
          entry.assign("description", sourcemeta::core::JSON{nullptr});
        } else {
          entry.assign("description", sourcemeta::core::JSON{description});
        }

        errors.push_back(std::move(entry));
      });

  auto report{sourcemeta::core::JSON::make_object()};
  report.assign("score", sourcemeta::core::to_json(result.second));
  report.assign("errors", std::move(errors));

  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_stream(
      destination, "application/json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{nullptr},
      [&report](auto &stream) { sourcemeta::core::prettify(report, stream); });
}

auto GENERATE_BUNDLE(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
  assert(dependencies.size() == 2);
  auto contents{sourcemeta::registry::read_contents(dependencies.front())};
  assert(contents.has_value());
  auto schema{sourcemeta::core::parse_json(contents.value().data)};
  sourcemeta::core::bundle(schema, sourcemeta::core::schema_official_walker,
                           [&callback, &resolver](const auto identifier) {
                             return resolver(identifier, callback);
                           });
  const auto dialect_identifier{sourcemeta::core::dialect(schema)};
  assert(dialect_identifier.has_value());
  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_stream(
      destination, "application/schema+json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{dialect_identifier.value()},
      [&schema](auto &stream) {
        sourcemeta::core::prettify(schema, stream,
                                   sourcemeta::core::schema_format_compare);
      });
}

auto GENERATE_UNIDENTIFIED(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path>
        &callback,
    const sourcemeta::registry::Resolver &resolver) -> void {
  assert(dependencies.size() == 1);
  auto contents{sourcemeta::registry::read_contents(dependencies.front())};
  assert(contents.has_value());
  auto schema{sourcemeta::core::parse_json(contents.value().data)};
  sourcemeta::core::unidentify(schema, sourcemeta::core::schema_official_walker,
                               [&callback, &resolver](const auto identifier) {
                                 return resolver(identifier, callback);
                               });
  const auto dialect_identifier{sourcemeta::core::dialect(schema)};
  assert(dialect_identifier.has_value());
  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_stream(
      destination, "application/schema+json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{dialect_identifier.value()},
      [&schema](auto &stream) {
        sourcemeta::core::prettify(schema, stream,
                                   sourcemeta::core::schema_format_compare);
      });
}

auto GENERATE_BLAZE_TEMPLATE_EXHAUSTIVE(
    const std::filesystem::path &destination,
    const sourcemeta::core::BuildDependencies<std::filesystem::path>
        &dependencies,
    const sourcemeta::core::BuildDynamicCallback<std::filesystem::path> &,
    const sourcemeta::registry::Resolver &) -> void {
  assert(dependencies.size() == 1);
  auto contents{sourcemeta::registry::read_contents(dependencies.front())};
  assert(contents.has_value());
  const auto schema_template{sourcemeta::blaze::compile(
      sourcemeta::core::parse_json(contents.value().data),
      sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::blaze::default_schema_compiler,
      sourcemeta::blaze::Mode::Exhaustive)};
  const auto result{sourcemeta::blaze::to_json(schema_template)};
  std::filesystem::create_directories(destination.parent_path());
  sourcemeta::registry::write_stream(
      destination, "application/json",
      // Don't compress, as we need to internally read from disk
      sourcemeta::registry::MetaPackEncoding::Identity,
      sourcemeta::core::JSON{nullptr},
      [&result](auto &stream) { sourcemeta::core::stringify(result, stream); });
}

} // namespace sourcemeta::registry

#endif
