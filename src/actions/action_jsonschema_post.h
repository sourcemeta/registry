#ifndef SOURCEMETA_ONE_ACTIONS_JSONSCHEMA_POST_H
#define SOURCEMETA_ONE_ACTIONS_JSONSCHEMA_POST_H

#include <sourcemeta/core/json.h>

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>
#include <sourcemeta/blaze/foundation.h>

#include <sourcemeta/one/http.h>
#include <sourcemeta/one/router.h>

#include <cstddef>   // std::size_t
#include <cstdint>   // std::uint64_t
#include <exception> // std::exception, std::exception_ptr, std::rethrow_exception
#include <functional>  // std::ref
#include <optional>    // std::optional
#include <sstream>     // std::ostringstream
#include <string>      // std::string
#include <string_view> // std::string_view
#include <utility>     // std::move

namespace sourcemeta::one {

// The body did not match what the route accepts
struct SchemaPostRequestError final : std::exception {
  [[nodiscard]] auto what() const noexcept -> const char * override {
    return "The request body does not match the expected schema";
  }
};

// What an inline schema may cost. A caller-supplied schema is the only thing
// this program compiles at request time, so what it may spend is settled here
// rather than by whatever the schema asks for. The three schema budgets are
// multiples of the worst case across every schema the sandboxes index,
// measured 2026-09-07. The body cap normally refuses a schema before the
// instruction budget can fire, which leaves that one standing as a backstop
// for a schema whose compiled size outgrows what it is written down as
inline constexpr std::size_t MAX_INLINE_REQUEST_BODY_BYTES{
    static_cast<std::size_t>(1) * 1024 * 1024};
inline constexpr std::uint64_t MAX_INLINE_SCHEMA_LOCATIONS{80000};
inline constexpr std::uint64_t MAX_INLINE_SCHEMA_INSTRUCTIONS{400000};
inline constexpr std::uint64_t MAX_INLINE_SCHEMA_DEPTH{44};

// What an inline compilation refused, carried out of the deferred body so that
// the answer names the reason rather than reporting a generic failure
struct InlineSchemaError final : std::exception {
  InlineSchemaError(const sourcemeta::core::HTTPStatus &status,
                    const std::string_view type, const char *detail)
      : status{status}, type{type}, detail_{detail} {}

  [[nodiscard]] auto what() const noexcept -> const char * override {
    return this->detail_;
  }

