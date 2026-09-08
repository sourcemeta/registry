# A JWT is the credential the MCP authorization model is written around: a
# token from an authorization server, presented in `Authorization`, bound to an
# audience. Every other MCP test here presents a static key instead, so this
# file covers the combination the specification actually describes.
#
# The instance declares four `jwt` policies, and the pair that matters is
# `machine` and `strict`: they name the *same* audience and differ only in the
# signature algorithm they accept. A token that satisfies one must therefore be
# refused by the other, which is what proves an audience alone does not admit.

# The provider issues a signed token for the audience the `machine` policy names
POST https://keycloak:8443/realms/main/protocol/openid-connect/token
[FormParams]
grant_type: client_credentials
client_id: ci-service
client_secret: ci-service-secret
HTTP 200
[Captures]
machine_token: jsonpath "$.access_token"
[Asserts]
jsonpath "$.token_type" == "Bearer"
jsonpath "$.access_token" matches /^[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/

# A token opens the MCP transport exactly as a key does, since the transport
# only cares that a bearer arrived
POST {{base}}/self/v1/mcp
Authorization: Bearer {{machine_token}}
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 1, "method": "ping" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
ping_body: body
mcp_schema: header "Link" regex "<([^>]+)>"
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {}
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer {{machine_token}}
```
{{ping_body}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# The catalog a token sees is the anonymous one plus exactly what its policy
# gates. The instance holds 63 resources reachable without a credential, and
# this token adds one, so the count is the whole assertion: anything else
# admitted or withheld moves it
POST {{base}}/self/v1/mcp
Authorization: Bearer {{machine_token}}
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 2, "method": "resources/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
list_body: body
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 2
jsonpath "$.error" not exists
jsonpath "$.result.resources" count == 50
jsonpath "$.result.nextCursor" == "50"
jsonpath "$.result.resources[0].uri" == "{{base}}/machine/config"
jsonpath "$.result.resources[0].name" == "/machine/config"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 259
jsonpath "$.result.resources[0].annotations.priority" == 0.5
jsonpath "$.result.resources[1].uri" == "{{base}}/orphan/lonely"
jsonpath "$.result.resources[2].uri" == "{{base}}/public/string"

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer {{machine_token}}
```
{{list_body}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# The second page completes the catalog, so the two together are everything
# this token may see. Nothing gated by another policy appears on either page,
# which a single-page assertion could never establish
POST {{base}}/self/v1/mcp
Authorization: Bearer {{machine_token}}
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "resources/list",
  "params": { "cursor": "50" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
page_two_body: body
[Asserts]
jsonpath "$.result.resources" count == 20
jsonpath "$.result.nextCursor" not exists
jsonpath "$.result.resources[*].uri" not includes "{{base}}/strict/rule"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/typed/thing"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/telemetry/metric"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/private/secret"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/internal/handbook"

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer {{machine_token}}
```
{{page_two_body}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# `/strict` names the same audience as `/machine` and accepts ES256 alone, so
# this token is refused there on the signature algorithm. Its schema exists, so
# what comes back says so rather than being an empty collection
POST {{base}}/self/v1/mcp
Authorization: Bearer {{machine_token}}
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "resources/read",
  "params": { "uri": "{{base}}/strict/rule" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
strict_denial: body
{
  "jsonrpc": "2.0",
  "id": 4,
  "error": {
    "code": -32002,
    "message": "Resource not found"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer {{machine_token}}
```
{{strict_denial}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# Reading a resource the token does admit returns it
POST {{base}}/self/v1/mcp
Authorization: Bearer {{machine_token}}
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "resources/read",
  "params": { "uri": "{{base}}/machine/config" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
admitted_read: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/machine/config"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer {{machine_token}}
```
{{admitted_read}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# A denial reached through a tool is a tool error rather than a transport one,
# so a client keeps the session and learns only that this one call failed
POST {{base}}/self/v1/mcp
Authorization: Bearer {{machine_token}}
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 6,
  "method": "tools/call",
  "params": {
    "name": "get_schema_metadata",
    "arguments": { "schema": "{{base}}/private/secret" }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
tool_denial: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.isError" == true

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer {{machine_token}}
```
{{tool_denial}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# The same tool on a location the token admits runs, and says so by naming the
# outcome rather than by leaving it out
POST {{base}}/self/v1/mcp
Authorization: Bearer {{machine_token}}
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 7,
  "method": "tools/call",
  "params": {
    "name": "get_schema_metadata",
    "arguments": { "schema": "{{base}}/machine/config" }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
tool_success: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.isError" == false
jsonpath "$.result.structuredContent" exists

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer {{machine_token}}
```
{{tool_success}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# A token this instance cannot verify buys exactly what presenting nothing buys
POST {{base}}/self/v1/mcp
Authorization: Bearer not-a-token-at-all
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 8,
  "method": "resources/read",
  "params": { "uri": "{{base}}/machine/config" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
malformed_denial: body
{
  "jsonrpc": "2.0",
  "id": 8,
  "error": {
    "code": -32002,
    "message": "Resource not found"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{malformed_denial}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# A structurally valid token from an issuer nobody here trusts is refused the
# same way, so what decides is the signature rather than the shape
POST {{base}}/self/v1/mcp
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJodHRwczovL2ltcG9zdGVyLmV4YW1wbGUiLCJhdWQiOiJodHRwczovL3NjaGVtYXMuZXhhbXBsZS5jb20ifQ.c2lnbmF0dXJlLXRoYXQtbm9ib2R5LWhlcmUtaXNzdWVk
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 9,
  "method": "resources/read",
  "params": { "uri": "{{base}}/machine/config" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
forged_denial: body
{
  "jsonrpc": "2.0",
  "id": 9,
  "error": {
    "code": -32002,
    "message": "Resource not found"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{forged_denial}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# The preflight describes what the endpoint accepts. A browser only ever
# reaches this from the instance's own origin, since any other is refused
# outright by the origin check this endpoint is required to make, so what is
# pinned here is that the description stays accurate rather than that it
# unblocks a caller
OPTIONS {{base}}/self/v1/mcp
Origin: {{base}}
Access-Control-Request-Method: POST
Access-Control-Request-Headers: authorization
HTTP 204
Cache-Control: no-store
Allow: POST, OPTIONS
[Asserts]
header "Access-Control-Allow-Headers" == "Authorization, Content-Type, MCP-Protocol-Version"
header "Access-Control-Allow-Methods" == "POST, OPTIONS"
header "Access-Control-Allow-Origin" == "{{base}}"
header "Access-Control-Max-Age" == "3600"
bytes count == 0
