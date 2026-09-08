# A tool names a route, so a policy governing that route decides whether the
# tool is any use to a caller. What each view is offered is settled when its
# copy of the endpoint's metadata is written, rather than worked out per
# request, which is what keeps the listing and the dispatch from ever
# disagreeing: they read the same artifact.
#
# This sandbox gates the trace route with the vault key, so the tool backed by
# it is offered to that key and to nobody else.

# An anonymous caller is offered every tool but the one whose route is gated
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
```
{ "jsonrpc": "2.0", "id": 1, "method": "tools/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Captures]
anonymous_tools: body
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 1
jsonpath "$.result.tools" count == 11
jsonpath "$.result.tools[*].name" not contains "trace_schema_evaluation"
jsonpath "$.result.tools[*].name" not contains "playground_trace_schema"
jsonpath "$.result.tools[*].name" contains "search_schemas"
jsonpath "$.result.tools[*].name" contains "evaluate_schema"

POST {{base}}/self/v1/api/schemas/evaluate/self/v1/schemas/mcp/response
```
{{anonymous_tools}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# The key that opens the route is offered the tool as well
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
Authorization: Bearer vault-secret-key
```
{ "jsonrpc": "2.0", "id": 2, "method": "tools/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Captures]
admitted_tools: body
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 2
jsonpath "$.result.tools" count == 13
jsonpath "$.result.tools[*].name" contains "trace_schema_evaluation"
jsonpath "$.result.tools[*].name" contains "playground_trace_schema"

POST {{base}}/self/v1/api/schemas/evaluate/self/v1/schemas/mcp/response
```
{{admitted_tools}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# Naming the tool anyway reaches nothing. The artifact that leaves it out of
# the listing is the same one the dispatch reads, so there is no second check
# to forget and no gap between what is offered and what may be called
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
```
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "tools/call",
  "params": { "name": "trace_schema_evaluation", "arguments": {} }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Captures]
refused_call: body
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 3
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid tool name"

POST {{base}}/self/v1/api/schemas/evaluate/self/v1/schemas/mcp/response
```
{{refused_call}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A tool nothing gates is callable by anybody, so what is refused above is the
# policy rather than the surface
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
```
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "tools/call",
  "params": { "name": "list_directory", "arguments": { "path": "/open" } }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4
jsonpath "$.error" not exists
jsonpath "$.result.isError" == false

# And the HTTP route the tool stands for answers the same way, which is the
# agreement that was missing: a tool call used to reach an action the route
# gate would have refused
POST {{base}}/self/v1/api/schemas/trace/open/string
Content-Type: application/json
```
{ "foo": "bar" }
```
HTTP 401
Cache-Control: no-store
Content-Type: application/problem+json
WWW-Authenticate: Bearer realm="registry"
Link: </self/v1/schemas/api/error>; rel="describedby"
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag, WWW-Authenticate
[Captures]
route_denial: body
route_schema: header "Link" regex "<([^>]+)>"
{
  "type": "urn:sourcemeta:one:authentication-required",
  "title": "Unauthorized",
  "status": 401,
  "detail": "This resource requires authentication"
}

POST {{base}}/self/v1/api/schemas/evaluate{{route_schema}}
```
{{route_denial}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# The handshake follows the same view. A caller offered tools is told the
# server has them, so a client that trusts the capability flag and a client
# that reads the list are told the same thing
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
```
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-11-25",
    "capabilities": {},
    "clientInfo": { "name": "probe", "version": "1.0.0" }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Captures]
anonymous_initialize: body
[Asserts]
jsonpath "$.result.capabilities.tools" exists

POST {{base}}/self/v1/api/schemas/evaluate/self/v1/schemas/mcp/response
```
{{anonymous_initialize}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A tool the caller is offered carries its whole definition, so what is hidden
# is the tool rather than merely its name in a list
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
Authorization: Bearer vault-secret-key
```
{ "jsonrpc": "2.0", "id": 6, "method": "tools/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Asserts]
jsonpath "$.result.tools[?(@.name == 'trace_schema_evaluation')].description" exists
jsonpath "$.result.tools[?(@.name == 'trace_schema_evaluation')].inputSchema" exists

# The key opens the tool it was gated behind, end to end, so the listing is
# not merely cosmetic
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 7,
  "method": "tools/call",
  "params": {
    "name": "trace_schema_evaluation",
    "arguments": {
      "schema": "{{base}}/open/string",
      "stringifiedInstance": "\"hello\""
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.isError" == false

# A credential that opens nothing is not a credential, so a wrong key is
# offered exactly what a caller carrying nothing is offered
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
Authorization: Bearer not-any-key
```
{ "jsonrpc": "2.0", "id": 8, "method": "tools/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Asserts]
jsonpath "$.result.tools" count == 11
jsonpath "$.result.tools[*].name" not contains "trace_schema_evaluation"
jsonpath "$.result.tools[*].name" not contains "playground_trace_schema"

# And it cannot call it either, so falling back to the anonymous answer falls
# back to the narrowest one rather than a wider one
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
Authorization: Bearer not-any-key
```
{
  "jsonrpc": "2.0",
  "id": 9,
  "method": "tools/call",
  "params": {
    "name": "trace_schema_evaluation",
    "arguments": {
      "schema": "{{base}}/open/string",
      "stringifiedInstance": "\"hello\""
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Asserts]
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid tool name"

# Resources are unaffected by any of this, since a tool standing for a route is
# a different question from a schema the caller may read. This one still
# enumerates whatever the view holds, a full page at a time
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
```
{ "jsonrpc": "2.0", "id": 10, "method": "resources/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.resources" count == 50
jsonpath "$.result.nextCursor" == "50"
jsonpath "$.result.resources[*].uri" contains "{{base}}/open/string"
jsonpath "$.result.resources[*].uri" not contains "{{base}}/vault/secret"

# And under the key it holds the gated ones too, which is the split the tool
# list above has nothing to do with
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
Content-Type: application/json
MCP-Protocol-Version: 2025-11-25
Authorization: Bearer vault-secret-key
```
{ "jsonrpc": "2.0", "id": 11, "method": "resources/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.resources[*].uri" contains "{{base}}/vault/secret"
