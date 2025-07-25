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
           const std::string &instance) -> sourcemeta::core::JSON {
  auto steps{sourcemeta::core::JSON::make_array()};

  sourcemeta::core::PointerPositionTracker tracker;
  const auto instance_json{
      sourcemeta::core::parse_json(instance, std::ref(tracker))};
  const auto result{evaluator.validate(
      schema_template, instance_json,
      [&steps, &tracker](const sourcemeta::blaze::EvaluationType type,
                         const bool valid,
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
  // "md5" as the cache key
  const auto template_json{read_json(template_path)};
  assert(template_json.has_value());
  const auto schema_template{
      sourcemeta::blaze::from_json(template_json.value().data)};
  assert(schema_template.has_value());

  sourcemeta::blaze::Evaluator evaluator;

  switch (type) {
    case EvaluateType::Standard:
      return sourcemeta::blaze::standard(
          evaluator, schema_template.value(),
          sourcemeta::core::parse_json(instance),
          sourcemeta::blaze::StandardOutput::Basic);
    case EvaluateType::Trace:
      return trace(evaluator, schema_template.value(), instance);
    default:
      // We should never get here
      assert(false);
      return sourcemeta::core::JSON{nullptr};
  }
}

} // namespace sourcemeta::registry

#endif
