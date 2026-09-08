#ifndef SOURCEMETA_ONE_ROUTER_H
#define SOURCEMETA_ONE_ROUTER_H

#include <sourcemeta/blaze/compiler.h>
#include <sourcemeta/blaze/evaluator.h>
#include <sourcemeta/blaze/output.h>
#include <sourcemeta/core/json.h>
#include <sourcemeta/core/jsonrpc.h>
#include <sourcemeta/core/mcp.h>
#include <sourcemeta/core/uritemplate.h>

#include <sourcemeta/one/authentication.h>
#include <sourcemeta/one/http.h>
#include <sourcemeta/one/router_lru.h>

#include <cstddef>     // std::size_t
#include <cstdint>     // std::uint8_t
#include <filesystem>  // std::filesystem::path
#include <memory>      // std::make_unique, std::shared_ptr, std::unique_ptr
#include <mutex>       // std::once_flag
#include <optional>    // std::optional
#include <span>        // std::span
#include <string>      // std::string
#include <string_view> // std::string_view
#include <utility>     // std::move, std::pair
#include <vector>      // std::vector

namespace sourcemeta::one {

class Router;
class RouterAction;

// The body did not match what the route accepts
struct SchemaPostRequestError final : std::exception {
  [[nodiscard]] auto what() const noexcept -> const char * override {
    return "The request body does not match the expected schema";
  }
};

// What a playground compilation refused, carried out of the deferred body so
// the answer names the reason rather than reporting a generic failure
class PlaygroundSchemaError final : public std::exception {
public:
  PlaygroundSchemaError(const sourcemeta::core::HTTPStatus &status,
                        const std::string_view type, const char *detail)
      : status_{status}, type_{type}, detail_{detail} {}

  [[nodiscard]] auto what() const noexcept -> const char * override {
    return this->detail_;
  }

  [[nodiscard]] auto status() const noexcept
      -> const sourcemeta::core::HTTPStatus & {
    return this->status_;
  }

  [[nodiscard]] auto type() const noexcept -> std::string_view {
    return this->type_;
  }

private:
  sourcemeta::core::HTTPStatus status_;
  std::string_view type_;
  const char *detail_;
};

// The largest body a route that compiles what it carries will read, which is
// smaller than what a route reading a precomputed artifact accepts
inline constexpr std::size_t MAX_PLAYGROUND_REQUEST_BODY_BYTES{
    static_cast<std::size_t>(1) * 1024 * 1024};

// The cookie fields a request carried, held for as long as the credentials
// that view them. A request may present the field more than once, so every
// occurrence is kept rather than the first, and they are not joined, since
// what a cookie means is decided by whoever reads it
class RequestCookies {
public:
  explicit RequestCookies(const HTTPRequest &request) {
    request.header_values("cookie",
                          [this](const std::string_view value) -> void {
                            this->fields_.emplace_back(value);
                          });
  }

  // Storage for an asynchronous body, where the request is gone by the time
  // the credentials are read, so the fields must be owned rather than viewed
  explicit RequestCookies(const std::vector<std::string> &owned) {
    this->fields_.reserve(owned.size());
    for (const auto &field : owned) {
      this->fields_.emplace_back(field);
    }
  }

  // What this views has to outlive it, so it cannot be built from storage that
  // ends with the expression that built it
  explicit RequestCookies(std::vector<std::string> &&) = delete;

  [[nodiscard]] operator std::span<const std::string_view>() const & noexcept {
    return this->fields_;
  }

  // For the same reason, what it hands out cannot outlive it either, so a
  // temporary is refused rather than left to be read once it is gone
  operator std::span<const std::string_view>() const && = delete;

