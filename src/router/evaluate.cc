#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>
#include <sourcemeta/blaze/foundation.h>
#include <sourcemeta/blaze/output.h>

#include <sourcemeta/one/metapack.h>
#include <sourcemeta/one/router.h>

#include <cassert>     // assert
#include <cstdint>     // std::uint64_t
#include <exception>   // std::exception
#include <functional>  // std::ref
#include <memory>      // std::make_shared, std::shared_ptr
#include <string_view> // std::string_view
#include <utility>     // std::move, std::pair
#include <vector>      // std::vector

namespace sourcemeta::one {

namespace {

// What a playground schema may cost, as multiples of the worst case across
// every schema the sandboxes index, measured 2026-09-07. The body cap normally
// refuses a schema before the instruction budget can fire, which leaves that
// one standing as a backstop for a schema whose compiled size outgrows what it
// is written down as
inline constexpr std::uint64_t MAX_PLAYGROUND_SCHEMA_LOCATIONS{80000};
inline constexpr std::uint64_t MAX_PLAYGROUND_SCHEMA_INSTRUCTIONS{400000};
inline constexpr std::uint64_t MAX_PLAYGROUND_SCHEMA_DEPTH{44};
// How deeply the document itself may nest, which is a separate question from
// how deeply compilation descends, since a schema can bury a value far below
// any subschema. The deepest schema across the sandboxes nests 48
inline constexpr std::uint64_t MAX_PLAYGROUND_SCHEMA_JSON_DEPTH{256};

// Resolve a reference from a playground schema the way this registry would
// it for whoever asked. What the caller may not read does not resolve, and
// neither does anything outside this instance
class PlaygroundSchemaResolver {
public:
  PlaygroundSchemaResolver(const RouterAction &action,
                           const Authentication::Caller &caller)
      : action_{&action}, caller_{&caller} {}

