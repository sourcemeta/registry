#ifndef SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_
#define SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_

// TODO: These are the only rules that in theory we should be able
// to reload as needed based on user changes

#include <sourcemeta/registry/metapack.h>
#include <sourcemeta/registry/resolver.h>

#include <sourcemeta/core/alterschema.h>

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>
#include <sourcemeta/core/jsonschema.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>
#include <sourcemeta/blaze/linter.h>

#include <cassert>    // assert
#include <chrono>     // std::chrono
#include <filesystem> // std::filesystem
#include <sstream>    // std::stringstream
#include <utility>    // std::move
#include <vector>     // std::vector

using PathCallback = std::function<void(const std::filesystem::path &)>;

template <typename Context>
using Handler = std::function<void(const std::filesystem::path &,
                                   const std::vector<std::filesystem::path> &,
                                   const PathCallback &, const Context &)>;

template <typename Context>
auto build(const Handler<Context> &handler, const PathCallback &tracker,
           const std::filesystem::path &destination,
           const std::filesystem::path &deps_path,
           const std::vector<std::filesystem::path> &dependencies,
           const Context &context) -> bool {
  if (std::filesystem::exists(deps_path) &&
      std::filesystem::exists(destination)) {
    const auto deps{sourcemeta::core::read_json(deps_path)};
    assert(deps.is_array());
    assert(!deps.empty());
    bool must_rebuild{false};
    const auto destination_last_write_time{
        std::filesystem::last_write_time(destination)};

    for (const auto &entry : deps.as_array()) {
      if (!std::filesystem::exists(entry.to_string()) ||
          std::filesystem::last_write_time(entry.to_string()) >
              destination_last_write_time) {
        must_rebuild = true;
        break;
      }
    }

    if (!must_rebuild) {
      tracker(deps_path);
      tracker(destination);
      return false;
    }
  }

  auto deps = sourcemeta::core::JSON::make_array();
  for (const auto &dependency : dependencies) {
    assert(std::filesystem::exists(dependency));
    deps.push_back(sourcemeta::core::JSON{dependency.string()});
  }

  std::filesystem::create_directories(destination.parent_path());
  handler(
      destination, dependencies,
      [&deps](const auto &new_dependency) {
        assert(std::filesystem::exists(new_dependency));
        deps.push_back(sourcemeta::core::JSON{new_dependency});
      },
      context);
  assert(std::filesystem::exists(destination));
  tracker(destination);

  std::filesystem::create_directories(deps_path.parent_path());
  std::ofstream deps_stream{deps_path};
  assert(!deps_stream.fail());
  sourcemeta::core::stringify(deps, deps_stream);
  tracker(deps_path);

  return true;
}

namespace sourcemeta::registry {

auto GENERATE_MATERIALISED_SCHEMA(const std::filesystem::path &destination,
                                  const std::vector<std::filesystem::path> &,
                                  const PathCallback &,
                                  const sourcemeta::core::JSON &schema)
    -> void {
  const auto dialect_identifier{sourcemeta::core::dialect(schema)};
  assert(dialect_identifier.has_value());
  sourcemeta::registry::write_stream(
      destination, "application/schema+json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{dialect_identifier.value()},
      [&schema](auto &stream) {
        sourcemeta::core::prettify(schema, stream,
                                   sourcemeta::core::schema_format_compare);
      });
}

auto GENERATE_POINTER_POSITIONS(
    const std::filesystem::path &destination,
    const std::vector<std::filesystem::path> &dependencies,
    const PathCallback &, const sourcemeta::registry::Resolver &) -> void {
  assert(dependencies.size() == 1);
  sourcemeta::core::PointerPositionTracker tracker;
  auto contents{sourcemeta::registry::read_contents(dependencies.front())};
  assert(contents.has_value());
  sourcemeta::core::parse_json(contents.value().data, std::ref(tracker));
  const auto result{sourcemeta::core::to_json(tracker)};
  sourcemeta::registry::write_stream(
      destination, "application/json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{nullptr},
      [&result](auto &stream) { sourcemeta::core::stringify(result, stream); });
}

auto GENERATE_FRAME_LOCATIONS(
    const std::filesystem::path &destination,
    const std::vector<std::filesystem::path> &dependencies,
    const PathCallback &callback,
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
  sourcemeta::registry::write_stream(
      destination, "application/json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{nullptr},
      [&result](auto &stream) { sourcemeta::core::stringify(result, stream); });
}

auto GENERATE_DEPENDENCIES(
    const std::filesystem::path &destination,
    const std::vector<std::filesystem::path> &dependencies,
    const PathCallback &callback,
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

  sourcemeta::registry::write_stream(
      destination, "application/json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{nullptr},
      [&result](auto &stream) { sourcemeta::core::stringify(result, stream); });
}

auto GENERATE_HEALTH(const std::filesystem::path &destination,
                     const std::vector<std::filesystem::path> &dependencies,
                     const PathCallback &callback,
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

  sourcemeta::registry::write_stream(
      destination, "application/json",
      sourcemeta::registry::MetaPackEncoding::GZIP,
      sourcemeta::core::JSON{nullptr},
      [&report](auto &stream) { sourcemeta::core::stringify(report, stream); });
}

auto GENERATE_BUNDLE(const std::filesystem::path &destination,
                     const std::vector<std::filesystem::path> &dependencies,
                     const PathCallback &callback,
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
    const std::vector<std::filesystem::path> &dependencies,
    const PathCallback &callback,
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
    const std::vector<std::filesystem::path> &dependencies,
    const PathCallback &, const sourcemeta::registry::Resolver &) -> void {
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
  sourcemeta::registry::write_stream(
      destination, "application/json",
      // Don't compress, as we need to internally read from disk
      sourcemeta::registry::MetaPackEncoding::Identity,
      sourcemeta::core::JSON{nullptr},
      [&result](auto &stream) { sourcemeta::core::stringify(result, stream); });
}

} // namespace sourcemeta::registry

#endif
