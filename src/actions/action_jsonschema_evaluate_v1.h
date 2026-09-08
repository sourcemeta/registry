#ifndef SOURCEMETA_ONE_ACTIONS_JSONSCHEMA_EVALUATE_V1_H
#define SOURCEMETA_ONE_ACTIONS_JSONSCHEMA_EVALUATE_V1_H

#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonrpc.h>
#include <sourcemeta/core/mcp.h>
#include <sourcemeta/core/uritemplate.h>

#include <sourcemeta/one/http.h>
#include <sourcemeta/one/router.h>
#include <sourcemeta/one/shared.h>

#include <exception> // std::exception, std::exception_ptr, std::rethrow_exception
#include <filesystem>  // std::filesystem::path
#include <span>        // std::span
#include <sstream>     // std::ostringstream
#include <string>      // std::string
#include <string_view> // std::string_view
#include <utility>     // std::move

class ActionJSONSchemaEvaluateV1 : public sourcemeta::one::RouterAction {
public:
  static constexpr std::string_view DESCRIPTION{
      "Validate a JSON instance against a schema and return whether it "
      "is valid plus any errors"};
  static constexpr bool READ_ONLY{true};
  static constexpr bool DESTRUCTIVE{false};
  static constexpr bool IDEMPOTENT{true};
  static constexpr bool OPEN_WORLD{false};

  ActionJSONSchemaEvaluateV1(
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
          const sourcemeta::one::RequestCookies fields{cookies};
          // Placed again rather than captured, since the caller this action
          // was handed points at a request that is gone by now
          const auto deferred_caller{
              this->caller_from({.bearer = bearer, .cookies = fields})};
          return this
              ->schema_evaluate(deferred_caller, schema_uri,
                                sourcemeta::core::parse_json(body),
                                sourcemeta::blaze::Mode::Exhaustive)
              .second;
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

    sourcemeta::core::JSON parsed_instance{nullptr};
    try {
      parsed_instance = sourcemeta::core::parse_json(
          arguments.at("stringifiedInstance").to_string());
    } catch (const std::exception &) {
      return sourcemeta::core::mcp_make_tool_error(
          request_id, "The instance is not valid JSON");
    } catch (...) {
      return sourcemeta::core::mcp_make_tool_error(
          request_id, "The instance is not valid JSON");
    }

    return sourcemeta::core::mcp_make_tool_success(
        version, request_id,
        this->schema_evaluate(caller, schema_uri, parsed_instance,
                              sourcemeta::blaze::Mode::Exhaustive)
            .second);
  }

  template <typename Perform>
  static auto serve_post(const std::span<std::string_view> matches,
                         const sourcemeta::one::Authentication::Caller &caller,
                         sourcemeta::one::HTTPRequest &request,
                         sourcemeta::one::HTTPResponse &response,
                         const sourcemeta::one::RouterAction &self,
                         const std::string_view response_schema,
                         const std::string_view error_schema,
                         const std::string_view request_schema, Perform perform)
      -> void {
    if (self.schema_post_preamble(request, response, error_schema)) {
      return;
    }

    const auto &path{matches.front()};
    if (path.find('#') != std::string_view::npos ||
        path.find("%23") != std::string_view::npos) {
      sourcemeta::one::json_error(
          request, response, sourcemeta::core::HTTP_STATUS_BAD_REQUEST,
          "urn:sourcemeta:one:invalid-schema-uri",
          "The schema URI must not contain a fragment", error_schema, "*");
      return;
    }

    std::string schema_uri{self.server_uri()};
    schema_uri.push_back('/');
    schema_uri.append(path);
    const auto schema_present{self.artifact_resolve_path(
        caller, schema_uri, sourcemeta::one::RouterAction::Tree::Schemas,
        "schema")};
    const auto evaluation_enabled{self.artifact_resolve_path(
        caller, schema_uri, sourcemeta::one::RouterAction::Tree::Schemas,
        "blaze-exhaustive")};
    if (!schema_present.path.has_value()) {
      sourcemeta::one::json_error(
          request, response, sourcemeta::core::HTTP_STATUS_NOT_FOUND,
          "urn:sourcemeta:one:not-found", "There is nothing at this URL",
          error_schema, "*");
      return;
    }

    if (!evaluation_enabled.path.has_value()) {
      // RFC 9110 §15.5.6: Allow lists the methods this specific target
      // resource currently supports. POST hits this very branch (returns
      // 405) when the schema was not precompiled, so only OPTIONS is
      // actually supported on this URL.
      sourcemeta::one::json_error(
          request, response, sourcemeta::core::HTTP_STATUS_METHOD_NOT_ALLOWED,
          "urn:sourcemeta:one:no-schema-template",
          "This schema was not precompiled for schema evaluation", error_schema,
          "*", "OPTIONS");
      return;
    }

    self.schema_post_body(
        request, response, response_schema, error_schema,
        sourcemeta::one::MAX_REQUEST_BODY_BYTES,
        // A throw here is intended and caught by the surrounding error
        // handler
        // NOLINTNEXTLINE(bugprone-exception-escape)
        [&self, request_schema, schema_uri = std::move(schema_uri),
         perform = std::move(perform)](
            const std::string &body) -> sourcemeta::core::JSON {
          const auto instance{sourcemeta::core::parse_json(body)};
          if (!self.structural_evaluate_fast(request_schema, instance)) {
            throw sourcemeta::one::SchemaPostRequestError{};
          }

          return perform(schema_uri, body);
        });
  }

private:
  std::string_view request_schema_;
  std::string_view response_schema_;
  std::string_view rpc_request_schema_;
  std::string_view rpc_response_schema_;
  std::string_view error_schema_;
};

#endif
