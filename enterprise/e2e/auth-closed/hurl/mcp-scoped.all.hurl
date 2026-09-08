# A policy may be narrower than the whole instance, and the `mcp` policy here
# governs the MCP endpoint alone while `registry` governs everything. A key
# from the narrow policy therefore opens the transport without opening the
# schema surface, and every JSON-RPC message it sends still has to be checked
# for well-formedness against a schema that lives on that closed surface.
# Checking it as if the caller had asked for it refused the instance its own
# bookkeeping and aborted the process, so a bare ping on this key was enough to
# take the server down. The instance owns those schemas rather than serving
# them here, and this file holds that apart: the narrow key is answered, the
# closed surface stays closed to it, and malformed messages are still rejected.

# The narrow key cannot read the schema surface, which is what makes the rest
# of this file meaningful rather than incidental
GET {{base}}/self/v1/schemas/mcp/request
Authorization: Bearer mcp-secret-key
HTTP 404
Cache-Control: no-store
Content-Type: application/problem+json
Link: </self/v1/schemas/api/error>; rel="describedby"
Access-Control-Allow-Origin: *
[Captures]
denied_body: body
error_schema: header "Link" regex "<([^>]+)>"
{
  "type": "urn:sourcemeta:one:not-found",
  "title": "Not Found",
  "status": 404,
  "detail": "There is nothing at this URL"
}