  [[nodiscard]] auto operator()(const std::string_view identifier) const
      -> sourcemeta::blaze::SchemaResolverResult {
    const auto resolution{this->action_->artifact_resolve_path(
        *this->caller_, identifier, RouterAction::Tree::Schemas, "schema")};
    if (resolution.path.has_value()) {
      auto schema{this->action_->artifact_read_json(resolution.path.value())};
      if (schema.has_value()) {
        return std::move(schema).value();
      }
    }

    return sourcemeta::blaze::schema_resolver(identifier);
  }

private:
  const RouterAction *action_;
  const Authentication::Caller *caller_;
};

// Place a reference that would not resolve within the schema the caller sent,
// by framing what they wrote rather than trusting what compilation reported.
// Nothing is named that does not appear in their own document, so a refusal
// tells them where they went wrong without telling them what this instance
// holds
auto unresolvable_reference(const sourcemeta::core::JSON &document,
                            const sourcemeta::blaze::SchemaResolver &resolver,
                            const std::string_view identifier)
    -> PlaygroundSchemaError {
  std::string reference;
  std::string location;

  try {
    const sourcemeta::blaze::SchemaFrame frame{
        sourcemeta::blaze::SchemaFrame::Mode::References,
        document,
        sourcemeta::blaze::schema_walker,
        resolver,
        "",
        "",
        sourcemeta::blaze::SchemaFrame::IdentifierMode::Additional,
        {sourcemeta::core::EMPTY_WEAK_POINTER},
        MAX_PLAYGROUND_SCHEMA_LOCATIONS};
    frame.for_each_unresolved_reference(
        [&reference, &location, identifier](
            const sourcemeta::core::WeakPointer &pointer,
            const sourcemeta::blaze::SchemaFrame::Reference &entry) -> void {
          if (reference.empty() && entry.destination == identifier) {
            reference = entry.destination;
            location = sourcemeta::core::to_string(pointer);
          }
        });
    // A schema that would not compile may not frame either, and a reference
    // this cannot place is one this does not name
    // NOLINTNEXTLINE(bugprone-empty-catch)
  } catch (const std::exception &) {
  }

  // A dialect that resolves nowhere is a reference too, and framing cannot
  // report it because framing is what failed on it
  if (reference.empty() && document.is_object()) {
    const auto *dialect{document.try_at("$schema")};
    if (dialect != nullptr && dialect->is_string() &&
        dialect->to_string() == identifier) {
      reference = dialect->to_string();
      location = "/$schema";
    }
  }

  return {sourcemeta::core::HTTP_STATUS_BAD_REQUEST,
          "urn:sourcemeta:one:unresolvable-reference",
          "A reference in the supplied schema could not be resolved",
          std::move(reference), std::move(location)};
}

// Framing walks the whole schema before any compiler budget applies, so a
// document nested deeply enough exhausts the stack before `max_depth` can
// refuse it. This bounds the shape of what is walked rather than what is
// compiled, and measures iteratively so that checking is not itself the thing
// that overflows
auto exceeds_json_depth(const sourcemeta::core::JSON &document,
                        const std::uint64_t limit) -> bool {
  std::vector<std::pair<const sourcemeta::core::JSON *, std::uint64_t>> pending;
  pending.emplace_back(&document, 1);

  while (!pending.empty()) {
    const auto entry{pending.back()};
    pending.pop_back();
    if (entry.second > limit) {
      return true;
    }

    if (entry.first->is_object()) {
      for (const auto &member : entry.first->as_object()) {
        pending.emplace_back(&member.second, entry.second + 1);
      }
    } else if (entry.first->is_array()) {
      for (const auto &member : entry.first->as_array()) {
        pending.emplace_back(&member, entry.second + 1);
      }
    }
  }

  return false;
}

} // namespace

auto Router::blaze_template(const ResolvedArtifact &artifact)
    -> std::shared_ptr<const sourcemeta::blaze::Template> {
  return this->template_cache_.get_or_compute(
      artifact.path(), [&artifact]() -> sourcemeta::blaze::Template {
        const auto template_json{
            sourcemeta::one::metapack_read_json(artifact.path())};
        assert(template_json.has_value());
        auto compiled{sourcemeta::blaze::from_json(template_json.value())};
        assert(compiled.has_value());
        return std::move(compiled).value();
      });
}

auto RouterAction::structural_template(const std::string_view schema_uri,
                                       const sourcemeta::blaze::Mode mode) const
    -> std::shared_ptr<const sourcemeta::blaze::Template> {
  const auto artifact{this->artifact_resolve_path_unauthenticated(
      VIEW_PUBLIC, schema_uri, Tree::Schemas,
      mode == sourcemeta::blaze::Mode::FastValidation ? "blaze-fast"
                                                      : "blaze-exhaustive")};
  assert(artifact.has_value());
  return this->dispatcher_.blaze_template(artifact.value());
}

auto RouterAction::structural_evaluate(const std::string_view schema_uri,
                                       const sourcemeta::core::JSON &instance,
                                       const sourcemeta::blaze::Mode mode) const
    -> std::pair<bool, sourcemeta::core::JSON> {
  const auto schema_template{this->structural_template(schema_uri, mode)};
  sourcemeta::blaze::Evaluator evaluator;
  auto result{
      sourcemeta::blaze::standard(evaluator, *schema_template, instance,
                                  sourcemeta::blaze::StandardOutput::Basic)};
  const auto *valid{result.try_at("valid")};
  const bool is_valid{valid != nullptr && valid->is_boolean() &&
                      valid->to_boolean()};
  return {is_valid, std::move(result)};
}

auto RouterAction::structural_evaluate_fast(
    const std::string_view schema_uri,
    const sourcemeta::core::JSON &instance) const -> bool {
  const auto schema_template{this->structural_template(
      schema_uri, sourcemeta::blaze::Mode::FastValidation)};
  sourcemeta::blaze::Evaluator evaluator;
  return evaluator.validate(*schema_template, instance);
}

auto RouterAction::blaze_template(const Authentication::Caller &caller,
                                  const std::string_view schema_uri,
                                  const sourcemeta::blaze::Mode mode) const
    -> std::shared_ptr<const sourcemeta::blaze::Template> {
  // A compiled schema lives in the unit tree, which holds one answer whoever
  // asks and carries no segment naming a view, so what is named here reaches
  // no path and the anonymous one stands for every caller
  const auto resolution{this->artifact_resolve_path(
      caller, schema_uri, Tree::Schemas,
      mode == sourcemeta::blaze::Mode::FastValidation ? "blaze-fast"
                                                      : "blaze-exhaustive")};
  assert(resolution.path.has_value());
  return this->dispatcher_.blaze_template(resolution.path.value());
}

auto RouterAction::schema_evaluate_fast(
    const Authentication::Caller &caller, const std::string_view schema_uri,
    const sourcemeta::core::JSON &instance) const -> bool {
  const auto schema_template{this->blaze_template(
      caller, schema_uri, sourcemeta::blaze::Mode::FastValidation)};
  sourcemeta::blaze::Evaluator evaluator;
  return evaluator.validate(*schema_template, instance);
}

auto RouterAction::schema_evaluate(const Authentication::Caller &caller,
                                   const std::string_view schema_uri,
                                   const sourcemeta::core::JSON &instance,
                                   const sourcemeta::blaze::Mode mode) const
    -> std::pair<bool, sourcemeta::core::JSON> {
  const auto schema_template{this->blaze_template(caller, schema_uri, mode)};
  sourcemeta::blaze::Evaluator evaluator;
  auto result{
      sourcemeta::blaze::standard(evaluator, *schema_template, instance,
                                  sourcemeta::blaze::StandardOutput::Basic)};
  const auto *valid{result.try_at("valid")};
  const bool is_valid{valid != nullptr && valid->is_boolean() &&
                      valid->to_boolean()};
  return {is_valid, std::move(result)};
}

auto RouterAction::schema_evaluate_with_tracing(
    const Authentication::Caller &caller, const std::string_view schema_uri,
    const sourcemeta::core::JSON &instance,
    const sourcemeta::blaze::TraceOutput::Callback &callback) const -> bool {
  const auto schema_template{this->blaze_template(
      caller, schema_uri, sourcemeta::blaze::Mode::Exhaustive)};
  sourcemeta::blaze::TraceOutput output{*schema_template, callback};
  sourcemeta::blaze::Evaluator evaluator;
  return evaluator.validate(*schema_template, instance, std::ref(output));
}

// Compile a playground schema under the budgets, resolving as the given
// Whatever compilation refuses becomes the answer the caller is owed, since a
// schema they wrote failing to compile is a fact about their request
auto RouterAction::compile_playground_schema(
    const Authentication::Caller &caller,
    const sourcemeta::core::JSON &schema) const -> sourcemeta::blaze::Template {
  if (exceeds_json_depth(schema, MAX_PLAYGROUND_SCHEMA_JSON_DEPTH)) {
    throw PlaygroundSchemaError{
        sourcemeta::core::HTTP_STATUS_UNPROCESSABLE_CONTENT,
        "urn:sourcemeta:one:schema-too-complex",
        "The supplied schema is too complex to compile on demand, so try a "
        "simpler one or add it to the catalog, where no such limit applies"};
  }

  const PlaygroundSchemaResolver resolver{*this, caller};
  const sourcemeta::blaze::Tweaks tweaks{
      .max_instructions = MAX_PLAYGROUND_SCHEMA_INSTRUCTIONS,
      .max_depth = MAX_PLAYGROUND_SCHEMA_DEPTH};

  try {
    return sourcemeta::blaze::compile(
        schema, sourcemeta::blaze::schema_walker, std::ref(resolver),
        sourcemeta::blaze::default_schema_compiler,
        sourcemeta::blaze::Mode::Exhaustive, "", "", "", tweaks,
        MAX_PLAYGROUND_SCHEMA_LOCATIONS);
  } catch (const sourcemeta::blaze::SchemaFrameLimitError &) {
    throw PlaygroundSchemaError{
        sourcemeta::core::HTTP_STATUS_UNPROCESSABLE_CONTENT,
        "urn:sourcemeta:one:schema-too-complex",
        "The supplied schema is too complex to compile on demand, so try a "
        "simpler one or add it to the catalog, where no such limit applies"};
  } catch (const sourcemeta::blaze::CompilerInstructionLimitError &) {
    throw PlaygroundSchemaError{
        sourcemeta::core::HTTP_STATUS_UNPROCESSABLE_CONTENT,
        "urn:sourcemeta:one:schema-too-complex",
        "The supplied schema is too complex to compile on demand, so try a "
        "simpler one or add it to the catalog, where no such limit applies"};
  } catch (const sourcemeta::blaze::CompilerDepthLimitError &) {
    throw PlaygroundSchemaError{
        sourcemeta::core::HTTP_STATUS_UNPROCESSABLE_CONTENT,
        "urn:sourcemeta:one:schema-too-complex",
        "The supplied schema is too complex to compile on demand, so try a "
        "simpler one or add it to the catalog, where no such limit applies"};
  } catch (const sourcemeta::blaze::SchemaResolutionError &error) {
    throw unresolvable_reference(schema, std::ref(resolver),
                                 error.identifier());
  } catch (const sourcemeta::blaze::SchemaReferenceError &error) {
    throw unresolvable_reference(schema, std::ref(resolver),
                                 error.identifier());
  } catch (const PlaygroundSchemaError &) {
    throw;
  } catch (const std::exception &) {
    throw PlaygroundSchemaError{sourcemeta::core::HTTP_STATUS_BAD_REQUEST,
                                "urn:sourcemeta:one:invalid-schema",
                                "The supplied schema could not be compiled"};
  }
}

} // namespace sourcemeta::one
