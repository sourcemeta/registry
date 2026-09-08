#include <sourcemeta/core/http.h>
#include <sourcemeta/core/jose.h>
#include <sourcemeta/core/uri.h>
#include <sourcemeta/one/router.h>

#include <chrono>      // std::chrono::seconds
#include <cstdint>     // std::uint8_t
#include <memory>      // std::make_unique
#include <mutex>       // std::call_once
#include <optional>    // std::optional, std::nullopt
#include <string>      // std::string
#include <string_view> // std::string_view
#include <vector>      // std::vector

namespace sourcemeta::one {

namespace {

// The one way authentication reaches a provider from a running server. It is
// composed here rather than inside the module, so what may touch a network is
// decided by whoever stands the server up
auto provider_fetcher() -> Authentication::Fetcher {
  return [](Authentication::ProviderRequest &&incoming)
             -> std::optional<Authentication::ProviderResponse> {
    try {
      const auto posting{!incoming.body.empty()};
      sourcemeta::core::HTTPSystemRequest request{
          std::string{incoming.url}, posting
                                         ? sourcemeta::core::HTTPMethod::POST
                                         : sourcemeta::core::HTTPMethod::GET};
      request.connect_timeout(std::chrono::seconds{2});
      request.timeout(std::chrono::seconds{5});
      request.maximum_response_size(1024UL * 1024UL);
      request.follow_redirects(false);
      if (!incoming.authorization.empty()) {
        request.header("authorization", std::move(incoming.authorization));
      }

      if (posting) {
        request.body(std::move(incoming.body),
                     "application/x-www-form-urlencoded");
      }

      const auto response{request.send()};
      std::optional<std::chrono::seconds> max_age;
      const auto header{sourcemeta::core::http_header_find(response.headers,
                                                           "cache-control")};
      if (header.has_value()) {
        max_age = sourcemeta::core::http_cache_control_max_age(header.value());
      }

      return Authentication::ProviderResponse{
          .status = static_cast<std::uint32_t>(response.status.code),
          .body = response.body,
          .max_age = max_age};
    } catch (...) {
      return std::nullopt;
    }
  };
}

} // namespace

Router::Router(const std::filesystem::path &base,
               const sourcemeta::core::URITemplateRouterView &router,
               const std::span<const RouterActionConstructor> constructors)
    : base_{base}, router_{router}, constructors_{constructors},
      // NOLINTNEXTLINE(modernize-avoid-c-arrays)
      slots_{std::make_unique<Slot[]>(router.size() + 1)},
      slots_size_{router.size() + 1},
      authentication_{
          sourcemeta::one::Authentication::Table{base / "authentication.bin"},
          provider_fetcher()} {
  // Only whoever holds the handler table knows how many there can be
  sourcemeta::one::http_metrics().start(constructors.size());
  router.arguments(0, [this](const auto &key, const auto &value) -> void {
    if (key == "errorSchema") {
      this->default_error_schema_ = std::get<std::string_view>(value);
    }
  });
}

auto Router::error(const sourcemeta::one::HTTPRequest &request,
                   sourcemeta::one::HTTPResponse &response,
                   const sourcemeta::core::HTTPStatus &status,
                   const std::string_view type, const std::string_view detail,
                   const std::string_view origin) const -> void {
  sourcemeta::one::json_error(request, response, status, type, detail,
                              this->default_error_schema_, origin);
}

auto Router::action(
    const sourcemeta::core::URITemplateRouter::Identifier identifier,
    const sourcemeta::core::URITemplateRouter::Identifier context)
    -> RouterAction * {
  if (identifier >= this->slots_size_ || context >= this->constructors_.size())
      [[unlikely]] {
    return nullptr;
  }

  auto &slot{this->slots_[identifier]};
  std::call_once(slot.flag, [this, &slot, context, identifier]() -> void {
    slot.instance = this->constructors_[context](this->base_, this->router_,
                                                 identifier, *this);
  });

  return slot.instance.get();
}

auto Router::action(
    const sourcemeta::core::URITemplateRouter::Identifier identifier)
    -> RouterAction * {
  if (identifier >= this->slots_size_) [[unlikely]] {
    return nullptr;
  }
  return this->action(identifier, this->router_.context(identifier));
}

auto Router::dispatch(
    const sourcemeta::core::URITemplateRouter::Identifier identifier,
    const sourcemeta::core::URITemplateRouter::Identifier context,
    const std::span<std::string_view> matches,
    sourcemeta::one::HTTPRequest &request,
    sourcemeta::one::HTTPResponse &response) -> void {
  // Which handler answers is the one thing about a request that only routing
  // knows, so it is the one thing said here
  request.observation().handler = static_cast<std::uint8_t>(context);

  auto *instance{this->action(identifier, context)};
  if (instance == nullptr) [[unlikely]] {
    this->error(request, response,
                sourcemeta::core::HTTP_STATUS_NOT_IMPLEMENTED,
                "urn:sourcemeta:one:unknown-action",
                "This version does not implement such action handler for "
                "this URL",
                "*");
    return;
  }

  const auto credential{
      sourcemeta::core::http_parse_bearer(request.header("authorization"))};

  // Identifier zero is the catch-all, whose content the content gate
  // authorises after canonicalising the URL. Explicit routes are reached by
  // exact literal match, so the surface gate authorises them on their literal
  // path. A CORS preflight is never gated, and neither is a route that must
  // stay reachable to establish authentication in the first place, which
  // vouches for itself instead
  // An explicit route is matched on the request target literally, so the gate
  // authorises that same spelling rather than the location it resolves to. A
  // target reaching past a governed prefix is therefore still governed by it,
  // while one that merely addresses content relative to its own route is not
  const RequestCookies cookies{request};
  // Read once here, since the same caller is served every artifact this request
  // reaches and every gate question asked of them afterwards is a comparison
  // against this rather than another reading of what they presented
  const auto caller{
      this->authentication_.caller({.bearer = credential, .cookies = cookies})};
  if (identifier != 0 && request.method() != "options" &&
      !instance->is_authentication_exempt() &&
      !this->authentication_.permits(
          Authentication::RouteTarget{request.path()}, caller,
          instance->required_audience())) {
    if (instance->serve_renewal_page(request, response)) {
      return;
    }

    sourcemeta::one::json_error_unauthorized(
        request, response, this->default_error_schema_, "*",
        instance->authentication_challenge());
    return;
  }

  instance->rest(matches, caller, request, response);
}

// A dead end only becomes a silent renewal when the browser carries the marker
// a previous sign-in left, and only under a policy that governs the path it
// reached. Both matter: without the first every stranger would be sent to a
// provider they have no account with, and without the second a stale marker
// would send somebody to a provider whose answer could not admit them here,
// which would leave them where they started and go round again
auto RouterAction::serve_renewal(sourcemeta::one::HTTPRequest &request,
                                 sourcemeta::one::HTTPResponse &response) const
    -> bool {
  const RequestCookies cookies{request};
  const auto path{
      Authentication::Path::parse(request.path(), this->server_uri())};
  if (!path.has_value()) {
    return false;
  }

  const auto policy{this->dispatcher().authentication().renewal(
      path.value(), {.cookies = cookies})};
  if (!policy.has_value()) {
    return false;
  }

  // Where a login begins is this instance's own layout, so it is composed here
  // rather than answered from elsewhere. The denied page is named outright
  // rather than left to a referrer, which a redirect carries from wherever the
  // browser came from rather than from the page it is being sent away from
  std::string location{""};
  location += "/self/v1/auth/login/";
  location += policy.value();
  location += "?silent=1&to=";
  sourcemeta::core::URI::escape(request.path(), location);
  response.write_status(sourcemeta::core::HTTP_STATUS_SEE_OTHER);
  response.write_header("Location", location);
  response.write_header("Cache-Control",
                        sourcemeta::one::cache_control_no_store());
  sourcemeta::one::send_response(sourcemeta::core::HTTP_STATUS_SEE_OTHER,
                                 request, response);
  return true;
}

auto RouterAction::serve_renewal_page(
    sourcemeta::one::HTTPRequest &request,
    sourcemeta::one::HTTPResponse &response) const -> bool {
  if ((request.method() != "get" && request.method() != "head") ||
      !sourcemeta::one::prefers_html(request.header("accept"))) {
    return false;
  }

  // A browser that signed in before is asked of its provider rather than of
  // the person, so an expired session renews without anybody noticing. Nothing
  // else is offered in its place, since signing in is somewhere a caller goes
  // rather than something a dead end hands them
  return this->serve_renewal(request, response);
}

auto RouterAction::schema_post_preamble(
    HTTPRequest &request, HTTPResponse &response,
    const std::string_view error_schema) const -> bool {
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

} // namespace sourcemeta::one