  // Whether the request carried no cookie at all, which is one of the two
  // things that make a caller anonymous
  [[nodiscard]] auto empty() const noexcept -> bool {
    return this->fields_.empty();
  }

private:
  std::vector<std::string_view> fields_;
};

// The same fields, copied, for a handler that outlives the request
[[nodiscard]] inline auto owned_cookies(const HTTPRequest &request)
    -> std::vector<std::string> {
  std::vector<std::string> result;
  request.header_values("cookie",
                        [&result](const std::string_view value) -> void {
                          result.emplace_back(value);
                        });
  return result;
}

// Proof that a path was produced by the artifact resolver. Only the
// action base class can mint one, so every artifact read must have
// passed through resolution by construction
class ResolvedArtifact {
public:
  [[nodiscard]] auto path() const noexcept -> const std::filesystem::path & {
    return this->path_;
  }

private:
  friend class RouterAction;
  explicit ResolvedArtifact(std::filesystem::path path)
      : path_{std::move(path)} {}
  std::filesystem::path path_;
};

// What a registry path came to for the caller who asked. There is no refusal
// here: a path the caller cannot reach resolves to nothing at all, since what
// a view does not hold and what was never there are one answer. Being refused
// a credential is a matter for the route gate, which speaks about the
// credential rather than about what the registry holds
struct ArtifactResolution {
  std::optional<ResolvedArtifact> path;
  // Whether the path is served to anonymous callers, as opposed to admitted
  // only because the caller presented a matching credential
  bool is_public{true};
};

class RouterAction {
public:
  RouterAction(const std::filesystem::path &index_directory,
               const std::string_view server_uri, Router &dispatcher)
      : index_directory_{index_directory}, server_uri_{server_uri},
        dispatcher_{dispatcher} {}
  virtual ~RouterAction() = default;

  // To avoid mistakes
  RouterAction(const RouterAction &) = delete;
  RouterAction(RouterAction &&) = delete;
  auto operator=(const RouterAction &) -> RouterAction & = delete;
  auto operator=(RouterAction &&) -> RouterAction & = delete;

  // Who is asking arrives already read, because a request resolves several
  // artifacts and every one of them asks the same question about the same
  // caller. Reading it where a path is built would place the same caller once
  // per artifact rather than once per request
  virtual auto rest(const std::span<std::string_view> matches,
                    const Authentication::Caller &caller, HTTPRequest &request,
                    HTTPResponse &response) -> void = 0;

  // The caller rather than the bearer alone, since a browser reaching a tool is
  // admitted by its session cookie and would otherwise pass the gate and then
  // be refused by whatever the tool resolves on its behalf
  virtual auto mcp(const sourcemeta::core::MCPProtocolVersion version,
                   const sourcemeta::core::JSON &request_id,
                   const sourcemeta::core::JSON &arguments,
                   const Authentication::Caller &caller)
      -> sourcemeta::core::JSON = 0;

  // Whether this route stays reachable no matter which policies cover its path.
  // A route that a caller must reach in order to establish authentication
  // cannot itself sit behind that authentication, so it opts out of the gate
  // and guards itself instead. The default denies the exemption
  [[nodiscard]] virtual auto is_authentication_exempt() const noexcept -> bool {
    return false;
  }

  // What this route adds to the challenge it is denied with, beyond the realm.
  // A route whose credential comes from somewhere a caller has no way to guess
  // says where that is here, so a denial is actionable rather than a dead end.
  // The default adds nothing
  [[nodiscard]] virtual auto authentication_challenge() const noexcept
      -> std::span<const std::pair<std::string_view, std::string_view>> {
    return {};
  }

  // The audience a presented token must name to reach this route, beyond
  // whatever the admitting policy already requires. A route that is a resource
  // in its own right says so here, so that a token issued for something wider
  // does not reach it. The default requires nothing
  [[nodiscard]] virtual auto required_audience() const noexcept
      -> std::string_view {
    return {};
  }

  // Renew, in place, the lapsed session of a browser that navigated into a
  // dead end, whether it was refused outright or found nothing there,
  // returning true when it wrote the response so the caller stops. Nothing
  // else is offered here, since signing in is somewhere a caller goes rather
  // than something a dead end hands them. Machines, non-navigations and
  // callers with nothing to renew fall through to whatever the caller would
  // have answered
  [[nodiscard]] auto serve_renewal_page(HTTPRequest &request,
                                        HTTPResponse &response) const -> bool;

