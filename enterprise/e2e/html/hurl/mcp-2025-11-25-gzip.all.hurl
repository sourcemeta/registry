POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": "ping-identity", "method": "ping" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
header "Content-Encoding" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "ping-identity"
jsonpath "$.result" isObject
jsonpath "$.result" isEmpty

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Accept-Encoding: gzip
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": "ping-gzip", "method": "ping" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Content-Encoding: gzip
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "ping-gzip"
jsonpath "$.result" isObject
jsonpath "$.result" isEmpty

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": "init-identity",
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-11-25",
    "capabilities": {},
    "clientInfo": { "name": "hurl", "version": "1.0.0" }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
header "Content-Encoding" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "init-identity"
jsonpath "$.result.protocolVersion" == "2025-11-25"
jsonpath "$.result.capabilities.resources" isObject
jsonpath "$.result.capabilities.resources" isEmpty
jsonpath "$.result.serverInfo.name" == "sourcemeta-one-enterprise"
jsonpath "$.result.serverInfo.title" == "Sourcemeta One Enterprise"
jsonpath "$.result.serverInfo.version" matches "^.+$"
jsonpath "$.result.serverInfo.description" == "The next-generation JSON Schema platform"
jsonpath "$.result.serverInfo.websiteUrl" == "{{base}}"
jsonpath "$.result.instructions" matches "^This is an instance of Sourcemeta One"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Accept-Encoding: gzip
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": "init-gzip",
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-11-25",
    "capabilities": {},
    "clientInfo": { "name": "hurl", "version": "1.0.0" }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Content-Encoding: gzip
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "init-gzip"
jsonpath "$.result.protocolVersion" == "2025-11-25"
jsonpath "$.result.capabilities.resources" isObject
jsonpath "$.result.capabilities.resources" isEmpty
jsonpath "$.result.serverInfo.name" == "sourcemeta-one-enterprise"
jsonpath "$.result.serverInfo.title" == "Sourcemeta One Enterprise"
jsonpath "$.result.serverInfo.version" matches "^.+$"
jsonpath "$.result.serverInfo.description" == "The next-generation JSON Schema platform"
jsonpath "$.result.serverInfo.websiteUrl" == "{{base}}"
jsonpath "$.result.instructions" matches "^This is an instance of Sourcemeta One"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": "tools-identity", "method": "tools/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
header "Content-Encoding" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "tools-identity"
jsonpath "$.result.tools" count == 13
jsonpath "$.result.tools[0].name" == "list_directory"
jsonpath "$.result.tools[0].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.tools[0].inputSchema.type" == "object"
jsonpath "$.result.tools[0].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/request"
jsonpath "$.result.tools[0].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[0].outputSchema.type" == "object"
jsonpath "$.result.tools[0].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/response"
jsonpath "$.result.tools[0].annotations.title" == "List Directory"
jsonpath "$.result.tools[0].annotations.readOnlyHint" == true
jsonpath "$.result.tools[0].annotations.destructiveHint" == false
jsonpath "$.result.tools[0].annotations.idempotentHint" == true
jsonpath "$.result.tools[0].annotations.openWorldHint" == false
jsonpath "$.result.tools[1].name" == "get_schema_dependencies"
jsonpath "$.result.tools[1].description" == "List the schemas this schema directly or transitively references, the outgoing edges of the dependency graph"
jsonpath "$.result.tools[1].inputSchema.type" == "object"
jsonpath "$.result.tools[1].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/request"
jsonpath "$.result.tools[1].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[1].outputSchema.type" == "object"
jsonpath "$.result.tools[1].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/response"
jsonpath "$.result.tools[1].annotations.title" == "Get Schema Dependencies"
jsonpath "$.result.tools[1].annotations.readOnlyHint" == true
jsonpath "$.result.tools[1].annotations.destructiveHint" == false
jsonpath "$.result.tools[1].annotations.idempotentHint" == true
jsonpath "$.result.tools[1].annotations.openWorldHint" == false
jsonpath "$.result.tools[2].name" == "get_schema_dependents"
jsonpath "$.result.tools[2].description" == "List the schemas that directly or transitively reference this schema, the incoming edges of the dependency graph"
jsonpath "$.result.tools[2].inputSchema.type" == "object"
jsonpath "$.result.tools[2].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/request"
jsonpath "$.result.tools[2].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[2].outputSchema.type" == "object"
jsonpath "$.result.tools[2].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/response"
jsonpath "$.result.tools[2].annotations.title" == "Get Schema Dependents"
jsonpath "$.result.tools[2].annotations.readOnlyHint" == true
jsonpath "$.result.tools[2].annotations.destructiveHint" == false
jsonpath "$.result.tools[2].annotations.idempotentHint" == true
jsonpath "$.result.tools[2].annotations.openWorldHint" == false
jsonpath "$.result.tools[3].name" == "get_schema_health"
jsonpath "$.result.tools[3].description" == "Return the lint health score (0 to 100) and any lint findings for a schema in the catalog"
jsonpath "$.result.tools[3].inputSchema.type" == "object"
jsonpath "$.result.tools[3].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/request"
jsonpath "$.result.tools[3].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[3].outputSchema.type" == "object"
jsonpath "$.result.tools[3].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/response"
jsonpath "$.result.tools[3].annotations.title" == "Get Schema Health"
jsonpath "$.result.tools[3].annotations.readOnlyHint" == true
jsonpath "$.result.tools[3].annotations.destructiveHint" == false
jsonpath "$.result.tools[3].annotations.idempotentHint" == true
jsonpath "$.result.tools[3].annotations.openWorldHint" == false
jsonpath "$.result.tools[4].name" == "get_schema_locations"
jsonpath "$.result.tools[4].description" == "Return every URI exposed by a schema, including subschemas and anchors, with their parent and base URI relationships. The response carries per-pointer metadata and grows with the schema's pointer count, so substantial payloads are expected for large schemas"
jsonpath "$.result.tools[4].inputSchema.type" == "object"
jsonpath "$.result.tools[4].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/request"
jsonpath "$.result.tools[4].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[4].outputSchema.type" == "object"
jsonpath "$.result.tools[4].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/response"
jsonpath "$.result.tools[4].annotations.title" == "Get Schema Locations"
jsonpath "$.result.tools[4].annotations.readOnlyHint" == true
jsonpath "$.result.tools[4].annotations.destructiveHint" == false
jsonpath "$.result.tools[4].annotations.idempotentHint" == true
jsonpath "$.result.tools[4].annotations.openWorldHint" == false
jsonpath "$.result.tools[5].name" == "get_schema_positions"
jsonpath "$.result.tools[5].description" == "Return the source line and column position of every JSON Pointer inside a schema"
jsonpath "$.result.tools[5].inputSchema.type" == "object"
jsonpath "$.result.tools[5].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/request"
jsonpath "$.result.tools[5].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[5].outputSchema.type" == "object"
jsonpath "$.result.tools[5].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/response"
jsonpath "$.result.tools[5].annotations.title" == "Get Schema Positions"
jsonpath "$.result.tools[5].annotations.readOnlyHint" == true
jsonpath "$.result.tools[5].annotations.destructiveHint" == false
jsonpath "$.result.tools[5].annotations.idempotentHint" == true
jsonpath "$.result.tools[5].annotations.openWorldHint" == false
jsonpath "$.result.tools[6].name" == "get_schema_stats"
jsonpath "$.result.tools[6].description" == "Return per-vocabulary keyword usage statistics for a schema in the catalog, identifying which JSON Schema keywords the schema relies on and how often each appears"
jsonpath "$.result.tools[6].inputSchema.type" == "object"
jsonpath "$.result.tools[6].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/request"
jsonpath "$.result.tools[6].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[6].outputSchema.type" == "object"
jsonpath "$.result.tools[6].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/response"
jsonpath "$.result.tools[6].annotations.title" == "Get Schema Stats"
jsonpath "$.result.tools[6].annotations.readOnlyHint" == true
jsonpath "$.result.tools[6].annotations.destructiveHint" == false
jsonpath "$.result.tools[6].annotations.idempotentHint" == true
jsonpath "$.result.tools[6].annotations.openWorldHint" == false
jsonpath "$.result.tools[7].name" == "get_schema_metadata"
jsonpath "$.result.tools[7].description" == "Return navigation metadata for a schema in the catalog, including title, description, dialect, byte size, dependency count, and breadcrumb path"
jsonpath "$.result.tools[7].inputSchema.type" == "object"
jsonpath "$.result.tools[7].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/request"
jsonpath "$.result.tools[7].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[7].outputSchema.type" == "object"
jsonpath "$.result.tools[7].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/response"
jsonpath "$.result.tools[7].annotations.title" == "Get Schema Metadata"
jsonpath "$.result.tools[7].annotations.readOnlyHint" == true
jsonpath "$.result.tools[7].annotations.destructiveHint" == false
jsonpath "$.result.tools[7].annotations.idempotentHint" == true
jsonpath "$.result.tools[7].annotations.openWorldHint" == false
jsonpath "$.result.tools[8].name" == "evaluate_schema"
jsonpath "$.result.tools[8].description" == "Validate a JSON instance against a schema and return whether it is valid plus any errors"
jsonpath "$.result.tools[8].inputSchema.type" == "object"
jsonpath "$.result.tools[8].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/request"
jsonpath "$.result.tools[8].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[8].outputSchema.type" == "object"
jsonpath "$.result.tools[8].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/response"
jsonpath "$.result.tools[8].annotations.title" == "Evaluate Schema"
jsonpath "$.result.tools[8].annotations.readOnlyHint" == true
jsonpath "$.result.tools[8].annotations.destructiveHint" == false
jsonpath "$.result.tools[8].annotations.idempotentHint" == true
jsonpath "$.result.tools[8].annotations.openWorldHint" == false
jsonpath "$.result.tools[9].name" == "instance_to_rdf"
jsonpath "$.result.tools[9].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.tools[9].inputSchema.type" == "object"
jsonpath "$.result.tools[9].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/request"
jsonpath "$.result.tools[9].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[9].outputSchema.type" == "object"
jsonpath "$.result.tools[9].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/response"
jsonpath "$.result.tools[9].annotations.title" == "Instance To Rdf"
jsonpath "$.result.tools[9].annotations.readOnlyHint" == true
jsonpath "$.result.tools[9].annotations.destructiveHint" == false
jsonpath "$.result.tools[9].annotations.idempotentHint" == true
jsonpath "$.result.tools[9].annotations.openWorldHint" == false
jsonpath "$.result.tools[10].name" == "trace_schema_evaluation"
jsonpath "$.result.tools[10].description" == "Validate a JSON instance against a schema and return a step-by-step trace of the evaluation. The trace can be substantial, so prefer non-tracing evaluation when only a valid or invalid verdict is needed and use this when per-step detail is required"
jsonpath "$.result.tools[10].inputSchema.type" == "object"
jsonpath "$.result.tools[10].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"
jsonpath "$.result.tools[10].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[10].outputSchema.type" == "object"
jsonpath "$.result.tools[10].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"
jsonpath "$.result.tools[10].annotations.title" == "Trace Schema Evaluation"
jsonpath "$.result.tools[10].annotations.readOnlyHint" == true
jsonpath "$.result.tools[10].annotations.destructiveHint" == false
jsonpath "$.result.tools[10].annotations.idempotentHint" == true
jsonpath "$.result.tools[10].annotations.openWorldHint" == false
jsonpath "$.result.tools[11].name" == "playground_trace_schema"
jsonpath "$.result.tools[11].description" == "Validate a JSON instance against a schema the caller supplies in the request rather than one this catalog holds, and return a step-by-step trace of the evaluation. References to schemas in this catalog are resolved as far as the caller may read them, and references to anywhere else are refused"
jsonpath "$.result.tools[11].inputSchema.type" == "object"
jsonpath "$.result.tools[11].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/request"
jsonpath "$.result.tools[11].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[11].outputSchema.type" == "object"
jsonpath "$.result.tools[11].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/response"
jsonpath "$.result.tools[11].annotations.title" == "Playground Trace Schema"
jsonpath "$.result.tools[11].annotations.readOnlyHint" == true
jsonpath "$.result.tools[11].annotations.destructiveHint" == false
jsonpath "$.result.tools[11].annotations.idempotentHint" == true
jsonpath "$.result.tools[11].annotations.openWorldHint" == false
jsonpath "$.result.tools[12].name" == "search_schemas"
jsonpath "$.result.tools[12].description" == "Search for schemas by query term"
jsonpath "$.result.tools[12].inputSchema.type" == "object"
jsonpath "$.result.tools[12].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/request"
jsonpath "$.result.tools[12].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[12].outputSchema.type" == "object"
jsonpath "$.result.tools[12].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/response"
jsonpath "$.result.tools[12].annotations.title" == "Search Schemas"
jsonpath "$.result.tools[12].annotations.readOnlyHint" == true
jsonpath "$.result.tools[12].annotations.destructiveHint" == false
jsonpath "$.result.tools[12].annotations.idempotentHint" == true
jsonpath "$.result.tools[12].annotations.openWorldHint" == false

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Accept-Encoding: gzip
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": "tools-gzip", "method": "tools/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Content-Encoding: gzip
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "tools-gzip"
jsonpath "$.result.tools" count == 13
jsonpath "$.result.tools[0].name" == "list_directory"
jsonpath "$.result.tools[0].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.tools[0].inputSchema.type" == "object"
jsonpath "$.result.tools[0].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/request"
jsonpath "$.result.tools[0].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[0].outputSchema.type" == "object"
jsonpath "$.result.tools[0].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/response"
jsonpath "$.result.tools[0].annotations.title" == "List Directory"
jsonpath "$.result.tools[0].annotations.readOnlyHint" == true
jsonpath "$.result.tools[0].annotations.destructiveHint" == false
jsonpath "$.result.tools[0].annotations.idempotentHint" == true
jsonpath "$.result.tools[0].annotations.openWorldHint" == false
jsonpath "$.result.tools[1].name" == "get_schema_dependencies"
jsonpath "$.result.tools[1].description" == "List the schemas this schema directly or transitively references, the outgoing edges of the dependency graph"
jsonpath "$.result.tools[1].inputSchema.type" == "object"
jsonpath "$.result.tools[1].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/request"
jsonpath "$.result.tools[1].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[1].outputSchema.type" == "object"
jsonpath "$.result.tools[1].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/response"
jsonpath "$.result.tools[1].annotations.title" == "Get Schema Dependencies"
jsonpath "$.result.tools[1].annotations.readOnlyHint" == true
jsonpath "$.result.tools[1].annotations.destructiveHint" == false
jsonpath "$.result.tools[1].annotations.idempotentHint" == true
jsonpath "$.result.tools[1].annotations.openWorldHint" == false
jsonpath "$.result.tools[2].name" == "get_schema_dependents"
jsonpath "$.result.tools[2].description" == "List the schemas that directly or transitively reference this schema, the incoming edges of the dependency graph"
jsonpath "$.result.tools[2].inputSchema.type" == "object"
jsonpath "$.result.tools[2].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/request"
jsonpath "$.result.tools[2].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[2].outputSchema.type" == "object"
jsonpath "$.result.tools[2].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/response"
jsonpath "$.result.tools[2].annotations.title" == "Get Schema Dependents"
jsonpath "$.result.tools[2].annotations.readOnlyHint" == true
jsonpath "$.result.tools[2].annotations.destructiveHint" == false
jsonpath "$.result.tools[2].annotations.idempotentHint" == true
jsonpath "$.result.tools[2].annotations.openWorldHint" == false
jsonpath "$.result.tools[3].name" == "get_schema_health"
jsonpath "$.result.tools[3].description" == "Return the lint health score (0 to 100) and any lint findings for a schema in the catalog"
jsonpath "$.result.tools[3].inputSchema.type" == "object"
jsonpath "$.result.tools[3].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/request"
jsonpath "$.result.tools[3].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[3].outputSchema.type" == "object"
jsonpath "$.result.tools[3].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/response"
jsonpath "$.result.tools[3].annotations.title" == "Get Schema Health"
jsonpath "$.result.tools[3].annotations.readOnlyHint" == true
jsonpath "$.result.tools[3].annotations.destructiveHint" == false
jsonpath "$.result.tools[3].annotations.idempotentHint" == true
jsonpath "$.result.tools[3].annotations.openWorldHint" == false
jsonpath "$.result.tools[4].name" == "get_schema_locations"
jsonpath "$.result.tools[4].description" == "Return every URI exposed by a schema, including subschemas and anchors, with their parent and base URI relationships. The response carries per-pointer metadata and grows with the schema's pointer count, so substantial payloads are expected for large schemas"
jsonpath "$.result.tools[4].inputSchema.type" == "object"
jsonpath "$.result.tools[4].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/request"
jsonpath "$.result.tools[4].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[4].outputSchema.type" == "object"
jsonpath "$.result.tools[4].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/response"
jsonpath "$.result.tools[4].annotations.title" == "Get Schema Locations"
jsonpath "$.result.tools[4].annotations.readOnlyHint" == true
jsonpath "$.result.tools[4].annotations.destructiveHint" == false
jsonpath "$.result.tools[4].annotations.idempotentHint" == true
jsonpath "$.result.tools[4].annotations.openWorldHint" == false
jsonpath "$.result.tools[5].name" == "get_schema_positions"
jsonpath "$.result.tools[5].description" == "Return the source line and column position of every JSON Pointer inside a schema"
jsonpath "$.result.tools[5].inputSchema.type" == "object"
jsonpath "$.result.tools[5].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/request"
jsonpath "$.result.tools[5].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[5].outputSchema.type" == "object"
jsonpath "$.result.tools[5].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/response"
jsonpath "$.result.tools[5].annotations.title" == "Get Schema Positions"
jsonpath "$.result.tools[5].annotations.readOnlyHint" == true
jsonpath "$.result.tools[5].annotations.destructiveHint" == false
jsonpath "$.result.tools[5].annotations.idempotentHint" == true
jsonpath "$.result.tools[5].annotations.openWorldHint" == false
jsonpath "$.result.tools[6].name" == "get_schema_stats"
jsonpath "$.result.tools[6].description" == "Return per-vocabulary keyword usage statistics for a schema in the catalog, identifying which JSON Schema keywords the schema relies on and how often each appears"
jsonpath "$.result.tools[6].inputSchema.type" == "object"
jsonpath "$.result.tools[6].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/request"
jsonpath "$.result.tools[6].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[6].outputSchema.type" == "object"
jsonpath "$.result.tools[6].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/response"
jsonpath "$.result.tools[6].annotations.title" == "Get Schema Stats"
jsonpath "$.result.tools[6].annotations.readOnlyHint" == true
jsonpath "$.result.tools[6].annotations.destructiveHint" == false
jsonpath "$.result.tools[6].annotations.idempotentHint" == true
jsonpath "$.result.tools[6].annotations.openWorldHint" == false
jsonpath "$.result.tools[7].name" == "get_schema_metadata"
jsonpath "$.result.tools[7].description" == "Return navigation metadata for a schema in the catalog, including title, description, dialect, byte size, dependency count, and breadcrumb path"
jsonpath "$.result.tools[7].inputSchema.type" == "object"
jsonpath "$.result.tools[7].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/request"
jsonpath "$.result.tools[7].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[7].outputSchema.type" == "object"
jsonpath "$.result.tools[7].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/response"
jsonpath "$.result.tools[7].annotations.title" == "Get Schema Metadata"
jsonpath "$.result.tools[7].annotations.readOnlyHint" == true
jsonpath "$.result.tools[7].annotations.destructiveHint" == false
jsonpath "$.result.tools[7].annotations.idempotentHint" == true
jsonpath "$.result.tools[7].annotations.openWorldHint" == false
jsonpath "$.result.tools[8].name" == "evaluate_schema"
jsonpath "$.result.tools[8].description" == "Validate a JSON instance against a schema and return whether it is valid plus any errors"
jsonpath "$.result.tools[8].inputSchema.type" == "object"
jsonpath "$.result.tools[8].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/request"
jsonpath "$.result.tools[8].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[8].outputSchema.type" == "object"
jsonpath "$.result.tools[8].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/response"
jsonpath "$.result.tools[8].annotations.title" == "Evaluate Schema"
jsonpath "$.result.tools[8].annotations.readOnlyHint" == true
jsonpath "$.result.tools[8].annotations.destructiveHint" == false
jsonpath "$.result.tools[8].annotations.idempotentHint" == true
jsonpath "$.result.tools[8].annotations.openWorldHint" == false
jsonpath "$.result.tools[9].name" == "instance_to_rdf"
jsonpath "$.result.tools[9].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.tools[9].inputSchema.type" == "object"
jsonpath "$.result.tools[9].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/request"
jsonpath "$.result.tools[9].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[9].outputSchema.type" == "object"
jsonpath "$.result.tools[9].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/response"
jsonpath "$.result.tools[9].annotations.title" == "Instance To Rdf"
jsonpath "$.result.tools[9].annotations.readOnlyHint" == true
jsonpath "$.result.tools[9].annotations.destructiveHint" == false
jsonpath "$.result.tools[9].annotations.idempotentHint" == true
jsonpath "$.result.tools[9].annotations.openWorldHint" == false
jsonpath "$.result.tools[10].name" == "trace_schema_evaluation"
jsonpath "$.result.tools[10].description" == "Validate a JSON instance against a schema and return a step-by-step trace of the evaluation. The trace can be substantial, so prefer non-tracing evaluation when only a valid or invalid verdict is needed and use this when per-step detail is required"
jsonpath "$.result.tools[10].inputSchema.type" == "object"
jsonpath "$.result.tools[10].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"
jsonpath "$.result.tools[10].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[10].outputSchema.type" == "object"
jsonpath "$.result.tools[10].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"
jsonpath "$.result.tools[10].annotations.title" == "Trace Schema Evaluation"
jsonpath "$.result.tools[10].annotations.readOnlyHint" == true
jsonpath "$.result.tools[10].annotations.destructiveHint" == false
jsonpath "$.result.tools[10].annotations.idempotentHint" == true
jsonpath "$.result.tools[10].annotations.openWorldHint" == false
jsonpath "$.result.tools[11].name" == "playground_trace_schema"
jsonpath "$.result.tools[11].description" == "Validate a JSON instance against a schema the caller supplies in the request rather than one this catalog holds, and return a step-by-step trace of the evaluation. References to schemas in this catalog are resolved as far as the caller may read them, and references to anywhere else are refused"
jsonpath "$.result.tools[11].inputSchema.type" == "object"
jsonpath "$.result.tools[11].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/request"
jsonpath "$.result.tools[11].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[11].outputSchema.type" == "object"
jsonpath "$.result.tools[11].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/response"
jsonpath "$.result.tools[11].annotations.title" == "Playground Trace Schema"
jsonpath "$.result.tools[11].annotations.readOnlyHint" == true
jsonpath "$.result.tools[11].annotations.destructiveHint" == false
jsonpath "$.result.tools[11].annotations.idempotentHint" == true
jsonpath "$.result.tools[11].annotations.openWorldHint" == false
jsonpath "$.result.tools[12].name" == "search_schemas"
jsonpath "$.result.tools[12].description" == "Search for schemas by query term"
jsonpath "$.result.tools[12].inputSchema.type" == "object"
jsonpath "$.result.tools[12].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/request"
jsonpath "$.result.tools[12].inputSchema['$comment']" == "MCP clients should resolve `$ref` references in input schemas by default. If yours does not, call `resources/read` on the `$ref` URL above to fetch the full input schema that defines this tool's parameters. This server is a JSON Schema registry, so every `$ref` URL is itself reachable as an MCP resource"
jsonpath "$.result.tools[12].outputSchema.type" == "object"
jsonpath "$.result.tools[12].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/response"
jsonpath "$.result.tools[12].annotations.title" == "Search Schemas"
jsonpath "$.result.tools[12].annotations.readOnlyHint" == true
jsonpath "$.result.tools[12].annotations.destructiveHint" == false
jsonpath "$.result.tools[12].annotations.idempotentHint" == true
jsonpath "$.result.tools[12].annotations.openWorldHint" == false

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": "call-identity",
  "method": "tools/call",
  "params": {
    "name": "get_schema_health",
    "arguments": { "schema": "{{base}}/test/bare/01" }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
text: jsonpath "$.result.content[0].text"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
header "Content-Encoding" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "call-identity"
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.content[0].type" == "text"
jsonpath "$.result.structuredContent.score" == 0
jsonpath "$.result.structuredContent.errors" count == 3
variable "text" jsonpath "$.score" == 0
variable "text" jsonpath "$.errors" count == 3

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Accept-Encoding: gzip
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": "call-gzip",
  "method": "tools/call",
  "params": {
    "name": "get_schema_health",
    "arguments": { "schema": "{{base}}/test/bare/01" }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Content-Encoding: gzip
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
text: jsonpath "$.result.content[0].text"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "call-gzip"
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.content[0].type" == "text"
jsonpath "$.result.structuredContent.score" == 0
jsonpath "$.result.structuredContent.errors" count == 3
variable "text" jsonpath "$.score" == 0
variable "text" jsonpath "$.errors" count == 3

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": "rlist-identity",
  "method": "resources/list",
  "params": { "cursor": "100" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
header "Content-Encoding" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "rlist-identity"
jsonpath "$.result.resources" count == 44
jsonpath "$.result.resources[0].uri" == "{{base}}/self/v1/schemas/mcp/notifications/cancelled"
jsonpath "$.result.resources[0].name" == "Sourcemeta One MCP Cancelled Notification"
jsonpath "$.result.resources[0].description" == "Cancellation hint from a client for an in-flight request. Sourcemeta One accepts and discards these"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 1163
jsonpath "$.result.resources[0].annotations.priority" == 0
jsonpath "$.result.resources[1].uri" == "{{base}}/self/v1/schemas/mcp/notifications/initialized"
jsonpath "$.result.resources[1].name" == "Sourcemeta One MCP Initialized Notification"
jsonpath "$.result.resources[1].description" == "Client signal that the handshake is complete and normal operation may begin"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 740
jsonpath "$.result.resources[1].annotations.priority" == 0
jsonpath "$.result.resources[2].uri" == "{{base}}/self/v1/schemas/mcp/ping/request"
jsonpath "$.result.resources[2].name" == "Sourcemeta One MCP Ping Request"
jsonpath "$.result.resources[2].description" == "Liveness check from a client"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 695
jsonpath "$.result.resources[2].annotations.priority" == 0
jsonpath "$.result.resources[3].uri" == "{{base}}/self/v1/schemas/mcp/ping/response"
jsonpath "$.result.resources[3].name" == "Sourcemeta One MCP Ping Response"
jsonpath "$.result.resources[3].description" == "Sourcemeta One's response to a liveness check"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 598
jsonpath "$.result.resources[3].annotations.priority" == 0
jsonpath "$.result.resources[4].uri" == "{{base}}/self/v1/schemas/mcp/prm/response"
jsonpath "$.result.resources[4].name" == "Sourcemeta One MCP Protected Resource Metadata Response"
jsonpath "$.result.resources[4].description" == "The OAuth 2.0 Protected Resource Metadata describing where a token for this instance's Model Context Protocol endpoint is obtained, as defined by RFC 9728"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 2176
jsonpath "$.result.resources[4].annotations.priority" == 0
jsonpath "$.result.resources[5].uri" == "{{base}}/self/v1/schemas/mcp/request"
jsonpath "$.result.resources[5].name" == "Sourcemeta One MCP Request"
jsonpath "$.result.resources[5].description" == "Any incoming MCP request the server accepts. The body may be a single JSON-RPC envelope or a JSON-RPC 2.0 batch (an array of envelopes) on protocol version `2025-03-26`"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 2520
jsonpath "$.result.resources[5].annotations.priority" == 0
jsonpath "$.result.resources[6].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/request"
jsonpath "$.result.resources[6].name" == "Sourcemeta One MCP Resources List Request"
jsonpath "$.result.resources[6].description" == "Request from a client to list MCP resources"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 1071
jsonpath "$.result.resources[6].annotations.priority" == 0
jsonpath "$.result.resources[7].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/response"
jsonpath "$.result.resources[7].name" == "Sourcemeta One MCP Resources List Response"
jsonpath "$.result.resources[7].description" == "Sourcemeta One's list of MCP resources"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 3062
jsonpath "$.result.resources[7].annotations.priority" == 0
jsonpath "$.result.resources[8].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/request"
jsonpath "$.result.resources[8].name" == "Sourcemeta One MCP Resources Read Request"
jsonpath "$.result.resources[8].description" == "Request from a client to read an MCP resource"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 1293
jsonpath "$.result.resources[8].annotations.priority" == 0
jsonpath "$.result.resources[9].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/response"
jsonpath "$.result.resources[9].name" == "Sourcemeta One MCP Resources Read Response"
jsonpath "$.result.resources[9].description" == "Sourcemeta One's response containing an MCP resource"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 1754
jsonpath "$.result.resources[9].annotations.priority" == 0
jsonpath "$.result.resources[10].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/request"
jsonpath "$.result.resources[10].name" == "Sourcemeta One MCP Resources Templates List Request"
jsonpath "$.result.resources[10].description" == "Request from a client to list MCP resource templates"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 922
jsonpath "$.result.resources[10].annotations.priority" == 0
jsonpath "$.result.resources[11].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/response"
jsonpath "$.result.resources[11].name" == "Sourcemeta One MCP Resources Templates List Response"
jsonpath "$.result.resources[11].description" == "Sourcemeta One's list of MCP resource templates"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 2927
jsonpath "$.result.resources[11].annotations.priority" == 0
jsonpath "$.result.resources[12].uri" == "{{base}}/self/v1/schemas/mcp/response"
jsonpath "$.result.resources[12].name" == "Sourcemeta One MCP Response"
jsonpath "$.result.resources[12].description" == "Any outgoing MCP response the server returns"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 4799
jsonpath "$.result.resources[12].annotations.priority" == 0
jsonpath "$.result.resources[13].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/request"
jsonpath "$.result.resources[13].name" == "Sourcemeta One Schema Evaluate RPC Input"
jsonpath "$.result.resources[13].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 1566
jsonpath "$.result.resources[13].annotations.priority" == 0
jsonpath "$.result.resources[14].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/response"
jsonpath "$.result.resources[14].name" == "Sourcemeta One Schema Evaluate RPC Output"
jsonpath "$.result.resources[14].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 441
jsonpath "$.result.resources[14].annotations.priority" == 0
jsonpath "$.result.resources[15].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/request"
jsonpath "$.result.resources[15].name" == "Sourcemeta One Schema Dependencies RPC Input"
jsonpath "$.result.resources[15].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 687
jsonpath "$.result.resources[15].annotations.priority" == 0
jsonpath "$.result.resources[16].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/response"
jsonpath "$.result.resources[16].name" == "Sourcemeta One Schema Dependencies RPC Output"
jsonpath "$.result.resources[16].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 741
jsonpath "$.result.resources[16].annotations.priority" == 0
jsonpath "$.result.resources[17].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/request"
jsonpath "$.result.resources[17].name" == "Sourcemeta One Schema Dependents RPC Input"
jsonpath "$.result.resources[17].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 683
jsonpath "$.result.resources[17].annotations.priority" == 0
jsonpath "$.result.resources[18].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/response"
jsonpath "$.result.resources[18].name" == "Sourcemeta One Schema Dependents RPC Output"
jsonpath "$.result.resources[18].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 735
jsonpath "$.result.resources[18].annotations.priority" == 0
jsonpath "$.result.resources[19].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/request"
jsonpath "$.result.resources[19].name" == "Sourcemeta One Schema Health RPC Input"
jsonpath "$.result.resources[19].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 668
jsonpath "$.result.resources[19].annotations.priority" == 0
jsonpath "$.result.resources[20].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/response"
jsonpath "$.result.resources[20].name" == "Sourcemeta One Schema Health RPC Output"
jsonpath "$.result.resources[20].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[20].mimeType" == "application/schema+json"
jsonpath "$.result.resources[20].size" == 415
jsonpath "$.result.resources[20].annotations.priority" == 0
jsonpath "$.result.resources[21].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/request"
jsonpath "$.result.resources[21].name" == "Sourcemeta One Schema Locations RPC Input"
jsonpath "$.result.resources[21].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[21].mimeType" == "application/schema+json"
jsonpath "$.result.resources[21].size" == 720
jsonpath "$.result.resources[21].annotations.priority" == 0
jsonpath "$.result.resources[22].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/response"
jsonpath "$.result.resources[22].name" == "Sourcemeta One Schema Locations RPC Output"
jsonpath "$.result.resources[22].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[22].mimeType" == "application/schema+json"
jsonpath "$.result.resources[22].size" == 471
jsonpath "$.result.resources[22].annotations.priority" == 0
jsonpath "$.result.resources[23].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/request"
jsonpath "$.result.resources[23].name" == "Sourcemeta One Schema Metadata RPC Input"
jsonpath "$.result.resources[23].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[23].mimeType" == "application/schema+json"
jsonpath "$.result.resources[23].size" == 666
jsonpath "$.result.resources[23].annotations.priority" == 0
jsonpath "$.result.resources[24].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/response"
jsonpath "$.result.resources[24].name" == "Sourcemeta One Schema Metadata RPC Output"
jsonpath "$.result.resources[24].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[24].mimeType" == "application/schema+json"
jsonpath "$.result.resources[24].size" == 843
jsonpath "$.result.resources[24].annotations.priority" == 0
jsonpath "$.result.resources[25].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/request"
jsonpath "$.result.resources[25].name" == "Sourcemeta One Schema Positions RPC Input"
jsonpath "$.result.resources[25].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[25].mimeType" == "application/schema+json"
jsonpath "$.result.resources[25].size" == 682
jsonpath "$.result.resources[25].annotations.priority" == 0
jsonpath "$.result.resources[26].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/response"
jsonpath "$.result.resources[26].name" == "Sourcemeta One Schema Positions RPC Output"
jsonpath "$.result.resources[26].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[26].mimeType" == "application/schema+json"
jsonpath "$.result.resources[26].size" == 435
jsonpath "$.result.resources[26].annotations.priority" == 0
jsonpath "$.result.resources[27].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/request"
jsonpath "$.result.resources[27].name" == "Sourcemeta One Schema Statistics RPC Input"
jsonpath "$.result.resources[27].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[27].mimeType" == "application/schema+json"
jsonpath "$.result.resources[27].size" == 703
jsonpath "$.result.resources[27].annotations.priority" == 0
jsonpath "$.result.resources[28].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/response"
jsonpath "$.result.resources[28].name" == "Sourcemeta One Schema Statistics RPC Output"
jsonpath "$.result.resources[28].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[28].mimeType" == "application/schema+json"
jsonpath "$.result.resources[28].size" == 709
jsonpath "$.result.resources[28].annotations.priority" == 0
jsonpath "$.result.resources[29].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/request"
jsonpath "$.result.resources[29].name" == "Sourcemeta One Schema RDF RPC Input"
jsonpath "$.result.resources[29].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[29].mimeType" == "application/schema+json"
jsonpath "$.result.resources[29].size" == 2558
jsonpath "$.result.resources[29].annotations.priority" == 0
jsonpath "$.result.resources[30].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/response"
jsonpath "$.result.resources[30].name" == "Sourcemeta One Schema RDF RPC Output"
jsonpath "$.result.resources[30].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[30].mimeType" == "application/schema+json"
jsonpath "$.result.resources[30].size" == 1589
jsonpath "$.result.resources[30].annotations.priority" == 0
jsonpath "$.result.resources[31].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/request"
jsonpath "$.result.resources[31].name" == "Sourcemeta One Directory Listing RPC Input"
jsonpath "$.result.resources[31].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[31].mimeType" == "application/schema+json"
jsonpath "$.result.resources[31].size" == 549
jsonpath "$.result.resources[31].annotations.priority" == 0
jsonpath "$.result.resources[32].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/response"
jsonpath "$.result.resources[32].name" == "Sourcemeta One Directory Listing RPC Output"
jsonpath "$.result.resources[32].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[32].mimeType" == "application/schema+json"
jsonpath "$.result.resources[32].size" == 609
jsonpath "$.result.resources[32].annotations.priority" == 0
jsonpath "$.result.resources[33].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/request"
jsonpath "$.result.resources[33].name" == "Sourcemeta One Playground Schema Trace RPC Input"
jsonpath "$.result.resources[33].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[33].mimeType" == "application/schema+json"
jsonpath "$.result.resources[33].size" == 2296
jsonpath "$.result.resources[33].annotations.priority" == 0
jsonpath "$.result.resources[34].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/response"
jsonpath "$.result.resources[34].name" == "Sourcemeta One Playground Schema Trace RPC Output"
jsonpath "$.result.resources[34].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[34].mimeType" == "application/schema+json"
jsonpath "$.result.resources[34].size" == 559
jsonpath "$.result.resources[34].annotations.priority" == 0
jsonpath "$.result.resources[35].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/request"
jsonpath "$.result.resources[35].name" == "Sourcemeta One MCP Tools Call Request"
jsonpath "$.result.resources[35].description" == "Request from a client to invoke an MCP tool by name"
jsonpath "$.result.resources[35].mimeType" == "application/schema+json"
jsonpath "$.result.resources[35].size" == 1161
jsonpath "$.result.resources[35].annotations.priority" == 0
jsonpath "$.result.resources[36].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/response"
jsonpath "$.result.resources[36].name" == "Sourcemeta One MCP Tools Call Response"
jsonpath "$.result.resources[36].description" == "Sourcemeta One's response to a tool invocation"
jsonpath "$.result.resources[36].mimeType" == "application/schema+json"
jsonpath "$.result.resources[36].size" == 4668
jsonpath "$.result.resources[36].annotations.priority" == 0
jsonpath "$.result.resources[37].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/request"
jsonpath "$.result.resources[37].name" == "Sourcemeta One Schema Search RPC Input"
jsonpath "$.result.resources[37].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[37].mimeType" == "application/schema+json"
jsonpath "$.result.resources[37].size" == 2155
jsonpath "$.result.resources[37].annotations.priority" == 0
jsonpath "$.result.resources[38].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/response"
jsonpath "$.result.resources[38].name" == "Sourcemeta One Schema Search RPC Output"
jsonpath "$.result.resources[38].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[38].mimeType" == "application/schema+json"
jsonpath "$.result.resources[38].size" == 777
jsonpath "$.result.resources[38].annotations.priority" == 0
jsonpath "$.result.resources[39].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"
jsonpath "$.result.resources[39].name" == "Sourcemeta One Schema Trace RPC Input"
jsonpath "$.result.resources[39].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[39].mimeType" == "application/schema+json"
jsonpath "$.result.resources[39].size" == 1735
jsonpath "$.result.resources[39].annotations.priority" == 0
jsonpath "$.result.resources[40].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"
jsonpath "$.result.resources[40].name" == "Sourcemeta One Schema Trace RPC Output"
jsonpath "$.result.resources[40].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[40].mimeType" == "application/schema+json"
jsonpath "$.result.resources[40].size" == 497
jsonpath "$.result.resources[40].annotations.priority" == 0
jsonpath "$.result.resources[41].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/request"
jsonpath "$.result.resources[41].name" == "Sourcemeta One MCP Tools List Request"
jsonpath "$.result.resources[41].description" == "Request from a client to list MCP tools"
jsonpath "$.result.resources[41].mimeType" == "application/schema+json"
jsonpath "$.result.resources[41].size" == 853
jsonpath "$.result.resources[41].annotations.priority" == 0
jsonpath "$.result.resources[42].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/response"
jsonpath "$.result.resources[42].name" == "Sourcemeta One MCP Tools List Response"
jsonpath "$.result.resources[42].description" == "Sourcemeta One's list of MCP tools"
jsonpath "$.result.resources[42].mimeType" == "application/schema+json"
jsonpath "$.result.resources[42].size" == 4495
jsonpath "$.result.resources[42].annotations.priority" == 0
jsonpath "$.result.resources[43].uri" == "{{base}}/self/v1/schemas/api/playground/schemas/trace/request"
jsonpath "$.result.resources[43].name" == "Sourcemeta One Playground Schema Trace API Request"
jsonpath "$.result.resources[43].description" == "A JSON instance and the schema to trace its evaluation against"
jsonpath "$.result.resources[43].mimeType" == "application/schema+json"
jsonpath "$.result.resources[43].size" == 1124
jsonpath "$.result.resources[43].annotations.priority" == 0
jsonpath "$.result.nextCursor" not exists

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Accept-Encoding: gzip
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": "rlist-gzip",
  "method": "resources/list",
  "params": { "cursor": "100" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Content-Encoding: gzip
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "rlist-gzip"
jsonpath "$.result.resources" count == 44
jsonpath "$.result.resources[0].uri" == "{{base}}/self/v1/schemas/mcp/notifications/cancelled"
jsonpath "$.result.resources[0].name" == "Sourcemeta One MCP Cancelled Notification"
jsonpath "$.result.resources[0].description" == "Cancellation hint from a client for an in-flight request. Sourcemeta One accepts and discards these"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 1163
jsonpath "$.result.resources[0].annotations.priority" == 0
jsonpath "$.result.resources[1].uri" == "{{base}}/self/v1/schemas/mcp/notifications/initialized"
jsonpath "$.result.resources[1].name" == "Sourcemeta One MCP Initialized Notification"
jsonpath "$.result.resources[1].description" == "Client signal that the handshake is complete and normal operation may begin"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 740
jsonpath "$.result.resources[1].annotations.priority" == 0
jsonpath "$.result.resources[2].uri" == "{{base}}/self/v1/schemas/mcp/ping/request"
jsonpath "$.result.resources[2].name" == "Sourcemeta One MCP Ping Request"
jsonpath "$.result.resources[2].description" == "Liveness check from a client"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 695
jsonpath "$.result.resources[2].annotations.priority" == 0
jsonpath "$.result.resources[3].uri" == "{{base}}/self/v1/schemas/mcp/ping/response"
jsonpath "$.result.resources[3].name" == "Sourcemeta One MCP Ping Response"
jsonpath "$.result.resources[3].description" == "Sourcemeta One's response to a liveness check"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 598
jsonpath "$.result.resources[3].annotations.priority" == 0
jsonpath "$.result.resources[4].uri" == "{{base}}/self/v1/schemas/mcp/prm/response"
jsonpath "$.result.resources[4].name" == "Sourcemeta One MCP Protected Resource Metadata Response"
jsonpath "$.result.resources[4].description" == "The OAuth 2.0 Protected Resource Metadata describing where a token for this instance's Model Context Protocol endpoint is obtained, as defined by RFC 9728"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 2176
jsonpath "$.result.resources[4].annotations.priority" == 0
jsonpath "$.result.resources[5].uri" == "{{base}}/self/v1/schemas/mcp/request"
jsonpath "$.result.resources[5].name" == "Sourcemeta One MCP Request"
jsonpath "$.result.resources[5].description" == "Any incoming MCP request the server accepts. The body may be a single JSON-RPC envelope or a JSON-RPC 2.0 batch (an array of envelopes) on protocol version `2025-03-26`"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 2520
jsonpath "$.result.resources[5].annotations.priority" == 0
jsonpath "$.result.resources[6].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/request"
jsonpath "$.result.resources[6].name" == "Sourcemeta One MCP Resources List Request"
jsonpath "$.result.resources[6].description" == "Request from a client to list MCP resources"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 1071
jsonpath "$.result.resources[6].annotations.priority" == 0
jsonpath "$.result.resources[7].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/response"
jsonpath "$.result.resources[7].name" == "Sourcemeta One MCP Resources List Response"
jsonpath "$.result.resources[7].description" == "Sourcemeta One's list of MCP resources"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 3062
jsonpath "$.result.resources[7].annotations.priority" == 0
jsonpath "$.result.resources[8].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/request"
jsonpath "$.result.resources[8].name" == "Sourcemeta One MCP Resources Read Request"
jsonpath "$.result.resources[8].description" == "Request from a client to read an MCP resource"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 1293
jsonpath "$.result.resources[8].annotations.priority" == 0
jsonpath "$.result.resources[9].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/response"
jsonpath "$.result.resources[9].name" == "Sourcemeta One MCP Resources Read Response"
jsonpath "$.result.resources[9].description" == "Sourcemeta One's response containing an MCP resource"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 1754
jsonpath "$.result.resources[9].annotations.priority" == 0
jsonpath "$.result.resources[10].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/request"
jsonpath "$.result.resources[10].name" == "Sourcemeta One MCP Resources Templates List Request"
jsonpath "$.result.resources[10].description" == "Request from a client to list MCP resource templates"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 922
jsonpath "$.result.resources[10].annotations.priority" == 0
jsonpath "$.result.resources[11].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/response"
jsonpath "$.result.resources[11].name" == "Sourcemeta One MCP Resources Templates List Response"
jsonpath "$.result.resources[11].description" == "Sourcemeta One's list of MCP resource templates"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 2927
jsonpath "$.result.resources[11].annotations.priority" == 0
jsonpath "$.result.resources[12].uri" == "{{base}}/self/v1/schemas/mcp/response"
jsonpath "$.result.resources[12].name" == "Sourcemeta One MCP Response"
jsonpath "$.result.resources[12].description" == "Any outgoing MCP response the server returns"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 4799
jsonpath "$.result.resources[12].annotations.priority" == 0
jsonpath "$.result.resources[13].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/request"
jsonpath "$.result.resources[13].name" == "Sourcemeta One Schema Evaluate RPC Input"
jsonpath "$.result.resources[13].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 1566
jsonpath "$.result.resources[13].annotations.priority" == 0
jsonpath "$.result.resources[14].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/response"
jsonpath "$.result.resources[14].name" == "Sourcemeta One Schema Evaluate RPC Output"
jsonpath "$.result.resources[14].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 441
jsonpath "$.result.resources[14].annotations.priority" == 0
jsonpath "$.result.resources[15].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/request"
jsonpath "$.result.resources[15].name" == "Sourcemeta One Schema Dependencies RPC Input"
jsonpath "$.result.resources[15].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 687
jsonpath "$.result.resources[15].annotations.priority" == 0
jsonpath "$.result.resources[16].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/response"
jsonpath "$.result.resources[16].name" == "Sourcemeta One Schema Dependencies RPC Output"
jsonpath "$.result.resources[16].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 741
jsonpath "$.result.resources[16].annotations.priority" == 0
jsonpath "$.result.resources[17].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/request"
jsonpath "$.result.resources[17].name" == "Sourcemeta One Schema Dependents RPC Input"
jsonpath "$.result.resources[17].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 683
jsonpath "$.result.resources[17].annotations.priority" == 0
jsonpath "$.result.resources[18].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/response"
jsonpath "$.result.resources[18].name" == "Sourcemeta One Schema Dependents RPC Output"
jsonpath "$.result.resources[18].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 735
jsonpath "$.result.resources[18].annotations.priority" == 0
jsonpath "$.result.resources[19].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/request"
jsonpath "$.result.resources[19].name" == "Sourcemeta One Schema Health RPC Input"
jsonpath "$.result.resources[19].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 668
jsonpath "$.result.resources[19].annotations.priority" == 0
jsonpath "$.result.resources[20].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/response"
jsonpath "$.result.resources[20].name" == "Sourcemeta One Schema Health RPC Output"
jsonpath "$.result.resources[20].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[20].mimeType" == "application/schema+json"
jsonpath "$.result.resources[20].size" == 415
jsonpath "$.result.resources[20].annotations.priority" == 0
jsonpath "$.result.resources[21].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/request"
jsonpath "$.result.resources[21].name" == "Sourcemeta One Schema Locations RPC Input"
jsonpath "$.result.resources[21].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[21].mimeType" == "application/schema+json"
jsonpath "$.result.resources[21].size" == 720
jsonpath "$.result.resources[21].annotations.priority" == 0
jsonpath "$.result.resources[22].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/response"
jsonpath "$.result.resources[22].name" == "Sourcemeta One Schema Locations RPC Output"
jsonpath "$.result.resources[22].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[22].mimeType" == "application/schema+json"
jsonpath "$.result.resources[22].size" == 471
jsonpath "$.result.resources[22].annotations.priority" == 0
jsonpath "$.result.resources[23].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/request"
jsonpath "$.result.resources[23].name" == "Sourcemeta One Schema Metadata RPC Input"
jsonpath "$.result.resources[23].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[23].mimeType" == "application/schema+json"
jsonpath "$.result.resources[23].size" == 666
jsonpath "$.result.resources[23].annotations.priority" == 0
jsonpath "$.result.resources[24].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/response"
jsonpath "$.result.resources[24].name" == "Sourcemeta One Schema Metadata RPC Output"
jsonpath "$.result.resources[24].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[24].mimeType" == "application/schema+json"
jsonpath "$.result.resources[24].size" == 843
jsonpath "$.result.resources[24].annotations.priority" == 0
jsonpath "$.result.resources[25].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/request"
jsonpath "$.result.resources[25].name" == "Sourcemeta One Schema Positions RPC Input"
jsonpath "$.result.resources[25].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[25].mimeType" == "application/schema+json"
jsonpath "$.result.resources[25].size" == 682
jsonpath "$.result.resources[25].annotations.priority" == 0
jsonpath "$.result.resources[26].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/response"
jsonpath "$.result.resources[26].name" == "Sourcemeta One Schema Positions RPC Output"
jsonpath "$.result.resources[26].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[26].mimeType" == "application/schema+json"
jsonpath "$.result.resources[26].size" == 435
jsonpath "$.result.resources[26].annotations.priority" == 0
jsonpath "$.result.resources[27].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/request"
jsonpath "$.result.resources[27].name" == "Sourcemeta One Schema Statistics RPC Input"
jsonpath "$.result.resources[27].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[27].mimeType" == "application/schema+json"
jsonpath "$.result.resources[27].size" == 703
jsonpath "$.result.resources[27].annotations.priority" == 0
jsonpath "$.result.resources[28].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/response"
jsonpath "$.result.resources[28].name" == "Sourcemeta One Schema Statistics RPC Output"
jsonpath "$.result.resources[28].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[28].mimeType" == "application/schema+json"
jsonpath "$.result.resources[28].size" == 709
jsonpath "$.result.resources[28].annotations.priority" == 0
jsonpath "$.result.resources[29].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/request"
jsonpath "$.result.resources[29].name" == "Sourcemeta One Schema RDF RPC Input"
jsonpath "$.result.resources[29].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[29].mimeType" == "application/schema+json"
jsonpath "$.result.resources[29].size" == 2558
jsonpath "$.result.resources[29].annotations.priority" == 0
jsonpath "$.result.resources[30].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/response"
jsonpath "$.result.resources[30].name" == "Sourcemeta One Schema RDF RPC Output"
jsonpath "$.result.resources[30].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[30].mimeType" == "application/schema+json"
jsonpath "$.result.resources[30].size" == 1589
jsonpath "$.result.resources[30].annotations.priority" == 0
jsonpath "$.result.resources[31].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/request"
jsonpath "$.result.resources[31].name" == "Sourcemeta One Directory Listing RPC Input"
jsonpath "$.result.resources[31].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[31].mimeType" == "application/schema+json"
jsonpath "$.result.resources[31].size" == 549
jsonpath "$.result.resources[31].annotations.priority" == 0
jsonpath "$.result.resources[32].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/response"
jsonpath "$.result.resources[32].name" == "Sourcemeta One Directory Listing RPC Output"
jsonpath "$.result.resources[32].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[32].mimeType" == "application/schema+json"
jsonpath "$.result.resources[32].size" == 609
jsonpath "$.result.resources[32].annotations.priority" == 0
jsonpath "$.result.resources[33].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/request"
jsonpath "$.result.resources[33].name" == "Sourcemeta One Playground Schema Trace RPC Input"
jsonpath "$.result.resources[33].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[33].mimeType" == "application/schema+json"
jsonpath "$.result.resources[33].size" == 2296
jsonpath "$.result.resources[33].annotations.priority" == 0
jsonpath "$.result.resources[34].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/response"
jsonpath "$.result.resources[34].name" == "Sourcemeta One Playground Schema Trace RPC Output"
jsonpath "$.result.resources[34].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[34].mimeType" == "application/schema+json"
jsonpath "$.result.resources[34].size" == 559
jsonpath "$.result.resources[34].annotations.priority" == 0
jsonpath "$.result.resources[35].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/request"
jsonpath "$.result.resources[35].name" == "Sourcemeta One MCP Tools Call Request"
jsonpath "$.result.resources[35].description" == "Request from a client to invoke an MCP tool by name"
jsonpath "$.result.resources[35].mimeType" == "application/schema+json"
jsonpath "$.result.resources[35].size" == 1161
jsonpath "$.result.resources[35].annotations.priority" == 0
jsonpath "$.result.resources[36].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/response"
jsonpath "$.result.resources[36].name" == "Sourcemeta One MCP Tools Call Response"
jsonpath "$.result.resources[36].description" == "Sourcemeta One's response to a tool invocation"
jsonpath "$.result.resources[36].mimeType" == "application/schema+json"
jsonpath "$.result.resources[36].size" == 4668
jsonpath "$.result.resources[36].annotations.priority" == 0
jsonpath "$.result.resources[37].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/request"
jsonpath "$.result.resources[37].name" == "Sourcemeta One Schema Search RPC Input"
jsonpath "$.result.resources[37].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[37].mimeType" == "application/schema+json"
jsonpath "$.result.resources[37].size" == 2155
jsonpath "$.result.resources[37].annotations.priority" == 0
jsonpath "$.result.resources[38].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/response"
jsonpath "$.result.resources[38].name" == "Sourcemeta One Schema Search RPC Output"
jsonpath "$.result.resources[38].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[38].mimeType" == "application/schema+json"
jsonpath "$.result.resources[38].size" == 777
jsonpath "$.result.resources[38].annotations.priority" == 0
jsonpath "$.result.resources[39].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"
jsonpath "$.result.resources[39].name" == "Sourcemeta One Schema Trace RPC Input"
jsonpath "$.result.resources[39].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[39].mimeType" == "application/schema+json"
jsonpath "$.result.resources[39].size" == 1735
jsonpath "$.result.resources[39].annotations.priority" == 0
jsonpath "$.result.resources[40].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"
jsonpath "$.result.resources[40].name" == "Sourcemeta One Schema Trace RPC Output"
jsonpath "$.result.resources[40].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[40].mimeType" == "application/schema+json"
jsonpath "$.result.resources[40].size" == 497
jsonpath "$.result.resources[40].annotations.priority" == 0
jsonpath "$.result.resources[41].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/request"
jsonpath "$.result.resources[41].name" == "Sourcemeta One MCP Tools List Request"
jsonpath "$.result.resources[41].description" == "Request from a client to list MCP tools"
jsonpath "$.result.resources[41].mimeType" == "application/schema+json"
jsonpath "$.result.resources[41].size" == 853
jsonpath "$.result.resources[41].annotations.priority" == 0
jsonpath "$.result.resources[42].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/response"
jsonpath "$.result.resources[42].name" == "Sourcemeta One MCP Tools List Response"
jsonpath "$.result.resources[42].description" == "Sourcemeta One's list of MCP tools"
jsonpath "$.result.resources[42].mimeType" == "application/schema+json"
jsonpath "$.result.resources[42].size" == 4495
jsonpath "$.result.resources[42].annotations.priority" == 0
jsonpath "$.result.resources[43].uri" == "{{base}}/self/v1/schemas/api/playground/schemas/trace/request"
jsonpath "$.result.resources[43].name" == "Sourcemeta One Playground Schema Trace API Request"
jsonpath "$.result.resources[43].description" == "A JSON instance and the schema to trace its evaluation against"
jsonpath "$.result.resources[43].mimeType" == "application/schema+json"
jsonpath "$.result.resources[43].size" == 1124
jsonpath "$.result.resources[43].annotations.priority" == 0
jsonpath "$.result.nextCursor" not exists

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

GET {{base}}/test/object
HTTP 200
Cache-Control: public, max-age=0, must-revalidate
[Captures]
schema_text: body
[Asserts]
header "Vary" == "User-Agent, Accept-Encoding"
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": "rread-identity",
  "method": "resources/read",
  "params": { "uri": "{{base}}/test/object" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
header "Content-Encoding" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "rread-identity"
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/test/object"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"
jsonpath "$.result.contents[0].text" == "{{schema_text}}"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Accept-Encoding: gzip
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": "rread-gzip",
  "method": "resources/read",
  "params": { "uri": "{{base}}/test/object" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Content-Encoding: gzip
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "rread-gzip"
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/test/object"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"
jsonpath "$.result.contents[0].text" == "{{schema_text}}"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": "tlist-identity", "method": "resources/templates/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
header "Content-Encoding" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "tlist-identity"
jsonpath "$.result.resourceTemplates" count == 1
jsonpath "$.result.resourceTemplates[0].uriTemplate" == "{{base}}/{+path}{?bundle}"
jsonpath "$.result.resourceTemplates[0].name" == "JSON Schema"
jsonpath "$.result.resourceTemplates[0].description" == "A JSON Schema in this catalog, addressable by its canonical absolute URI under this server's origin. This instance is sovereign over its own URL namespace. Schemas whose URIs lie outside this namespace will not be served here. Substitute `{+path}` with the schema's catalog path. Include `{?bundle}` (its presence alone triggers bundling, any value is ignored) to receive the schema with every external `$ref` inlined into a single self-contained document. The URI must not contain a fragment. Use `resources/list` to discover the available schemas rather than guessing paths"
jsonpath "$.result.resourceTemplates[0].mimeType" == "application/schema+json"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Accept-Encoding: gzip
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": "tlist-gzip", "method": "resources/templates/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Content-Encoding: gzip
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "tlist-gzip"
jsonpath "$.result.resourceTemplates" count == 1
jsonpath "$.result.resourceTemplates[0].uriTemplate" == "{{base}}/{+path}{?bundle}"
jsonpath "$.result.resourceTemplates[0].name" == "JSON Schema"
jsonpath "$.result.resourceTemplates[0].description" == "A JSON Schema in this catalog, addressable by its canonical absolute URI under this server's origin. This instance is sovereign over its own URL namespace. Schemas whose URIs lie outside this namespace will not be served here. Substitute `{+path}` with the schema's catalog path. Include `{?bundle}` (its presence alone triggers bundling, any value is ignored) to receive the schema with every external `$ref` inlined into a single self-contained document. The URI must not contain a fragment. Use `resources/list` to discover the available schemas rather than guessing paths"
jsonpath "$.result.resourceTemplates[0].mimeType" == "application/schema+json"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Accept-Encoding: gzip;q=0
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": "neg-gzip-q0", "method": "ping" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: {{base}}
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-11-25
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
header "Content-Encoding" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == "neg-gzip-q0"
jsonpath "$.result" isObject
jsonpath "$.result" isEmpty

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Accept-Encoding: identity;q=0
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": "neg-identity-q0", "method": "ping" }
```
HTTP 406
Cache-Control: no-store
Content-Type: application/problem+json
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.status" == 406
jsonpath "$.type" == "urn:sourcemeta:one:cannot-satisfy-content-encoding"
jsonpath "$.title" == "Not Acceptable"
