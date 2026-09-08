#ifndef SOURCEMETA_ONE_ACTIONS_PLAYGROUND_SCHEMA_TRACE_V1_H
#define SOURCEMETA_ONE_ACTIONS_PLAYGROUND_SCHEMA_TRACE_V1_H

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonpointer.h>
#include <sourcemeta/core/mcp.h>
#include <sourcemeta/core/uritemplate.h>

#include <sourcemeta/one/http.h>
#include <sourcemeta/one/router.h>
#include <sourcemeta/one/shared.h>

#include "action_jsonschema_post.h"
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
          } else if (key == "errorSchema") {
            this->error_schema_ = std::get<std::string_view>(value);
          }
        });
  }

  auto rest(const std::span<std::string_view>,
            const sourcemeta::one::Authentication::Caller &,
            sourcemeta::one::HTTPRequest &request,
            sourcemeta::one::HTTPResponse &response) -> void override {
    if (sourcemeta::one::schema_post_preamble(request, response,
                                              this->error_schema_)) {
      return;
    }

    sourcemeta::one::schema_post_body(
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
          const auto schema_template{sourcemeta::one::compile_playground_schema(
              *this, deferred_caller, envelope.at("schema"))};
          return ActionJSONSchemaTraceV1::build_trace_document(
              schema_template, envelope.at("instance"), &tracker,
              sourcemeta::core::Pointer{"instance"});
        });
  }

  auto mcp(const sourcemeta::core::MCPProtocolVersion,
           const sourcemeta::core::JSON &request_id,
           const sourcemeta::core::JSON &,
           const sourcemeta::one::Authentication::Caller &)
      -> sourcemeta::core::JSON override {
    return sourcemeta::core::mcp_make_tool_error(
        request_id, "This action is not exposed as a tool");
  }

private:
  std::string_view request_schema_;
  std::string_view response_schema_;
  std::string_view error_schema_;
};

#endif
