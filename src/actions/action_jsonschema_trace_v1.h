#ifndef SOURCEMETA_ONE_ACTIONS_JSONSCHEMA_TRACE_V1_H
#define SOURCEMETA_ONE_ACTIONS_JSONSCHEMA_TRACE_V1_H

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>
#include <sourcemeta/core/jsonrpc.h>
#include <sourcemeta/core/mcp.h>
#include <sourcemeta/core/uritemplate.h>

#include <sourcemeta/blaze/evaluator.h>
#include <sourcemeta/blaze/foundation.h>
#include <sourcemeta/blaze/output.h>

#include <sourcemeta/one/http.h>
#include <sourcemeta/one/metapack.h>
#include <sourcemeta/one/router.h>
#include <sourcemeta/one/shared.h>

#include "action_jsonschema_evaluate_v1.h"

#include <filesystem>  // std::filesystem::path
#include <functional>  // std::ref
#include <span>        // std::span
#include <stdexcept>   // std::runtime_error
#include <string>      // std::string
#include <string_view> // std::string_view
#include <utility>     // std::move

class ActionJSONSchemaTraceV1 : public sourcemeta::one::RouterAction {
public:
  static constexpr std::string_view DESCRIPTION{
      "Validate a JSON instance against a schema and return a step-by-step "
      "trace of the evaluation. The trace can be substantial, so prefer "
      "non-tracing evaluation when only a valid or invalid verdict is "
      "needed and use this when per-step detail is required"};
  static constexpr bool READ_ONLY{true};
  static constexpr bool DESTRUCTIVE{false};
  static constexpr bool IDEMPOTENT{true};
  static constexpr bool OPEN_WORLD{false};

  ActionJSONSchemaTraceV1(
      const std::filesystem::path &base,
      const sourcemeta::core::URITemplateRouterView &router,
      const sourcemeta::core::URITemplateRouter::Identifier identifier,
      sourcemeta::one::Router &dispatcher)
      : sourcemeta::one::RouterAction{base, router.base_url(), dispatcher} {
    router.arguments(
        identifier, [this](const auto &key, const auto &value) -> void {
          if (key == "requestSchema") {
            this->request_schema_ = std::get<std::string_view>(value);
          } else if (key == "responseSchema") {
            this->response_schema_ = std::get<std::string_view>(value);
          } else if (key == "mcpRequestSchema") {
            this->rpc_request_schema_ = std::get<std::string_view>(value);
          } else if (key == "mcpResponseSchema") {
            this->rpc_response_schema_ = std::get<std::string_view>(value);
          } else if (key == "errorSchema") {
            this->error_schema_ = std::get<std::string_view>(value);
          }
        });
  }

  auto rest(const std::span<std::string_view> matches,
            const sourcemeta::one::Authentication::Caller &caller,
            sourcemeta::one::HTTPRequest &request,
            sourcemeta::one::HTTPResponse &response) -> void override {
    const sourcemeta::one::RequestCookies cookies{request};
    ActionJSONSchemaEvaluateV1::serve_post(
        matches, caller, request, response, *this, this->response_schema_,
        this->error_schema_, this->request_schema_,
        // A throw here is intended and caught by the surrounding request
        // handler
        // NOLINTNEXTLINE(bugprone-exception-escape)
        [this,
         bearer = std::string{sourcemeta::core::http_parse_bearer(
             request.header("authorization"))},
         cookies = sourcemeta::one::owned_cookies(request)](
            const std::string_view schema_uri,
            const std::string &body) -> sourcemeta::core::JSON {
          sourcemeta::core::PointerPositionTracker tracker;
          sourcemeta::core::JSON instance_json{nullptr};
          sourcemeta::core::parse_json(body, instance_json, std::ref(tracker));
          const sourcemeta::one::RequestCookies fields{cookies};
          // Placed again rather than captured, since the caller this action
          // was handed points at a request that is gone by now
          const auto deferred_caller{
              this->caller_from({.bearer = bearer, .cookies = fields})};
          const auto schema_template{
              this->blaze_template(deferred_caller, schema_uri,
                                   sourcemeta::blaze::Mode::Exhaustive)};
          return ActionJSONSchemaTraceV1::build_trace_document(
              *schema_template, instance_json, &tracker,
              sourcemeta::core::Pointer{});
        });
  }

