#ifndef SOURCEMETA_REGISTRY_SERVER_EVALUATE_H
#define SOURCEMETA_REGISTRY_SERVER_EVALUATE_H

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>

#include <sourcemeta/registry/metapack.h>

#include <cassert>     // assert
#include <filesystem>  // std::filesystem::path
#include <type_traits> // std::underlying_type_t
#include <utility>     // std::move

namespace {

auto trace(sourcemeta::blaze::Evaluator &evaluator,
           const sourcemeta::blaze::Template &schema_template,
           const std::string &instance,
           const std::filesystem::path &template_path)
    -> sourcemeta::core::JSON {
  auto steps{sourcemeta::core::JSON::make_array()};

  auto locations_path{template_path.parent_path() / "locations.metapack"};
  // TODO: Cache this across runs?
  const auto locations_entry{
      sourcemeta::registry::read_contents(locations_path)};
  assert(locations_entry.has_value());
  const auto locations{
      sourcemeta::core::parse_json(locations_entry.value().data)};
  assert(locations.defines("static"));
  const auto &static_locations{locations.at("static")};

  sourcemeta::core::PointerPositionTracker tracker;
  const auto instance_json{
      sourcemeta::core::parse_json(instance, std::ref(tracker))};
  const auto result{evaluator.validate(
      schema_template, instance_json,
      [&steps, &tracker, &static_locations, &instance_json](
          const sourcemeta::blaze::EvaluationType type, const bool valid,
          const sourcemeta::blaze::Instruction &instruction,
          const sourcemeta::core::WeakPointer &evaluate_path,
          const sourcemeta::core::WeakPointer &instance_location,
          const sourcemeta::core::JSON &annotation) {
        auto step{sourcemeta::core::JSON::make_object()};

        if (type == sourcemeta::blaze::EvaluationType::Pre) {
          step.assign("type", sourcemeta::core::JSON{"push"});
        } else if (valid) {
          step.assign("type", sourcemeta::core::JSON{"pass"});
        } else {
          step.assign("type", sourcemeta::core::JSON{"fail"});
        }

        step.assign("name", sourcemeta::core::JSON{
                                sourcemeta::blaze::InstructionNames
                                    [static_cast<std::underlying_type_t<
                                        sourcemeta::blaze::InstructionIndex>>(
                                        instruction.type)]});
        step.assign("evaluatePath", sourcemeta::core::to_json(evaluate_path));
        step.assign("instanceLocation",
                    sourcemeta::core::to_json(instance_location));
        auto instance_positions{tracker.get(
            // TODO: Can we avoid converting the weak pointer into a pointer
            // here?
            sourcemeta::core::to_pointer(instance_location))};
        assert(instance_positions.has_value());
        step.assign(
            "instancePositions",
            sourcemeta::core::to_json(std::move(instance_positions).value()));
        step.assign("keywordLocation",
                    sourcemeta::core::to_json(instruction.keyword_location));
        step.assign("annotation", annotation);

        if (type == sourcemeta::blaze::EvaluationType::Pre) {
          step.assign("message", sourcemeta::core::JSON{nullptr});
        } else {
          step.assign("message",
                      sourcemeta::core::JSON{sourcemeta::blaze::describe(
                          valid, instruction, evaluate_path, instance_location,
                          instance_json, annotation)});
        }

        // Determine keyword vocabulary
        const auto &current_location{
            static_locations.at(instruction.keyword_location)};
        const auto vocabularies{sourcemeta::core::vocabularies(
            sourcemeta::core::schema_official_resolver,
            current_location.at("baseDialect").to_string(),
            current_location.at("dialect").to_string())};
        const auto walker_result{sourcemeta::core::schema_official_walker(
            evaluate_path.back().to_property(), vocabularies)};
        step.assign("vocabulary",
                    sourcemeta::core::to_json(walker_result.vocabulary));

        steps.push_back(std::move(step));
      })};

  auto document{sourcemeta::core::JSON::make_object()};
  document.assign("valid", sourcemeta::core::JSON{result});
  document.assign("steps", std::move(steps));
  return document;
}

} // namespace

namespace sourcemeta::registry {

enum class EvaluateType { Standard, Trace };

auto evaluate(const std::filesystem::path &template_path,
              const std::string &instance, const EvaluateType type)
    -> sourcemeta::core::JSON {
  assert(std::filesystem::exists(template_path));

  // TODO: Cache this conversion across runs, potentially using the schema file
  // "checksum" as the cache key. This is important as the template might be
  // compressed
  const auto template_json{read_contents(template_path)};
  assert(template_json.has_value());
  const auto schema_template{sourcemeta::blaze::from_json(
      sourcemeta::core::parse_json(template_json.value().data))};
  assert(schema_template.has_value());

  sourcemeta::blaze::Evaluator evaluator;

  switch (type) {
    case EvaluateType::Standard:
      return sourcemeta::blaze::standard(
          evaluator, schema_template.value(),
          sourcemeta::core::parse_json(instance),
          sourcemeta::blaze::StandardOutput::Basic);
    case EvaluateType::Trace:
      return trace(evaluator, schema_template.value(), instance, template_path);
    default:
      // We should never get here
      assert(false);
      return sourcemeta::core::JSON{nullptr};
  }
}

} // namespace sourcemeta::registry

#endif