  // Send a browser that has signed in before back to its provider, to be asked
  // whether that sign-in still stands, rather than asking the person again
  [[nodiscard]] auto serve_renewal(HTTPRequest &request,
                                   HTTPResponse &response) const -> bool;

  [[nodiscard]] auto server_uri() const noexcept -> std::string_view {
    return this->server_uri_;
  }

  [[nodiscard]] auto dispatcher() const noexcept -> Router & {
    return this->dispatcher_;
  }

  enum class Tree : std::uint8_t { Schemas, Explorer };

  struct BrowserSecurityHeaders {
    // W3C Referrer Policy (https://www.w3.org/TR/referrer-policy/)
    std::string_view referrer_policy{};
    // W3C CSP Level 3 §6.4.2
    // (https://www.w3.org/TR/CSP3/#directive-frame-ancestors) Value is the
    // directive's source-list (e.g. `'none'`, `'self'`, an origin allowlist).
    // The full header value is composed as `frame-ancestors <value>`.
    std::string_view frame_ancestors{};
    // RFC 7034 (https://datatracker.ietf.org/doc/html/rfc7034)
    // Legacy clickjacking control for browsers that predate CSP3
    // frame-ancestors. Value is one of "DENY", "SAMEORIGIN", or
    // "ALLOW-FROM <uri>".
    std::string_view x_frame_options{};
  };

  // Browser-targeted security headers we apply to every HTML response:
  //
  // - Referrer-Policy (W3C Referrer Policy):
  //   https://www.w3.org/TR/referrer-policy/
  //   Send full URL on same-origin navigation, only the origin on
  //   cross-origin navigation. Schema paths within the browser encode the
  //   user's current view and would otherwise leak via every external link
  //   click.
  //
  // - Content-Security-Policy frame-ancestors (W3C CSP Level 3 §6.4.2):
  //   https://www.w3.org/TR/CSP3/#directive-frame-ancestors
  //   Modern clickjacking control: deny embedding the web UI in any
  //   iframe.
  //
  // - X-Frame-Options (RFC 7034):
  //   https://datatracker.ietf.org/doc/html/rfc7034
  //   Legacy clickjacking control for browsers that predate CSP3
  //   frame-ancestors. Belt-and-suspenders for old client coverage at
  //   near-zero header cost.
  //
  // JSON and static-asset responses pass a default-constructed (all-empty)
  // instance and emit none of these.
  static constexpr BrowserSecurityHeaders HTML_BROWSER_SECURITY{
      .referrer_policy = "strict-origin-when-cross-origin",
      .frame_ancestors = "'none'",
      .x_frame_options = "DENY",
  };

  // The tree decides whether a view applies, since the unit tree holds one
  // answer whoever asks, so a caller names who they are and nothing else
  [[nodiscard]] auto artifact_resolve_path(const Authentication::Caller &caller,
                                           std::string_view input, Tree tree,
                                           std::string_view artifact_name) const
      -> ArtifactResolution;

  // Place a caller from credentials this action is holding rather than from the
  // request it arrived on. A deferred body outlives its request, so what it
  // presented has to be owned and read again once the body is there
  [[nodiscard]] auto
  caller_from(const Authentication::Credentials &credentials) const
      -> Authentication::Caller;

  [[nodiscard]] auto artifact_read_json(const ResolvedArtifact &artifact) const
      -> std::optional<sourcemeta::core::JSON>;

  auto artifact_serve(const ResolvedArtifact &artifact,
                      const sourcemeta::core::HTTPStatus &status,
                      bool enable_cors, std::string_view mime,
                      std::string_view link,
                      const BrowserSecurityHeaders &browser_security,
                      HTTPRequest &request, HTTPResponse &response,
                      std::string_view error_schema,
                      std::string_view cache_control,
                      std::string_view vary) const -> void;