  sourcemeta::core::HTTPStatus status;
  std::string_view type;

private:
  const char *detail_;
};

// Resolve a reference from an inline schema the way this registry would answer
// it for whoever asked. What the caller may not read does not resolve, and
// neither does anything outside this instance
class InlineSchemaResolver {
public:
  InlineSchemaResolver(const RouterAction &action,
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

// Compile an inline schema under the budgets, resolving as the given caller.
// Whatever compilation refuses becomes the answer the caller is owed, since a
// schema they wrote failing to compile is a fact about their request
[[nodiscard]] inline auto compile_inline_schema(
    const RouterAction &action, const Authentication::Caller &caller,
    const sourcemeta::core::JSON &schema) -> sourcemeta::blaze::Template {
  const InlineSchemaResolver resolver{action, caller};
  const sourcemeta::blaze::Tweaks tweaks{.max_instructions =
                                             MAX_INLINE_SCHEMA_INSTRUCTIONS,
                                         .max_depth = MAX_INLINE_SCHEMA_DEPTH};

  try {
    return sourcemeta::blaze::compile(
        schema, sourcemeta::blaze::schema_walker, std::ref(resolver),
        sourcemeta::blaze::default_schema_compiler,
        sourcemeta::blaze::Mode::Exhaustive, "", "", "", tweaks,
        MAX_INLINE_SCHEMA_LOCATIONS);
  } catch (const sourcemeta::blaze::SchemaFrameLimitError &) {
    throw InlineSchemaError{sourcemeta::core::HTTP_STATUS_UNPROCESSABLE_CONTENT,
                            "urn:sourcemeta:one:schema-too-complex",
                            "The supplied schema is too complex to compile"};
  } catch (const sourcemeta::blaze::CompilerInstructionLimitError &) {
    throw InlineSchemaError{sourcemeta::core::HTTP_STATUS_UNPROCESSABLE_CONTENT,
                            "urn:sourcemeta:one:schema-too-complex",
                            "The supplied schema is too complex to compile"};
  } catch (const sourcemeta::blaze::CompilerDepthLimitError &) {
    throw InlineSchemaError{sourcemeta::core::HTTP_STATUS_UNPROCESSABLE_CONTENT,
                            "urn:sourcemeta:one:schema-too-complex",
                            "The supplied schema is too complex to compile"};
  } catch (const sourcemeta::blaze::SchemaResolutionError &) {
    throw InlineSchemaError{
        sourcemeta::core::HTTP_STATUS_BAD_REQUEST,
        "urn:sourcemeta:one:unresolvable-reference",
        "A reference in the supplied schema could not be resolved"};
  } catch (const sourcemeta::blaze::SchemaReferenceError &) {
    throw InlineSchemaError{
        sourcemeta::core::HTTP_STATUS_BAD_REQUEST,
        "urn:sourcemeta:one:unresolvable-reference",
        "A reference in the supplied schema could not be resolved"};
  } catch (const InlineSchemaError &) {
    throw;
  } catch (const std::exception &) {
    throw InlineSchemaError{sourcemeta::core::HTTP_STATUS_BAD_REQUEST,
                            "urn:sourcemeta:one:invalid-schema",
                            "The supplied schema could not be compiled"};
  }
}

// Answer a preflight or a method a schema POST route does not serve, reporting
// whether the request was answered here
[[nodiscard]] inline auto
schema_post_preamble(HTTPRequest &request, HTTPResponse &response,
                     const std::string_view error_schema) -> bool {
  if (request.method() == "options") {
    response.write_status(sourcemeta::core::HTTP_STATUS_NO_CONTENT);
    response.write_header("Access-Control-Allow-Origin", "*");
    response.write_header("Access-Control-Expose-Headers", "Link, ETag");
    response.write_header("Access-Control-Allow-Methods", "POST, OPTIONS");
    response.write_header("Access-Control-Allow-Headers", "Content-Type");
    response.write_header("Access-Control-Max-Age", "3600");
    // Browser preflight cache is governed by `Access-Control-Max-Age`;
    // `no-store` keeps shared HTTP caches from storing this response.
    response.write_header("Cache-Control", cache_control_no_store());
    // RFC 9110 §9.3.7: OPTIONS responses SHOULD include Allow. Different
    // audience than Access-Control-Allow-Methods (HTTP vs CORS preflight).
    // https://datatracker.ietf.org/doc/html/rfc9110#section-9.3.7
    response.write_header("Allow", "POST, OPTIONS");
    send_response(sourcemeta::core::HTTP_STATUS_NO_CONTENT, request, response);
    return true;
  }

  if (request.method() != "post") {
    json_error(request, response,
               sourcemeta::core::HTTP_STATUS_METHOD_NOT_ALLOWED,
               "urn:sourcemeta:one:method-not-allowed",
               "This HTTP method is invalid for this URL", error_schema, "*",
               "POST, OPTIONS");
    return true;
  }

  return false;
}

// Read a schema POST body and answer with whatever the callback makes of it.
// The body arrives once the request that carried it is gone, so whatever the
// callback needs from that request has to be owned by the time it runs
template <typename Perform>
auto schema_post_body(HTTPRequest &request, HTTPResponse &response,
                      const std::string_view response_schema,
                      const std::string_view error_schema,
                      const std::size_t max_body, Perform perform) -> void {
  // RFC 9110 §10.1.1: refuse unrecognised expectations with 417 before
  // touching the body. uWS already auto-acknowledged `100-continue`
  // upstream, so anything left here is a value we cannot honour.
  if (expect_header_unrecognised(request)) {
    json_error(request, response,
               sourcemeta::core::HTTP_STATUS_EXPECTATION_FAILED,
               "urn:sourcemeta:one:expectation-failed",
               "The Expect header carries an unsupported expectation",
               error_schema, "*");
    return;
  }

  // RFC 9110 §15.5.14: when the client declares a `Content-Length`
  // beyond the cap, fast-fail with 413 before scheduling the read.
  if (request_body_too_large(request, max_body)) {
    json_error(request, response,
               sourcemeta::core::HTTP_STATUS_CONTENT_TOO_LARGE,
               "urn:sourcemeta:one:payload-too-large",
               "The request body is too large", error_schema, "*");
    return;
  }

  request.body(
      // A throw here is intended and caught by the surrounding error
      // handler
      // NOLINTNEXTLINE(bugprone-exception-escape)
      [response_schema, error_schema, perform = std::move(perform)](
          HTTPRequest &callback_request, HTTPResponse &callback_response,
          std::string &&body, bool too_big) -> void {
        if (too_big) {
          json_error(callback_request, callback_response,
                     sourcemeta::core::HTTP_STATUS_CONTENT_TOO_LARGE,
                     "urn:sourcemeta:one:payload-too-large",
                     "The request body is too large", error_schema, "*");
          return;
        }

        if (body.empty()) {
          json_error(callback_request, callback_response,
                     sourcemeta::core::HTTP_STATUS_BAD_REQUEST,
                     "urn:sourcemeta:one:no-instance",
                     "You must pass an instance to validate against",
                     error_schema, "*");
          return;
        }

        try {
          const auto result{perform(body)};
          callback_response.write_status(sourcemeta::core::HTTP_STATUS_OK);
          callback_response.write_header("Content-Type", "application/json");
          callback_response.write_header("Access-Control-Allow-Origin", "*");
          callback_response.write_header("Access-Control-Expose-Headers",
                                         "Link, ETag");
          // The response is fully determined by the POST body. A
          // shared cache cannot use this for any other request, so
          // skip caching altogether.
          callback_response.write_header("Cache-Control",
                                         cache_control_no_store());
          write_link_header(callback_response, response_schema);
          std::ostringstream payload;
          sourcemeta::core::prettify(result, payload);
          send_response(sourcemeta::core::HTTP_STATUS_OK, callback_request,
                        callback_response, payload.str(), Encoding::Identity);
        } catch (const sourcemeta::core::JSONParseError &) {
          json_error(callback_request, callback_response,
                     sourcemeta::core::HTTP_STATUS_BAD_REQUEST,
                     "urn:sourcemeta:one:invalid-json",
                     "The request body is not valid JSON", error_schema, "*");
        } catch (const SchemaPostRequestError &error) {
          json_error(callback_request, callback_response,
                     sourcemeta::core::HTTP_STATUS_BAD_REQUEST,
                     "urn:sourcemeta:one:invalid-request", error.what(),
                     error_schema, "*");
        } catch (const InlineSchemaError &error) {
          json_error(callback_request, callback_response, error.status,
                     error.type, error.what(), error_schema, "*");
        } catch (const std::exception &exception) {
          json_error(callback_request, callback_response,
                     sourcemeta::core::HTTP_STATUS_INTERNAL_SERVER_ERROR,
                     "urn:sourcemeta:one:schema-evaluation-error",
                     exception.what(), error_schema, "*");
        }
      },
      [error_schema](HTTPRequest &callback_request,
                     HTTPResponse &callback_response,
                     const std::exception_ptr &error) -> void {
        try {
          std::rethrow_exception(error);
        } catch (const std::exception &exception) {
          json_error(callback_request, callback_response,
                     sourcemeta::core::HTTP_STATUS_INTERNAL_SERVER_ERROR,
                     "urn:sourcemeta:one:uncaught-error", exception.what(),
                     error_schema, "*");
        }
      },
      max_body);
}

} // namespace sourcemeta::one

#endif
