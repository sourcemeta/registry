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

// TODO: Elevate all of this to Core
using DependencyCallback = std::function<void(const std::filesystem::path &)>;
template <typename Context, typename Adapter>
auto build(
    Adapter &configuration,
    const std::function<void(const typename Adapter::node_type &,
                             const std::vector<typename Adapter::node_type> &,
                             const DependencyCallback &, const Context &)>
        &handler,
    const typename Adapter::node_type &destination,
    const std::vector<typename Adapter::node_type> &dependencies,
    const Context &context) -> bool {
  const auto destination_mark{configuration.mark(destination)};
  const auto current_deps{configuration.read_dependencies(destination)};
  if (destination_mark.has_value() && current_deps.has_value()) {
    bool outdated{false};
    for (const auto &entry : current_deps.value()) {
      const auto current_mark{
          configuration.mark(configuration.dependency_to_node(entry))};
      if (!current_mark.has_value() ||
          !configuration.is_fresh_against(destination_mark.value(),
                                          current_mark.value())) {
        outdated = true;
        break;
      }
    }

    if (!outdated) {
      return false;
    }
  }

  std::vector<typename Adapter::node_type> deps;
  for (const auto &dependency : dependencies) {
    assert(configuration.mark(dependency).has_value());
    deps.emplace_back(dependency);
  }

  handler(
      destination, dependencies,
      [&deps, &configuration](const auto &new_dependency) {
        assert(configuration.mark(new_dependency).has_value());
        deps.emplace_back(new_dependency);
      },
      context);

  configuration
      .template write_dependencies<std::vector<typename Adapter::node_type>>(
          destination, deps.cbegin(), deps.cend());
  return true;
}

namespace sourcemeta::registry {

auto GENERATE_MATERIALISED_SCHEMA(const std::filesystem::path &destination,
                                  const std::vector<std::filesystem::path> &,
                                  const DependencyCallback &,
                                  const sourcemeta::core::JSON &schema)
    -> void {
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

auto GENERATE_POINTER_POSITIONS(
    const std::filesystem::path &destination,
    const std::vector<std::filesystem::path> &dependencies,
    const DependencyCallback &, const sourcemeta::registry::Resolver &)
    -> void {
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
      [&result](auto &stream) { sourcemeta::core::stringify(result, stream); });
}

auto GENERATE_FRAME_LOCATIONS(
    const std::filesystem::path &destination,
    const std::vector<std::filesystem::path> &dependencies,
    const DependencyCallback &callback,
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
      [&result](auto &stream) { sourcemeta::core::stringify(result, stream); });
}

auto GENERATE_DEPENDENCIES(
    const std::filesystem::path &destination,
    const std::vector<std::filesystem::path> &dependencies,
    const DependencyCallback &callback,
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
      [&result](auto &stream) { sourcemeta::core::stringify(result, stream); });
}

auto GENERATE_HEALTH(const std::filesystem::path &destination,
                     const std::vector<std::filesystem::path> &dependencies,
                     const DependencyCallback &callback,
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
      [&report](auto &stream) { sourcemeta::core::stringify(report, stream); });
}

auto GENERATE_BUNDLE(const std::filesystem::path &destination,
                     const std::vector<std::filesystem::path> &dependencies,
                     const DependencyCallback &callback,
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
    const std::vector<std::filesystem::path> &dependencies,
    const DependencyCallback &callback,
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
    const std::vector<std::filesystem::path> &dependencies,
    const DependencyCallback &, const sourcemeta::registry::Resolver &)
    -> void {
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