  // Validate against one of this instance's own structural schemas, such as
  // the envelope a request has to match before it is acted on. Those are this
  // instance's bookkeeping rather than catalog content and are never handed to
  // the caller, so they resolve without the gate. Passing a caller's
  // credential here instead would refuse whoever was admitted to a route but
  // not to `/self`, which is a policy shape an operator may reasonably write
  [[nodiscard]] auto structural_evaluate(std::string_view schema_uri,
                                         const sourcemeta::core::JSON &instance,
                                         sourcemeta::blaze::Mode mode) const
      -> std::pair<bool, sourcemeta::core::JSON>;

  [[nodiscard]] auto
  structural_evaluate_fast(std::string_view schema_uri,
                           const sourcemeta::core::JSON &instance) const
      -> bool;

  [[nodiscard]] auto
  schema_evaluate_fast(const Authentication::Caller &caller,
                       std::string_view schema_uri,
                       const sourcemeta::core::JSON &instance) const -> bool;

  [[nodiscard]] auto schema_evaluate(const Authentication::Caller &caller,
                                     std::string_view schema_uri,
                                     const sourcemeta::core::JSON &instance,
                                     sourcemeta::blaze::Mode mode) const
      -> std::pair<bool, sourcemeta::core::JSON>;

  [[nodiscard]] auto schema_evaluate_with_tracing(
      const Authentication::Caller &caller, std::string_view schema_uri,
      const sourcemeta::core::JSON &instance,
      const sourcemeta::blaze::TraceOutput::Callback &callback) const -> bool;

  // Where a request points within this instance, in the one spelling the gate
  // and the artifact tree both read, or nothing when it points outside
  [[nodiscard]] auto canonical_path(std::string_view input) const
      -> std::optional<Authentication::Path>;

  // Compile a schema the caller supplied under the budgets that bound what a
  // request may spend, resolving its references as that caller. Whatever
  // compilation refuses becomes the answer they are owed, since a schema they
  // wrote failing to compile is a fact about their request
  [[nodiscard]] auto
  compile_playground_schema(const Authentication::Caller &caller,
                            const sourcemeta::core::JSON &schema) const
      -> sourcemeta::blaze::Template;

  // Answer a preflight or a method a schema POST route does not serve,
  // reporting whether the request was answered here
  [[nodiscard]] auto schema_post_preamble(HTTPRequest &request,
                                          HTTPResponse &response,
                                          std::string_view error_schema) const
      -> bool;

