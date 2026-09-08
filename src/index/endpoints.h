#ifndef SOURCEMETA_ONE_INDEX_ENDPOINTS_H
#define SOURCEMETA_ONE_INDEX_ENDPOINTS_H

#include <string_view> // std::string_view

namespace sourcemeta::one {

// Every route this instance serves, as a URI template relative to the instance
// root. The router is populated from here, and whatever else has to name the
// same endpoint reads it from here rather than spelling it again

inline constexpr std::string_view ENDPOINT_LIST_DIRECTORY{
    "/self/v1/api/list{/path*}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_DEPENDENCIES{
    "/self/v1/api/schemas/dependencies/{+schema}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_DEPENDENTS{
    "/self/v1/api/schemas/dependents/{+schema}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_HEALTH{
    "/self/v1/api/schemas/health/{+schema}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_LOCATIONS{
    "/self/v1/api/schemas/locations/{+schema}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_POSITIONS{
    "/self/v1/api/schemas/positions/{+schema}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_STATS{
    "/self/v1/api/schemas/stats/{+schema}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_METADATA{
    "/self/v1/api/schemas/metadata/{+schema}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_EVALUATE{
    "/self/v1/api/schemas/evaluate/{+schema}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_RDF{
    "/self/v1/api/schemas/rdf/{+schema}"};
inline constexpr std::string_view ENDPOINT_SCHEMA_TRACE{
    "/self/v1/api/schemas/trace/{+schema}"};
// Tracing against a schema the caller supplies rather than one this instance
// holds. Everything under the playground namespace compiles what a request
// carries rather than reading what was indexed, so an operator governs that
// whole capability, including whatever is added to it later, by naming the
// namespace alone
inline constexpr std::string_view ENDPOINT_PLAYGROUND_SCHEMA_TRACE{
    "/self/v1/api/playground/schemas/trace"};
inline constexpr std::string_view ENDPOINT_SCHEMA_SEARCH{
    "/self/v1/api/schemas/search"};
inline constexpr std::string_view ENDPOINT_HEALTH{"/self/v1/health"};
inline constexpr std::string_view ENDPOINT_METRICS{"/self/v1/metrics"};
inline constexpr std::string_view ENDPOINT_AUTH_LOGOUT{"/self/v1/auth/logout"};
inline constexpr std::string_view ENDPOINT_AUTH_LOGIN_PAGE{
    "/self/v1/auth/login"};
inline constexpr std::string_view ENDPOINT_AUTH_LOGIN{
    "/self/v1/auth/login/{policy}"};
inline constexpr std::string_view ENDPOINT_AUTH_CALLBACK{
    "/self/v1/auth/callback/{policy}"};
inline constexpr std::string_view ENDPOINT_MCP{"/self/v1/mcp"};
// Clients that normalise URLs by appending a slash reach the same handler
inline constexpr std::string_view ENDPOINT_MCP_TRAILING_SLASH{"/self/v1/mcp/"};
// RFC 9728 Section 3 forms this by inserting the well-known string between
// the host and the path of the resource it describes
inline constexpr std::string_view ENDPOINT_MCP_PRM{
    "/.well-known/oauth-protected-resource/self/v1/mcp"};
inline constexpr std::string_view ENDPOINT_MCP_PRM_TRAILING_SLASH{
    "/.well-known/oauth-protected-resource/self/v1/mcp/"};
inline constexpr std::string_view ENDPOINT_API_NOT_FOUND{"/self/v1/api/{+any}"};
inline constexpr std::string_view ENDPOINT_STATIC{"/self/v1/static/{+path}"};

// The path an authentication policy names when it means a route. A template
// expression matches whatever a caller puts there, so what a policy can be
// written against is the literal part ahead of it, and a scope reaching into
// the expression is a scope this instance cannot honour on every surface that
// reaches the route
[[nodiscard]] inline auto route_scope(const std::string_view uri_template)
    -> std::string_view {
  auto result{uri_template.substr(0, uri_template.find('{'))};
  if (result.size() > 1 && result.back() == '/') {
    result.remove_suffix(1);
  }

  return result;
}

} // namespace sourcemeta::one

#endif
