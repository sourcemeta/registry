#ifndef SOURCEMETA_ONE_ACTIONS_PLAYGROUND_SCHEMA_TRACE_V1_H
#define SOURCEMETA_ONE_ACTIONS_PLAYGROUND_SCHEMA_TRACE_V1_H

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>
#include <sourcemeta/core/jsonrpc.h>
#include <sourcemeta/core/mcp.h>
#include <sourcemeta/core/uritemplate.h>

#include <sourcemeta/one/http.h>
#include <sourcemeta/one/router.h>
#include <sourcemeta/one/shared.h>

#include "action_jsonschema_trace_v1.h"

#include <filesystem>  // std::filesystem::path
#include <functional>  // std::ref
#include <span>        // std::span
#include <string>      // std::string
#include <string_view> // std::string_view

class ActionPlaygroundSchemaTraceV1 : public sourcemeta::one::RouterAction {
public:
  static constexpr std::string_view DESCRIPTION{
      "Validate a JSON instance against a schema the caller supplies in the "
      "request rather than one this catalog holds, and return a step-by-step "
      "trace of the evaluation. References to schemas in this catalog are "
      "resolved as far as the caller may read them, and references to anywhere "
      "else are refused"};
  static constexpr bool READ_ONLY{true};
  static constexpr bool DESTRUCTIVE{false};
  static constexpr bool IDEMPOTENT{true};
  static constexpr bool OPEN_WORLD{false};

  ActionPlaygroundSchemaTraceV1(
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

  auto rest(const std::span<std::string_view>,
            const sourcemeta::one::Authentication::Caller &,
            sourcemeta::one::HTTPRequest &request,
            sourcemeta::one::HTTPResponse &response) -> void override {
    if (this->schema_post_preflight(request, response) ||
        this->schema_post_method_refused(request, response,
                                         this->error_schema_)) {
      return;
    }

    this->schema_post_body(
        request, response, this->response_schema_, this->error_schema_,
        sourcemeta::one::MAX_PLAYGROUND_REQUEST_BODY_BYTES,
        // A throw here is intended and caught by the surrounding request
        // handler
        // NOLINTNEXTLINE(bugprone-exception-escape)
        [this,
         bearer = std::string{sourcemeta::core::http_parse_bearer(
             request.header("authorization"))},
         cookies = sourcemeta::one::owned_cookies(request)](
            const std::string &body) -> sourcemeta::core::JSON {
          sourcemeta::core::PointerPositionTracker tracker;
          sourcemeta::core::JSON envelope{nullptr};
          sourcemeta::core::parse_json(body, envelope, std::ref(tracker));
          if (!this->structural_evaluate_fast(this->request_schema_,
                                              envelope)) {
            throw sourcemeta::one::SchemaPostRequestError{};
          }

          const sourcemeta::one::RequestCookies fields{cookies};
          // Placed again rather than captured, since the caller this action
          // was handed points at a request that is gone by now
          const auto deferred_caller{
              this->caller_from({.bearer = bearer, .cookies = fields})};
          const auto schema_template{this->compile_playground_schema(
              deferred_caller, envelope.at("schema"))};
          return ActionJSONSchemaTraceV1::build_trace_document(
              schema_template, envelope.at("instance"), &tracker,
              sourcemeta::core::Pointer{"instance"});
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

    sourcemeta::core::JSON parsed_schema{nullptr};
    try {
      parsed_schema = sourcemeta::core::parse_json(
          arguments.at("stringifiedSchema").to_string());
    } catch (const std::exception &) {
      return sourcemeta::core::mcp_make_tool_error(
          request_id, "The schema is not valid JSON");
    } catch (...) {
      return sourcemeta::core::mcp_make_tool_error(
          request_id, "The schema is not valid JSON");
    }

    // What the REST surface refuses through its request schema, this refuses
    // here, since a tool argument arrives as a string rather than a document
    if (!parsed_schema.is_object() || !parsed_schema.defines("$schema")) {
      return sourcemeta::core::mcp_make_tool_error(
          request_id, "The schema must be an object declaring its dialect");
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

    try {
      const auto schema_template{
          this->compile_playground_schema(caller, parsed_schema)};
      return sourcemeta::core::mcp_make_tool_success(
          version, request_id,
          ActionJSONSchemaTraceV1::build_trace_document(
              schema_template, parsed_instance, &tracker,
              sourcemeta::core::Pointer{}));
    } catch (const sourcemeta::one::PlaygroundSchemaError &error) {
      return sourcemeta::core::mcp_make_tool_error(request_id, error.what());
    }
  }

private:
  std::string_view request_schema_;
  std::string_view response_schema_;
  std::string_view rpc_request_schema_;
  std::string_view rpc_response_schema_;
  std::string_view error_schema_;
};

#endif