  // Read a schema POST body and answer with whatever the callback makes of it.
  // The body arrives once the request that carried it is gone, so whatever the
  // callback needs from that request has to be owned by the time it runs
  template <typename Perform>
  auto schema_post_body(HTTPRequest &request, HTTPResponse &response,
                        const std::string_view response_schema,
                        const std::string_view error_schema,
                        const std::size_t max_body, Perform perform) const
      -> void {
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
          } catch (const PlaygroundSchemaError &error) {
            json_error(callback_request, callback_response, error.status(),
                       error.type(), error.what(), error_schema, "*");
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

protected:
  // Resolution for trees that are not registry content, such as the
  // compile-time static asset bundle. Same containment discipline as
  // registry resolution, against a caller-declared root, but access to
  // these trees is governed at the route level, as their identity is a
  // URL rather than a registry path. Existence is left to the serving
  // layer, which orders its method check before the existence check
  [[nodiscard]] auto artifact_resolve_static(const std::filesystem::path &root,
                                             std::string_view relative) const
      -> ArtifactResolution;

  // Locate an artifact without consulting the gate, for the ones that are this
  // instance speaking about itself rather than registry content: the metadata
  // read at action construction, where no request and therefore no caller
  // exists, and the pages that stand in for content nobody is being served. A
  // view still has to be named, since a page that speaks to a caller speaks in
  // the terms of the view they resolve to. Never reach for this to serve
  // anything the registry holds
  [[nodiscard]] auto artifact_resolve_path_unauthenticated(
      std::string_view view, std::string_view input, Tree tree,
      std::string_view artifact_name) const -> std::optional<ResolvedArtifact>;

  // The compiled form of a schema this registry holds, as the caller may see
  // it. An action that evaluates against a template it obtained some other way
  // reaches for this to evaluate against a catalog schema on the same terms
  [[nodiscard]] auto blaze_template(const Authentication::Caller &caller,
                                    std::string_view schema_uri,
                                    sourcemeta::blaze::Mode mode) const
      -> std::shared_ptr<const sourcemeta::blaze::Template>;

private:
  [[nodiscard]] auto artifact_locate(const Authentication::Path &path,
                                     Tree tree, std::string_view view,
                                     std::string_view artifact_name) const
      -> std::optional<std::filesystem::path>;

  [[nodiscard]] auto structural_template(std::string_view schema_uri,
                                         sourcemeta::blaze::Mode mode) const
      -> std::shared_ptr<const sourcemeta::blaze::Template>;

  // NOLINTNEXTLINE(cppcoreguidelines-avoid-const-or-ref-data-members)
  const std::filesystem::path &index_directory_;
  std::string_view server_uri_;
  // NOLINTNEXTLINE(cppcoreguidelines-avoid-const-or-ref-data-members)
  Router &dispatcher_;
};

using RouterActionConstructor =
    auto (*)(const std::filesystem::path &,
             const sourcemeta::core::URITemplateRouterView &,
             sourcemeta::core::URITemplateRouter::Identifier, Router &)
        -> std::unique_ptr<RouterAction>;

template <typename T>
auto make_router_action(
    const std::filesystem::path &base,
    const sourcemeta::core::URITemplateRouterView &router,
    const sourcemeta::core::URITemplateRouter::Identifier identifier,
    Router &dispatcher) -> std::unique_ptr<RouterAction> {
  return std::make_unique<T>(base, router, identifier, dispatcher);
}

class Router {
public:
  Router(const std::filesystem::path &base,
         const core::URITemplateRouterView &router,
         std::span<const RouterActionConstructor> constructors);
  ~Router() = default;

  // To avoid mistakes
  Router(const Router &) = delete;
  Router(Router &&) = delete;
  auto operator=(const Router &) -> Router & = delete;
  auto operator=(Router &&) -> Router & = delete;

  auto dispatch(const core::URITemplateRouter::Identifier identifier,
                const core::URITemplateRouter::Identifier context,
                const std::span<std::string_view> matches, HTTPRequest &request,
                HTTPResponse &response) -> void;

  [[nodiscard]] auto
  action(const core::URITemplateRouter::Identifier identifier,
         const core::URITemplateRouter::Identifier context) -> RouterAction *;

  [[nodiscard]] auto
  action(const core::URITemplateRouter::Identifier identifier)
      -> RouterAction *;

  auto error(const HTTPRequest &request, HTTPResponse &response,
             const sourcemeta::core::HTTPStatus &status, std::string_view type,
             std::string_view detail, std::string_view origin) const -> void;

  [[nodiscard]] auto blaze_template(const ResolvedArtifact &artifact)
      -> std::shared_ptr<const sourcemeta::blaze::Template>;

  [[nodiscard]] auto authentication() const noexcept -> const Authentication & {
    return this->authentication_;
  }

private:
  static constexpr std::size_t TEMPLATE_CACHE_CAPACITY{50};

  struct Slot {
    std::unique_ptr<RouterAction> instance;
    std::once_flag flag;
  };

  // NOLINTNEXTLINE(cppcoreguidelines-avoid-const-or-ref-data-members)
  const std::filesystem::path &base_;
  // NOLINTNEXTLINE(cppcoreguidelines-avoid-const-or-ref-data-members)
  const core::URITemplateRouterView &router_;
  std::span<const RouterActionConstructor> constructors_;
  // NOLINTNEXTLINE(modernize-avoid-c-arrays)
  std::unique_ptr<Slot[]> slots_;
  std::size_t slots_size_;
  std::string_view default_error_schema_;
  RouterLRU<std::filesystem::path, sourcemeta::blaze::Template> template_cache_{
      TEMPLATE_CACHE_CAPACITY};
  Authentication authentication_;
};

} // namespace sourcemeta::one

#endif
