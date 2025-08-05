#ifndef SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_
#define SOURCEMETA_REGISTRY_INDEX_GENERATORS_H_

// TODO: These are the only rules that in theory we should be able
// to reload as needed based on user changes

#include <sourcemeta/registry/metapack.h>
#include <sourcemeta/registry/resolver.h>

#include <sourcemeta/core/alterschema.h>

#include <sourcemeta/core/gzip.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>
#include <sourcemeta/core/jsonschema.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>
#include <sourcemeta/blaze/linter.h>

#include <cassert>    // assert
#include <filesystem> // std::filesystem
#include <sstream>    // std::stringstream
#include <utility>    // std::move

namespace sourcemeta::registry {

auto GENERATE_HEALTH(const sourcemeta::registry::Resolver &resolver,
                     const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::registry::read_contents(absolute_path)};
  assert(schema.has_value());

  sourcemeta::core::SchemaTransformer bundle;
  sourcemeta::core::add(bundle, sourcemeta::core::AlterSchemaMode::Readability);
  bundle.add<sourcemeta::blaze::ValidExamples>(
      sourcemeta::blaze::default_schema_compiler);
  bundle.add<sourcemeta::blaze::ValidDefault>(
      sourcemeta::blaze::default_schema_compiler);

  auto errors{sourcemeta::core::JSON::make_array()};
  const auto result = bundle.check(
      sourcemeta::core::parse_json(schema.value().data),
      sourcemeta::core::schema_official_walker,
      [&resolver](const auto identifier) { return resolver(identifier); },
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
  // TODO: Elevate just the score to the directory navs
  report.assign("score", sourcemeta::core::to_json(result.second));
  report.assign("errors", std::move(errors));
  return report;
}

auto GENERATE_FRAME_LOCATIONS(const sourcemeta::registry::Resolver &resolver,
                              const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::registry::read_contents(absolute_path)};
  assert(schema.has_value());
  sourcemeta::core::SchemaFrame frame{
      sourcemeta::core::SchemaFrame::Mode::Locations};
  frame.analyse(
      sourcemeta::core::parse_json(schema.value().data),
      sourcemeta::core::schema_official_walker,
      [&resolver](const auto identifier) { return resolver(identifier); });
  return frame.to_json().at("locations");
}

auto GENERATE_BUNDLE(const sourcemeta::registry::Resolver &resolver,
                     const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::registry::read_contents(absolute_path)};
  assert(schema.has_value());
  return sourcemeta::core::bundle(
      sourcemeta::core::parse_json(schema.value().data),
      sourcemeta::core::schema_official_walker,
      [&resolver](const auto identifier) { return resolver(identifier); });
}

auto GENERATE_DEPENDENCIES(const sourcemeta::registry::Resolver &resolver,
                           const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::registry::read_contents(absolute_path)};
  assert(schema.has_value());
  auto result{sourcemeta::core::JSON::make_array()};
  sourcemeta::core::dependencies(
      sourcemeta::core::parse_json(schema.value().data),
      sourcemeta::core::schema_official_walker,
      [&resolver](const auto identifier) { return resolver(identifier); },
      [&result](const auto &origin, const auto &pointer, const auto &target,
                const auto &) {
        auto trace{sourcemeta::core::JSON::make_object()};
        trace.assign("from", sourcemeta::core::to_json(origin));
        trace.assign("to", sourcemeta::core::to_json(target));
        trace.assign("at", sourcemeta::core::to_json(pointer));
        result.push_back(std::move(trace));
      });

  return result;
}

auto GENERATE_UNIDENTIFIED(const sourcemeta::registry::Resolver &resolver,
                           const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  auto contents{sourcemeta::registry::read_contents(absolute_path)};
  assert(contents.has_value());
  auto schema{sourcemeta::core::parse_json(contents.value().data)};
  sourcemeta::core::unidentify(
      schema, sourcemeta::core::schema_official_walker,
      [&resolver](const auto identifier) { return resolver(identifier); });
  return schema;
}

auto GENERATE_BLAZE_TEMPLATE_EXHAUSTIVE(
    const sourcemeta::registry::Resolver &,
    const std::filesystem::path &absolute_path) -> sourcemeta::core::JSON {
  const auto schema{sourcemeta::registry::read_contents(absolute_path)};
  assert(schema.has_value());
  const auto schema_template{sourcemeta::blaze::compile(
      sourcemeta::core::parse_json(schema.value().data),
      sourcemeta::core::schema_official_walker,
      sourcemeta::core::schema_official_resolver,
      sourcemeta::blaze::default_schema_compiler,
      sourcemeta::blaze::Mode::Exhaustive)};
  return sourcemeta::blaze::to_json(schema_template);
}

auto GENERATE_POINTER_POSITIONS(const sourcemeta::registry::Resolver &,
                                const std::filesystem::path &absolute_path)
    -> sourcemeta::core::JSON {
  sourcemeta::core::PointerPositionTracker tracker;
  const auto file{sourcemeta::registry::read_contents(absolute_path)};
  assert(file.has_value());
  const auto schema{
      sourcemeta::core::parse_json(file.value().data, std::ref(tracker))};
  return sourcemeta::core::to_json(tracker);
}

} // namespace sourcemeta::registry

#endif