  auto mcp(const sourcemeta::core::MCPProtocolVersion version,
           const sourcemeta::core::JSON &request_id,
           const sourcemeta::core::JSON &arguments,
           const sourcemeta::one::Authentication::Caller &caller)
      -> sourcemeta::core::JSON override {
    auto [request_valid, request_output]{
        this->structural_evaluate(this->rpc_request_schema_, arguments,
                                  sourcemeta::blaze::Mode::Exhaustive)};
    if (!request_valid) {
      return sourcemeta::core::jsonrpc_make_error(
          &request_id, -32602, "Params fail against the tool request schema",
          std::move(request_output));
    }

    const auto &schema_uri{arguments.at("schema").to_string()};
    const auto schema_present{this->artifact_resolve_path(
        caller, schema_uri, Tree::Schemas, "schema")};
    const auto evaluation_enabled{this->artifact_resolve_path(
        caller, schema_uri, Tree::Schemas, "blaze-exhaustive")};
    if (!schema_present.path.has_value()) {
      return sourcemeta::core::mcp_make_tool_error(request_id,
                                                   "Schema not found");
    }

    if (!evaluation_enabled.path.has_value()) {
      return sourcemeta::core::mcp_make_tool_error(
          request_id, "This schema was not precompiled for schema evaluation");
    }

    sourcemeta::core::PointerPositionTracker tracker;
    sourcemeta::core::JSON parsed_instance{nullptr};
    try {
      sourcemeta::core::parse_json(
          arguments.at("stringifiedInstance").to_string(), parsed_instance,
          std::ref(tracker));
    } catch (const std::exception &) {
      return sourcemeta::core::mcp_make_tool_error(
          request_id, "The instance is not valid JSON");
    } catch (...) {
      return sourcemeta::core::mcp_make_tool_error(
          request_id, "The instance is not valid JSON");
    }

    return sourcemeta::core::mcp_make_tool_success(
        version, request_id,
        ActionJSONSchemaTraceV1::build_trace_document(
            *this->blaze_template(caller, schema_uri,
                                  sourcemeta::blaze::Mode::Exhaustive),
            parsed_instance, &tracker, sourcemeta::core::Pointer{}));
  }

  // Build the trace document for one evaluation. The instance prefix locates
  // the instance within the document the tracker was built over, which is that
  // document itself where the body is a bare instance, and the member holding
  // it where the body is an envelope
  static auto
  build_trace_document(const sourcemeta::blaze::Template &schema_template,
                       const sourcemeta::core::JSON &instance_json,
                       const sourcemeta::core::PointerPositionTracker *tracker,
                       const sourcemeta::core::Pointer &instance_prefix)
      -> sourcemeta::core::JSON {
    auto steps{sourcemeta::core::JSON::make_array()};

    const sourcemeta::blaze::TraceOutput::Callback callback{
        [&steps, tracker, &instance_prefix, &instance_json](
            const sourcemeta::blaze::TraceOutput::Entry &entry) -> void {
          auto step{sourcemeta::core::JSON::make_object()};

          if (entry.type == sourcemeta::blaze::TraceOutput::EntryType::Push) {
            step.assign("type", sourcemeta::core::JSON{"push"});
          } else if (entry.type ==
                     sourcemeta::blaze::TraceOutput::EntryType::Fail) {
            step.assign("type", sourcemeta::core::JSON{"fail"});
          } else {
            step.assign("type", sourcemeta::core::JSON{"pass"});
          }

          step.assign("name", sourcemeta::core::JSON{entry.name});
          step.assign("evaluatePath",
                      sourcemeta::core::JSON{
                          sourcemeta::core::to_string(entry.evaluate_path)});
          step.assign("instanceLocation",
                      sourcemeta::core::JSON{sourcemeta::core::to_string(
                          entry.instance_location)});
          if (tracker != nullptr) {
            auto instance_positions{tracker->get(instance_prefix.concat(
                // TODO: Can we avoid converting the weak pointer into a pointer
                // here?
                sourcemeta::core::to_pointer(entry.instance_location)))};
            if (!instance_positions.has_value()) {
              throw std::runtime_error{"Failed to resolve instance positions"};
            }
            step.assign("instancePositions",
                        sourcemeta::core::to_json(
                            std::move(instance_positions).value()));
          }
          step.assign("keywordLocation",
                      sourcemeta::core::JSON{entry.keyword_location});
          step.assign("annotation", entry.annotation);

          if (entry.type == sourcemeta::blaze::TraceOutput::EntryType::Push) {
            step.assign("message", sourcemeta::core::JSON{nullptr});
          } else {
            step.assign(
                "message",
                sourcemeta::core::JSON{sourcemeta::blaze::describe(
                    entry.type !=
                        sourcemeta::blaze::TraceOutput::EntryType::Fail,
                    entry.step, entry.evaluate_path, entry.instance_location,
                    instance_json, entry.annotation)});
          }

          if (entry.vocabulary.has_value()) {
            step.assign("vocabulary",
                        sourcemeta::core::JSON{entry.vocabulary.value()});
          } else {
            step.assign("vocabulary", sourcemeta::core::JSON{nullptr});
          }

          steps.push_back(std::move(step));
        }};

    sourcemeta::blaze::TraceOutput output{schema_template, callback};
    sourcemeta::blaze::Evaluator evaluator;
    const auto result{
        evaluator.validate(schema_template, instance_json, std::ref(output))};

    auto document{sourcemeta::core::JSON::make_object()};
    document.assign("valid", sourcemeta::core::JSON{result});
    document.assign("steps", std::move(steps));
    return document;
  }

private:
  std::string_view request_schema_;
  std::string_view response_schema_;
  std::string_view rpc_request_schema_;
  std::string_view rpc_response_schema_;
  std::string_view error_schema_;
};

#endif