# The round-trip runs on the wide key, since the evaluate endpoint is itself
# behind the policy that closes the instance
POST {{base}}/self/v1/api/schemas/evaluate{{error_schema}}
Authorization: Bearer full-secret-key
```
{{denied_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A bare ping is the whole regression: it names no schema and reads no
# content, and it once aborted the process
POST {{base}}/self/v1/mcp
Authorization: Bearer mcp-secret-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 1, "method": "ping" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
Access-Control-Expose-Headers: Link, ETag
[Captures]
ping_body: body
mcp_schema: header "Link" regex "<([^>]+)>"
{
  "jsonrpc": "2.0",
  "id": 1,
  "result": {}
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer full-secret-key
```
{{ping_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# The handshake answers on the narrow key too, and it answers for that key
# rather than for the instance: this one reaches no tool, so the capability
# saying there are tools is not advertised to it. A client is spared asking for
# a list it would find empty
POST {{base}}/self/v1/mcp
Authorization: Bearer mcp-secret-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 2, "method": "initialize", "params": { "protocolVersion": "2025-11-25", "capabilities": {}, "clientInfo": { "name": "scoped", "version": "1" } } }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
initialize_body: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 2
jsonpath "$.result.protocolVersion" == "2025-11-25"
jsonpath "$.result.capabilities.resources" exists
jsonpath "$.result.capabilities.tools" not exists
jsonpath "$.result.serverInfo.name" == "sourcemeta-one-enterprise"
jsonpath "$.result.serverInfo.title" == "Sourcemeta One Enterprise"
jsonpath "$.result.serverInfo.websiteUrl" == "{{base}}"
jsonpath "$.result.instructions" contains "Fully Private Sandbox"

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer full-secret-key
```
{{initialize_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A tool stands for a route, and this key opens the transport rather than the
# routes behind it, so there is nothing here it may invoke. Offering the list
# anyway would describe a surface this caller cannot reach, and an agent
# reading it would spend its turns finding that out one refusal at a time
POST {{base}}/self/v1/mcp
Authorization: Bearer mcp-secret-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 3, "method": "tools/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
tools_body: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 3
jsonpath "$.result.tools" count == 0

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer full-secret-key
```
{{tools_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# The wide key is offered all of them, which is what makes the empty list above
# a fact about that key rather than about this instance. The two answers come
# from the same endpoint and differ only in who asked
POST {{base}}/self/v1/mcp
Authorization: Bearer full-secret-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 31, "method": "tools/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
wide_tools_body: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 31
jsonpath "$.result.tools" count == 13
jsonpath "$.result.tools[*].name" includes "list_directory"
jsonpath "$.result.tools[*].name" includes "search_schemas"
jsonpath "$.result.tools[*].name" includes "evaluate_schema"
jsonpath "$.result.tools[*].name" includes "trace_schema_evaluation"
jsonpath "$.result.tools[*].name" includes "playground_trace_schema"
jsonpath "$.result.tools[*].name" includes "instance_to_rdf"
jsonpath "$.result.tools[*].name" includes "get_schema_metadata"
jsonpath "$.result.tools[*].name" includes "get_schema_dependencies"
jsonpath "$.result.tools[*].name" includes "get_schema_dependents"
jsonpath "$.result.tools[*].name" includes "get_schema_health"
jsonpath "$.result.tools[*].name" includes "get_schema_locations"
jsonpath "$.result.tools[*].name" includes "get_schema_positions"
jsonpath "$.result.tools[*].name" includes "get_schema_stats"

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer full-secret-key
```
{{wide_tools_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# And what the wide key may name, it may call, so the listing is a promise
# rather than a description
POST {{base}}/self/v1/mcp
Authorization: Bearer full-secret-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 32, "method": "tools/call", "params": { "name": "list_directory", "arguments": { "path": "/" } } }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
wide_call_body: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 32
jsonpath "$.result.isError" == false

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer full-secret-key
```
{{wide_call_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# Answering the transport is not the same as opening the catalog. Every schema
# on this instance sits behind the wide policy, so the narrow key enumerates
# nothing and the empty list is the whole body
POST {{base}}/self/v1/mcp
Authorization: Bearer mcp-secret-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 4, "method": "resources/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
resources_body: body
[Asserts]
jsonpath "$.result.nextCursor" not exists
{
  "jsonrpc": "2.0",
  "id": 4,
  "result": {
    "resources": []
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer full-secret-key
```
{{resources_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# Naming a gated schema outright is refused rather than served
POST {{base}}/self/v1/mcp
Authorization: Bearer mcp-secret-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 5, "method": "resources/read", "params": { "uri": "{{base}}/catalog/classified" } }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
read_body: body
{
  "jsonrpc": "2.0",
  "id": 5,
  "error": {
    "code": -32002,
    "message": "Resource not found"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer full-secret-key
```
{{read_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# Naming one anyway reaches nothing. What the listing leaves out is what the
# dispatch reads, so the two cannot disagree and a guess buys nothing
POST {{base}}/self/v1/mcp
Authorization: Bearer mcp-secret-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 6, "method": "tools/call", "params": { "name": "list_directory", "arguments": { "path": "/" } } }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
call_body: body
{
  "jsonrpc": "2.0",
  "id": 6,
  "error": {
    "code": -32602,
    "message": "Invalid tool name",
    "data": "Use `tools/list` to discover the available tools"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer full-secret-key
```
{{call_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# Resolving those schemas apart from the caller must not stop them being
# applied, so a message the protocol forbids is still refused on the narrow key
POST {{base}}/self/v1/mcp
Authorization: Bearer mcp-secret-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": null, "method": "ping" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
malformed_body: body
{
  "jsonrpc": "2.0",
  "id": null,
  "error": {
    "code": -32600,
    "message": "Invalid Request"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
Authorization: Bearer full-secret-key
```
{{malformed_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A credential belonging to no policy is still refused at the transport
POST {{base}}/self/v1/mcp
Authorization: Bearer not-any-key
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 7, "method": "ping" }
```
HTTP 401
Cache-Control: no-store
Content-Type: application/problem+json
WWW-Authenticate: Bearer realm="registry", resource_metadata="{{base}}/.well-known/oauth-protected-resource/self/v1/mcp"
Link: </self/v1/schemas/api/error>; rel="describedby"
[Captures]
wrong_body: body
{
  "type": "urn:sourcemeta:one:authentication-required",
  "title": "Unauthorized",
  "status": 401,
  "detail": "This resource requires authentication"
}

POST {{base}}/self/v1/api/schemas/evaluate{{error_schema}}
Authorization: Bearer full-secret-key
```
{{wrong_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# The narrow policy reaches its own endpoint and no further, so the key that
# opens the transport does not open a sibling surface
GET {{base}}/self/v1/static/style.min.css
Authorization: Bearer mcp-secret-key
HTTP 401
Cache-Control: no-store
WWW-Authenticate: Bearer realm="registry"
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:authentication-required"
jsonpath "$.status" == 401

GET {{base}}/catalog/example.json
Authorization: Bearer mcp-secret-key
HTTP 404
Cache-Control: no-store
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:not-found"
jsonpath "$.status" == 404
