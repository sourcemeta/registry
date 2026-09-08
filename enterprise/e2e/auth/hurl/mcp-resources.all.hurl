# `resources/list` is filtered against the caller's credential at request time.
# An anonymous caller enumerates only the public schemas plus the public
# `/self` API schemas. Every entry on every page is asserted so a protected
# schema cannot slip in unnoticed.

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "resources/list"
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
anonymous_list: body
anonymous_list_schema: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 1
jsonpath "$.result.resources" count == 50
jsonpath "$.result.nextCursor" == "50"
jsonpath "$.result.resources[0].uri" == "{{base}}/orphan/lonely"
jsonpath "$.result.resources[0].name" == "/orphan/lonely"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 208
jsonpath "$.result.resources[0].annotations.priority" == 0.5
jsonpath "$.result.resources[1].uri" == "{{base}}/public/string"
jsonpath "$.result.resources[1].name" == "/public/string"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 131
jsonpath "$.result.resources[1].annotations.priority" == 0.5
jsonpath "$.result.resources[2].uri" == "{{base}}/self/v1/schemas/api/auth/login/response"
jsonpath "$.result.resources[2].name" == "Sourcemeta One Login API Response"
jsonpath "$.result.resources[2].description" == "The ways of signing in to this instance, which a custom interface reads to offer them"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 1735
jsonpath "$.result.resources[2].annotations.priority" == 0
jsonpath "$.result.resources[3].uri" == "{{base}}/self/v1/schemas/api/error"
jsonpath "$.result.resources[3].name" == "Sourcemeta One API Error"
jsonpath "$.result.resources[3].description" == "The error response format returned by the Sourcemeta One API endpoints"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 11208
jsonpath "$.result.resources[3].annotations.priority" == 0
jsonpath "$.result.resources[4].uri" == "{{base}}/self/v1/schemas/api/list/response"
jsonpath "$.result.resources[4].name" == "Sourcemeta One List API Response"
jsonpath "$.result.resources[4].description" == "The response format for the directory listing API endpoint"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 3878
jsonpath "$.result.resources[4].annotations.priority" == 0
jsonpath "$.result.resources[5].uri" == "{{base}}/self/v1/schemas/api/playground/schemas/trace/response"
jsonpath "$.result.resources[5].name" == "Sourcemeta One Playground Schema Trace API Response"
jsonpath "$.result.resources[5].description" == "The response format for tracing evaluation against a schema supplied in the request, which is what tracing against a schema in the catalog returns"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 501
jsonpath "$.result.resources[5].annotations.priority" == 0
jsonpath "$.result.resources[6].uri" == "{{base}}/self/v1/schemas/api/schemas/dependencies/response"
jsonpath "$.result.resources[6].name" == "Sourcemeta One Schema Dependencies API Response"
jsonpath "$.result.resources[6].description" == "The response format for the schema dependencies API endpoint"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 992
jsonpath "$.result.resources[6].annotations.priority" == 0
jsonpath "$.result.resources[7].uri" == "{{base}}/self/v1/schemas/api/schemas/dependents/response"
jsonpath "$.result.resources[7].name" == "Sourcemeta One Schema Dependents API Response"
jsonpath "$.result.resources[7].description" == "The response format for the schema dependents API endpoint"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 986
jsonpath "$.result.resources[7].annotations.priority" == 0
jsonpath "$.result.resources[8].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/request"
jsonpath "$.result.resources[8].name" == "Sourcemeta One Schema Evaluate API Request"
jsonpath "$.result.resources[8].description" == "The JSON instance to validate against a schema in the catalog"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 417
jsonpath "$.result.resources[8].annotations.priority" == 0
jsonpath "$.result.resources[9].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/response"
jsonpath "$.result.resources[9].name" == "Sourcemeta One Schema Evaluate API Response"
jsonpath "$.result.resources[9].description" == "The response format for the schema evaluation API endpoint"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 2138
jsonpath "$.result.resources[9].annotations.priority" == 0
jsonpath "$.result.resources[10].uri" == "{{base}}/self/v1/schemas/api/schemas/health/response"
jsonpath "$.result.resources[10].name" == "Sourcemeta One Schema Health API Response"
jsonpath "$.result.resources[10].description" == "The response format for the schema health API endpoint"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 1584
jsonpath "$.result.resources[10].annotations.priority" == 0
jsonpath "$.result.resources[11].uri" == "{{base}}/self/v1/schemas/api/schemas/locations/response"
jsonpath "$.result.resources[11].name" == "Sourcemeta One Schema Locations API Response"
jsonpath "$.result.resources[11].description" == "The response format for the schema frame locations API endpoint"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 2391
jsonpath "$.result.resources[11].annotations.priority" == 0
jsonpath "$.result.resources[12].uri" == "{{base}}/self/v1/schemas/api/schemas/metadata/response"
jsonpath "$.result.resources[12].name" == "Sourcemeta One Schema Metadata API Response"
jsonpath "$.result.resources[12].description" == "The response format for the schema metadata API endpoint"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 2943
jsonpath "$.result.resources[12].annotations.priority" == 0
jsonpath "$.result.resources[13].uri" == "{{base}}/self/v1/schemas/api/schemas/output-error"
jsonpath "$.result.resources[13].name" == "Sourcemeta One Schema Output Error"
jsonpath "$.result.resources[13].description" == "A single entry of the standard JSON Schema output format that describes why an instance does not conform to a schema"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 1143
jsonpath "$.result.resources[13].annotations.priority" == 0
jsonpath "$.result.resources[14].uri" == "{{base}}/self/v1/schemas/api/schemas/position"
jsonpath "$.result.resources[14].name" == "Sourcemeta One Schema Position"
jsonpath "$.result.resources[14].description" == "Represents a position in a JSON document as line start, column start, line end, and column end"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 446
jsonpath "$.result.resources[14].annotations.priority" == 0
jsonpath "$.result.resources[15].uri" == "{{base}}/self/v1/schemas/api/schemas/positions/response"
jsonpath "$.result.resources[15].name" == "Sourcemeta One Schema Positions API Response"
jsonpath "$.result.resources[15].description" == "The response format for the schema positions API endpoint"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 435
jsonpath "$.result.resources[15].annotations.priority" == 0
jsonpath "$.result.resources[16].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/request"
jsonpath "$.result.resources[16].name" == "Sourcemeta One Schema RDF API Request"
jsonpath "$.result.resources[16].description" == "The JSON instance to promote to JSON-LD against a schema in the catalog, along with the desired output form"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 1422
jsonpath "$.result.resources[16].annotations.priority" == 0
jsonpath "$.result.resources[17].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/response"
jsonpath "$.result.resources[17].name" == "Sourcemeta One Schema RDF API Response"
jsonpath "$.result.resources[17].description" == "The instance promoted to JSON-LD, in expanded, flattened, or compacted form"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 799
jsonpath "$.result.resources[17].annotations.priority" == 0
jsonpath "$.result.resources[18].uri" == "{{base}}/self/v1/schemas/api/schemas/search/response"
jsonpath "$.result.resources[18].name" == "Sourcemeta One Schema Search API Response"
jsonpath "$.result.resources[18].description" == "The response format for the schema search API endpoint"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 1341
jsonpath "$.result.resources[18].annotations.priority" == 0
jsonpath "$.result.resources[19].uri" == "{{base}}/self/v1/schemas/api/schemas/stats/response"
jsonpath "$.result.resources[19].name" == "Sourcemeta One Schema Stats API Response"
jsonpath "$.result.resources[19].description" == "The response format for the schema statistics API endpoint"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 2345
jsonpath "$.result.resources[19].annotations.priority" == 0
jsonpath "$.result.resources[20].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/request"
jsonpath "$.result.resources[20].name" == "Sourcemeta One Schema Trace API Request"
jsonpath "$.result.resources[20].description" == "The JSON instance to trace evaluation against a schema in the catalog"
jsonpath "$.result.resources[20].mimeType" == "application/schema+json"
jsonpath "$.result.resources[20].size" == 419
jsonpath "$.result.resources[20].annotations.priority" == 0
jsonpath "$.result.resources[21].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/response"
jsonpath "$.result.resources[21].name" == "Sourcemeta One Schema Trace API Response"
jsonpath "$.result.resources[21].description" == "The response format for the schema trace API endpoint"
jsonpath "$.result.resources[21].mimeType" == "application/schema+json"
jsonpath "$.result.resources[21].size" == 2290
jsonpath "$.result.resources[21].annotations.priority" == 0
jsonpath "$.result.resources[22].uri" == "{{base}}/self/v1/schemas/mcp/error"
jsonpath "$.result.resources[22].name" == "Sourcemeta One MCP Error Response"
jsonpath "$.result.resources[22].description" == "The error response Sourcemeta One returns when an MCP request fails"
jsonpath "$.result.resources[22].mimeType" == "application/schema+json"
jsonpath "$.result.resources[22].size" == 5860
jsonpath "$.result.resources[22].annotations.priority" == 0
jsonpath "$.result.resources[23].uri" == "{{base}}/self/v1/schemas/mcp/initialize/request"
jsonpath "$.result.resources[23].name" == "Sourcemeta One MCP Initialize Request"
jsonpath "$.result.resources[23].description" == "Connection handshake from a client"
jsonpath "$.result.resources[23].mimeType" == "application/schema+json"
jsonpath "$.result.resources[23].size" == 4617
jsonpath "$.result.resources[23].annotations.priority" == 0
jsonpath "$.result.resources[24].uri" == "{{base}}/self/v1/schemas/mcp/initialize/response"
jsonpath "$.result.resources[24].name" == "Sourcemeta One MCP Initialize Response"
jsonpath "$.result.resources[24].description" == "Sourcemeta One's response to a client's initialization"
jsonpath "$.result.resources[24].mimeType" == "application/schema+json"
jsonpath "$.result.resources[24].size" == 2524
jsonpath "$.result.resources[24].annotations.priority" == 0
jsonpath "$.result.resources[25].uri" == "{{base}}/self/v1/schemas/mcp/notifications/cancelled"
jsonpath "$.result.resources[25].name" == "Sourcemeta One MCP Cancelled Notification"
jsonpath "$.result.resources[25].description" == "Cancellation hint from a client for an in-flight request. Sourcemeta One accepts and discards these"
jsonpath "$.result.resources[25].mimeType" == "application/schema+json"
jsonpath "$.result.resources[25].size" == 1163
jsonpath "$.result.resources[25].annotations.priority" == 0
jsonpath "$.result.resources[26].uri" == "{{base}}/self/v1/schemas/mcp/notifications/initialized"
jsonpath "$.result.resources[26].name" == "Sourcemeta One MCP Initialized Notification"
jsonpath "$.result.resources[26].description" == "Client signal that the handshake is complete and normal operation may begin"
jsonpath "$.result.resources[26].mimeType" == "application/schema+json"
jsonpath "$.result.resources[26].size" == 740
jsonpath "$.result.resources[26].annotations.priority" == 0
jsonpath "$.result.resources[27].uri" == "{{base}}/self/v1/schemas/mcp/ping/request"
jsonpath "$.result.resources[27].name" == "Sourcemeta One MCP Ping Request"
jsonpath "$.result.resources[27].description" == "Liveness check from a client"
jsonpath "$.result.resources[27].mimeType" == "application/schema+json"
jsonpath "$.result.resources[27].size" == 695
jsonpath "$.result.resources[27].annotations.priority" == 0
jsonpath "$.result.resources[28].uri" == "{{base}}/self/v1/schemas/mcp/ping/response"
jsonpath "$.result.resources[28].name" == "Sourcemeta One MCP Ping Response"
jsonpath "$.result.resources[28].description" == "Sourcemeta One's response to a liveness check"
jsonpath "$.result.resources[28].mimeType" == "application/schema+json"
jsonpath "$.result.resources[28].size" == 598
jsonpath "$.result.resources[28].annotations.priority" == 0
jsonpath "$.result.resources[29].uri" == "{{base}}/self/v1/schemas/mcp/prm/response"
jsonpath "$.result.resources[29].name" == "Sourcemeta One MCP Protected Resource Metadata Response"
jsonpath "$.result.resources[29].description" == "The OAuth 2.0 Protected Resource Metadata describing where a token for this instance's Model Context Protocol endpoint is obtained, as defined by RFC 9728"
jsonpath "$.result.resources[29].mimeType" == "application/schema+json"
jsonpath "$.result.resources[29].size" == 2176
jsonpath "$.result.resources[29].annotations.priority" == 0
jsonpath "$.result.resources[30].uri" == "{{base}}/self/v1/schemas/mcp/request"
jsonpath "$.result.resources[30].name" == "Sourcemeta One MCP Request"
jsonpath "$.result.resources[30].description" == "Any incoming MCP request the server accepts. The body may be a single JSON-RPC envelope or a JSON-RPC 2.0 batch (an array of envelopes) on protocol version `2025-03-26`"
jsonpath "$.result.resources[30].mimeType" == "application/schema+json"
jsonpath "$.result.resources[30].size" == 2520
jsonpath "$.result.resources[30].annotations.priority" == 0
jsonpath "$.result.resources[31].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/request"
jsonpath "$.result.resources[31].name" == "Sourcemeta One MCP Resources List Request"
jsonpath "$.result.resources[31].description" == "Request from a client to list MCP resources"
jsonpath "$.result.resources[31].mimeType" == "application/schema+json"
jsonpath "$.result.resources[31].size" == 1071
jsonpath "$.result.resources[31].annotations.priority" == 0
jsonpath "$.result.resources[32].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/response"
jsonpath "$.result.resources[32].name" == "Sourcemeta One MCP Resources List Response"
jsonpath "$.result.resources[32].description" == "Sourcemeta One's list of MCP resources"
jsonpath "$.result.resources[32].mimeType" == "application/schema+json"
jsonpath "$.result.resources[32].size" == 3062
jsonpath "$.result.resources[32].annotations.priority" == 0
jsonpath "$.result.resources[33].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/request"
jsonpath "$.result.resources[33].name" == "Sourcemeta One MCP Resources Read Request"
jsonpath "$.result.resources[33].description" == "Request from a client to read an MCP resource"
jsonpath "$.result.resources[33].mimeType" == "application/schema+json"
jsonpath "$.result.resources[33].size" == 1293
jsonpath "$.result.resources[33].annotations.priority" == 0
jsonpath "$.result.resources[34].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/response"
jsonpath "$.result.resources[34].name" == "Sourcemeta One MCP Resources Read Response"
jsonpath "$.result.resources[34].description" == "Sourcemeta One's response containing an MCP resource"
jsonpath "$.result.resources[34].mimeType" == "application/schema+json"
jsonpath "$.result.resources[34].size" == 1754
jsonpath "$.result.resources[34].annotations.priority" == 0
jsonpath "$.result.resources[35].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/request"
jsonpath "$.result.resources[35].name" == "Sourcemeta One MCP Resources Templates List Request"
jsonpath "$.result.resources[35].description" == "Request from a client to list MCP resource templates"
jsonpath "$.result.resources[35].mimeType" == "application/schema+json"
jsonpath "$.result.resources[35].size" == 922
jsonpath "$.result.resources[35].annotations.priority" == 0
jsonpath "$.result.resources[36].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/response"
jsonpath "$.result.resources[36].name" == "Sourcemeta One MCP Resources Templates List Response"
jsonpath "$.result.resources[36].description" == "Sourcemeta One's list of MCP resource templates"
jsonpath "$.result.resources[36].mimeType" == "application/schema+json"
jsonpath "$.result.resources[36].size" == 2927
jsonpath "$.result.resources[36].annotations.priority" == 0
jsonpath "$.result.resources[37].uri" == "{{base}}/self/v1/schemas/mcp/response"
jsonpath "$.result.resources[37].name" == "Sourcemeta One MCP Response"
jsonpath "$.result.resources[37].description" == "Any outgoing MCP response the server returns"
jsonpath "$.result.resources[37].mimeType" == "application/schema+json"
jsonpath "$.result.resources[37].size" == 4799
jsonpath "$.result.resources[37].annotations.priority" == 0
jsonpath "$.result.resources[38].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/request"
jsonpath "$.result.resources[38].name" == "Sourcemeta One Schema Evaluate RPC Input"
jsonpath "$.result.resources[38].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[38].mimeType" == "application/schema+json"
jsonpath "$.result.resources[38].size" == 1566
jsonpath "$.result.resources[38].annotations.priority" == 0
jsonpath "$.result.resources[39].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/response"
jsonpath "$.result.resources[39].name" == "Sourcemeta One Schema Evaluate RPC Output"
jsonpath "$.result.resources[39].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[39].mimeType" == "application/schema+json"
jsonpath "$.result.resources[39].size" == 441
jsonpath "$.result.resources[39].annotations.priority" == 0
jsonpath "$.result.resources[40].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/request"
jsonpath "$.result.resources[40].name" == "Sourcemeta One Schema Dependencies RPC Input"
jsonpath "$.result.resources[40].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[40].mimeType" == "application/schema+json"
jsonpath "$.result.resources[40].size" == 687
jsonpath "$.result.resources[40].annotations.priority" == 0
jsonpath "$.result.resources[41].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/response"
jsonpath "$.result.resources[41].name" == "Sourcemeta One Schema Dependencies RPC Output"
jsonpath "$.result.resources[41].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[41].mimeType" == "application/schema+json"
jsonpath "$.result.resources[41].size" == 741
jsonpath "$.result.resources[41].annotations.priority" == 0
jsonpath "$.result.resources[42].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/request"
jsonpath "$.result.resources[42].name" == "Sourcemeta One Schema Dependents RPC Input"
jsonpath "$.result.resources[42].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[42].mimeType" == "application/schema+json"
jsonpath "$.result.resources[42].size" == 683
jsonpath "$.result.resources[42].annotations.priority" == 0
jsonpath "$.result.resources[43].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/response"
jsonpath "$.result.resources[43].name" == "Sourcemeta One Schema Dependents RPC Output"
jsonpath "$.result.resources[43].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[43].mimeType" == "application/schema+json"
jsonpath "$.result.resources[43].size" == 735
jsonpath "$.result.resources[43].annotations.priority" == 0
jsonpath "$.result.resources[44].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/request"
jsonpath "$.result.resources[44].name" == "Sourcemeta One Schema Health RPC Input"
jsonpath "$.result.resources[44].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[44].mimeType" == "application/schema+json"
jsonpath "$.result.resources[44].size" == 668
jsonpath "$.result.resources[44].annotations.priority" == 0
jsonpath "$.result.resources[45].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/response"
jsonpath "$.result.resources[45].name" == "Sourcemeta One Schema Health RPC Output"
jsonpath "$.result.resources[45].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[45].mimeType" == "application/schema+json"
jsonpath "$.result.resources[45].size" == 415
jsonpath "$.result.resources[45].annotations.priority" == 0
jsonpath "$.result.resources[46].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/request"
jsonpath "$.result.resources[46].name" == "Sourcemeta One Schema Locations RPC Input"
jsonpath "$.result.resources[46].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[46].mimeType" == "application/schema+json"
jsonpath "$.result.resources[46].size" == 720
jsonpath "$.result.resources[46].annotations.priority" == 0
jsonpath "$.result.resources[47].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/response"
jsonpath "$.result.resources[47].name" == "Sourcemeta One Schema Locations RPC Output"
jsonpath "$.result.resources[47].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[47].mimeType" == "application/schema+json"
jsonpath "$.result.resources[47].size" == 471
jsonpath "$.result.resources[47].annotations.priority" == 0
jsonpath "$.result.resources[48].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/request"
jsonpath "$.result.resources[48].name" == "Sourcemeta One Schema Metadata RPC Input"
jsonpath "$.result.resources[48].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[48].mimeType" == "application/schema+json"
jsonpath "$.result.resources[48].size" == 666
jsonpath "$.result.resources[48].annotations.priority" == 0
jsonpath "$.result.resources[49].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/response"
jsonpath "$.result.resources[49].name" == "Sourcemeta One Schema Metadata RPC Output"
jsonpath "$.result.resources[49].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[49].mimeType" == "application/schema+json"
jsonpath "$.result.resources[49].size" == 843
jsonpath "$.result.resources[49].annotations.priority" == 0

POST {{base}}/self/v1/api/schemas/evaluate{{anonymous_list_schema}}
```
{{anonymous_list}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# The anonymous second page, still only public schemas.
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 2,
  "method": "resources/list",
  "params": { "cursor": "50" }
}
```
HTTP 200
Content-Type: application/json
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 2
jsonpath "$.result.resources" count == 19
jsonpath "$.result.nextCursor" not exists
jsonpath "$.result.resources[0].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/request"
jsonpath "$.result.resources[0].name" == "Sourcemeta One Schema Positions RPC Input"
jsonpath "$.result.resources[0].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 682
jsonpath "$.result.resources[0].annotations.priority" == 0
jsonpath "$.result.resources[1].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/response"
jsonpath "$.result.resources[1].name" == "Sourcemeta One Schema Positions RPC Output"
jsonpath "$.result.resources[1].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 435
jsonpath "$.result.resources[1].annotations.priority" == 0
jsonpath "$.result.resources[2].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/request"
jsonpath "$.result.resources[2].name" == "Sourcemeta One Schema Statistics RPC Input"
jsonpath "$.result.resources[2].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 703
jsonpath "$.result.resources[2].annotations.priority" == 0
jsonpath "$.result.resources[3].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/response"
jsonpath "$.result.resources[3].name" == "Sourcemeta One Schema Statistics RPC Output"
jsonpath "$.result.resources[3].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 709
jsonpath "$.result.resources[3].annotations.priority" == 0
jsonpath "$.result.resources[4].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/request"
jsonpath "$.result.resources[4].name" == "Sourcemeta One Schema RDF RPC Input"
jsonpath "$.result.resources[4].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 2558
jsonpath "$.result.resources[4].annotations.priority" == 0
jsonpath "$.result.resources[5].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/response"
jsonpath "$.result.resources[5].name" == "Sourcemeta One Schema RDF RPC Output"
jsonpath "$.result.resources[5].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 1589
jsonpath "$.result.resources[5].annotations.priority" == 0
jsonpath "$.result.resources[6].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/request"
jsonpath "$.result.resources[6].name" == "Sourcemeta One Directory Listing RPC Input"
jsonpath "$.result.resources[6].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 549
jsonpath "$.result.resources[6].annotations.priority" == 0
jsonpath "$.result.resources[7].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/response"
jsonpath "$.result.resources[7].name" == "Sourcemeta One Directory Listing RPC Output"
jsonpath "$.result.resources[7].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 609
jsonpath "$.result.resources[7].annotations.priority" == 0
jsonpath "$.result.resources[8].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/request"
jsonpath "$.result.resources[8].name" == "Sourcemeta One Playground Schema Trace RPC Input"
jsonpath "$.result.resources[8].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 2296
jsonpath "$.result.resources[8].annotations.priority" == 0
jsonpath "$.result.resources[9].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/response"
jsonpath "$.result.resources[9].name" == "Sourcemeta One Playground Schema Trace RPC Output"
jsonpath "$.result.resources[9].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 559
jsonpath "$.result.resources[9].annotations.priority" == 0
jsonpath "$.result.resources[10].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/request"
jsonpath "$.result.resources[10].name" == "Sourcemeta One MCP Tools Call Request"
jsonpath "$.result.resources[10].description" == "Request from a client to invoke an MCP tool by name"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 1161
jsonpath "$.result.resources[10].annotations.priority" == 0
jsonpath "$.result.resources[11].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/response"
jsonpath "$.result.resources[11].name" == "Sourcemeta One MCP Tools Call Response"
jsonpath "$.result.resources[11].description" == "Sourcemeta One's response to a tool invocation"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 4668
jsonpath "$.result.resources[11].annotations.priority" == 0
jsonpath "$.result.resources[12].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/request"
jsonpath "$.result.resources[12].name" == "Sourcemeta One Schema Search RPC Input"
jsonpath "$.result.resources[12].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 2155
jsonpath "$.result.resources[12].annotations.priority" == 0
jsonpath "$.result.resources[13].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/response"
jsonpath "$.result.resources[13].name" == "Sourcemeta One Schema Search RPC Output"
jsonpath "$.result.resources[13].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 777
jsonpath "$.result.resources[13].annotations.priority" == 0
jsonpath "$.result.resources[14].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"
jsonpath "$.result.resources[14].name" == "Sourcemeta One Schema Trace RPC Input"
jsonpath "$.result.resources[14].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 1735
jsonpath "$.result.resources[14].annotations.priority" == 0
jsonpath "$.result.resources[15].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"
jsonpath "$.result.resources[15].name" == "Sourcemeta One Schema Trace RPC Output"
jsonpath "$.result.resources[15].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 497
jsonpath "$.result.resources[15].annotations.priority" == 0
jsonpath "$.result.resources[16].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/request"
jsonpath "$.result.resources[16].name" == "Sourcemeta One MCP Tools List Request"
jsonpath "$.result.resources[16].description" == "Request from a client to list MCP tools"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 853
jsonpath "$.result.resources[16].annotations.priority" == 0
jsonpath "$.result.resources[17].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/response"
jsonpath "$.result.resources[17].name" == "Sourcemeta One MCP Tools List Response"
jsonpath "$.result.resources[17].description" == "Sourcemeta One's list of MCP tools"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 4495
jsonpath "$.result.resources[17].annotations.priority" == 0
jsonpath "$.result.resources[18].uri" == "{{base}}/self/v1/schemas/api/playground/schemas/trace/request"
jsonpath "$.result.resources[18].name" == "Sourcemeta One Playground Schema Trace API Request"
jsonpath "$.result.resources[18].description" == "A JSON instance and the schema to trace its evaluation against"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 1124
jsonpath "$.result.resources[18].annotations.priority" == 0

# The primary key adds the `/private` and `/reports` schemas, which sort
# ahead of the public ones, on top of everything the anonymous caller sees.
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer primary-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3,
  "method": "resources/list"
}
```
HTTP 200
Content-Type: application/json
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 3
jsonpath "$.result.resources" count == 50
jsonpath "$.result.nextCursor" == "50"
jsonpath "$.result.resources[0].uri" == "{{base}}/private/secret"
jsonpath "$.result.resources[0].name" == "/private/secret"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 259
jsonpath "$.result.resources[0].annotations.priority" == 0.5
jsonpath "$.result.resources[1].uri" == "{{base}}/orphan/lonely"
jsonpath "$.result.resources[1].name" == "/orphan/lonely"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 208
jsonpath "$.result.resources[1].annotations.priority" == 0.5
jsonpath "$.result.resources[2].uri" == "{{base}}/reports/quarterly"
jsonpath "$.result.resources[2].name" == "/reports/quarterly"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 183
jsonpath "$.result.resources[2].annotations.priority" == 0.5
jsonpath "$.result.resources[3].uri" == "{{base}}/private/open/shared"
jsonpath "$.result.resources[3].name" == "/private/open/shared"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 138
jsonpath "$.result.resources[3].annotations.priority" == 0.5
jsonpath "$.result.resources[4].uri" == "{{base}}/public/string"
jsonpath "$.result.resources[4].name" == "/public/string"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 131
jsonpath "$.result.resources[4].annotations.priority" == 0.5
jsonpath "$.result.resources[5].uri" == "{{base}}/self/v1/schemas/api/auth/login/response"
jsonpath "$.result.resources[5].name" == "Sourcemeta One Login API Response"
jsonpath "$.result.resources[5].description" == "The ways of signing in to this instance, which a custom interface reads to offer them"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 1735
jsonpath "$.result.resources[5].annotations.priority" == 0
jsonpath "$.result.resources[6].uri" == "{{base}}/self/v1/schemas/api/error"
jsonpath "$.result.resources[6].name" == "Sourcemeta One API Error"
jsonpath "$.result.resources[6].description" == "The error response format returned by the Sourcemeta One API endpoints"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 11208
jsonpath "$.result.resources[6].annotations.priority" == 0
jsonpath "$.result.resources[7].uri" == "{{base}}/self/v1/schemas/api/list/response"
jsonpath "$.result.resources[7].name" == "Sourcemeta One List API Response"
jsonpath "$.result.resources[7].description" == "The response format for the directory listing API endpoint"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 3878
jsonpath "$.result.resources[7].annotations.priority" == 0
jsonpath "$.result.resources[8].uri" == "{{base}}/self/v1/schemas/api/playground/schemas/trace/response"
jsonpath "$.result.resources[8].name" == "Sourcemeta One Playground Schema Trace API Response"
jsonpath "$.result.resources[8].description" == "The response format for tracing evaluation against a schema supplied in the request, which is what tracing against a schema in the catalog returns"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 501
jsonpath "$.result.resources[8].annotations.priority" == 0
jsonpath "$.result.resources[9].uri" == "{{base}}/self/v1/schemas/api/schemas/dependencies/response"
jsonpath "$.result.resources[9].name" == "Sourcemeta One Schema Dependencies API Response"
jsonpath "$.result.resources[9].description" == "The response format for the schema dependencies API endpoint"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 992
jsonpath "$.result.resources[9].annotations.priority" == 0
jsonpath "$.result.resources[10].uri" == "{{base}}/self/v1/schemas/api/schemas/dependents/response"
jsonpath "$.result.resources[10].name" == "Sourcemeta One Schema Dependents API Response"
jsonpath "$.result.resources[10].description" == "The response format for the schema dependents API endpoint"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 986
jsonpath "$.result.resources[10].annotations.priority" == 0
jsonpath "$.result.resources[11].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/request"
jsonpath "$.result.resources[11].name" == "Sourcemeta One Schema Evaluate API Request"
jsonpath "$.result.resources[11].description" == "The JSON instance to validate against a schema in the catalog"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 417
jsonpath "$.result.resources[11].annotations.priority" == 0
jsonpath "$.result.resources[12].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/response"
jsonpath "$.result.resources[12].name" == "Sourcemeta One Schema Evaluate API Response"
jsonpath "$.result.resources[12].description" == "The response format for the schema evaluation API endpoint"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 2138
jsonpath "$.result.resources[12].annotations.priority" == 0
jsonpath "$.result.resources[13].uri" == "{{base}}/self/v1/schemas/api/schemas/health/response"
jsonpath "$.result.resources[13].name" == "Sourcemeta One Schema Health API Response"
jsonpath "$.result.resources[13].description" == "The response format for the schema health API endpoint"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 1584
jsonpath "$.result.resources[13].annotations.priority" == 0
jsonpath "$.result.resources[14].uri" == "{{base}}/self/v1/schemas/api/schemas/locations/response"
jsonpath "$.result.resources[14].name" == "Sourcemeta One Schema Locations API Response"
jsonpath "$.result.resources[14].description" == "The response format for the schema frame locations API endpoint"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 2391
jsonpath "$.result.resources[14].annotations.priority" == 0
jsonpath "$.result.resources[15].uri" == "{{base}}/self/v1/schemas/api/schemas/metadata/response"
jsonpath "$.result.resources[15].name" == "Sourcemeta One Schema Metadata API Response"
jsonpath "$.result.resources[15].description" == "The response format for the schema metadata API endpoint"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 2943
jsonpath "$.result.resources[15].annotations.priority" == 0
jsonpath "$.result.resources[16].uri" == "{{base}}/self/v1/schemas/api/schemas/output-error"
jsonpath "$.result.resources[16].name" == "Sourcemeta One Schema Output Error"
jsonpath "$.result.resources[16].description" == "A single entry of the standard JSON Schema output format that describes why an instance does not conform to a schema"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 1143
jsonpath "$.result.resources[16].annotations.priority" == 0
jsonpath "$.result.resources[17].uri" == "{{base}}/self/v1/schemas/api/schemas/position"
jsonpath "$.result.resources[17].name" == "Sourcemeta One Schema Position"
jsonpath "$.result.resources[17].description" == "Represents a position in a JSON document as line start, column start, line end, and column end"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 446
jsonpath "$.result.resources[17].annotations.priority" == 0
jsonpath "$.result.resources[18].uri" == "{{base}}/self/v1/schemas/api/schemas/positions/response"
jsonpath "$.result.resources[18].name" == "Sourcemeta One Schema Positions API Response"
jsonpath "$.result.resources[18].description" == "The response format for the schema positions API endpoint"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 435
jsonpath "$.result.resources[18].annotations.priority" == 0
jsonpath "$.result.resources[19].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/request"
jsonpath "$.result.resources[19].name" == "Sourcemeta One Schema RDF API Request"
jsonpath "$.result.resources[19].description" == "The JSON instance to promote to JSON-LD against a schema in the catalog, along with the desired output form"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 1422
jsonpath "$.result.resources[19].annotations.priority" == 0
jsonpath "$.result.resources[20].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/response"
jsonpath "$.result.resources[20].name" == "Sourcemeta One Schema RDF API Response"
jsonpath "$.result.resources[20].description" == "The instance promoted to JSON-LD, in expanded, flattened, or compacted form"
jsonpath "$.result.resources[20].mimeType" == "application/schema+json"
jsonpath "$.result.resources[20].size" == 799
jsonpath "$.result.resources[20].annotations.priority" == 0
jsonpath "$.result.resources[21].uri" == "{{base}}/self/v1/schemas/api/schemas/search/response"
jsonpath "$.result.resources[21].name" == "Sourcemeta One Schema Search API Response"
jsonpath "$.result.resources[21].description" == "The response format for the schema search API endpoint"
jsonpath "$.result.resources[21].mimeType" == "application/schema+json"
jsonpath "$.result.resources[21].size" == 1341
jsonpath "$.result.resources[21].annotations.priority" == 0
jsonpath "$.result.resources[22].uri" == "{{base}}/self/v1/schemas/api/schemas/stats/response"
jsonpath "$.result.resources[22].name" == "Sourcemeta One Schema Stats API Response"
jsonpath "$.result.resources[22].description" == "The response format for the schema statistics API endpoint"
jsonpath "$.result.resources[22].mimeType" == "application/schema+json"
jsonpath "$.result.resources[22].size" == 2345
jsonpath "$.result.resources[22].annotations.priority" == 0
jsonpath "$.result.resources[23].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/request"
jsonpath "$.result.resources[23].name" == "Sourcemeta One Schema Trace API Request"
jsonpath "$.result.resources[23].description" == "The JSON instance to trace evaluation against a schema in the catalog"
jsonpath "$.result.resources[23].mimeType" == "application/schema+json"
jsonpath "$.result.resources[23].size" == 419
jsonpath "$.result.resources[23].annotations.priority" == 0
jsonpath "$.result.resources[24].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/response"
jsonpath "$.result.resources[24].name" == "Sourcemeta One Schema Trace API Response"
jsonpath "$.result.resources[24].description" == "The response format for the schema trace API endpoint"
jsonpath "$.result.resources[24].mimeType" == "application/schema+json"
jsonpath "$.result.resources[24].size" == 2290
jsonpath "$.result.resources[24].annotations.priority" == 0
jsonpath "$.result.resources[25].uri" == "{{base}}/self/v1/schemas/mcp/error"
jsonpath "$.result.resources[25].name" == "Sourcemeta One MCP Error Response"
jsonpath "$.result.resources[25].description" == "The error response Sourcemeta One returns when an MCP request fails"
jsonpath "$.result.resources[25].mimeType" == "application/schema+json"
jsonpath "$.result.resources[25].size" == 5860
jsonpath "$.result.resources[25].annotations.priority" == 0
jsonpath "$.result.resources[26].uri" == "{{base}}/self/v1/schemas/mcp/initialize/request"
jsonpath "$.result.resources[26].name" == "Sourcemeta One MCP Initialize Request"
jsonpath "$.result.resources[26].description" == "Connection handshake from a client"
jsonpath "$.result.resources[26].mimeType" == "application/schema+json"
jsonpath "$.result.resources[26].size" == 4617
jsonpath "$.result.resources[26].annotations.priority" == 0
jsonpath "$.result.resources[27].uri" == "{{base}}/self/v1/schemas/mcp/initialize/response"
jsonpath "$.result.resources[27].name" == "Sourcemeta One MCP Initialize Response"
jsonpath "$.result.resources[27].description" == "Sourcemeta One's response to a client's initialization"
jsonpath "$.result.resources[27].mimeType" == "application/schema+json"
jsonpath "$.result.resources[27].size" == 2524
jsonpath "$.result.resources[27].annotations.priority" == 0
jsonpath "$.result.resources[28].uri" == "{{base}}/self/v1/schemas/mcp/notifications/cancelled"
jsonpath "$.result.resources[28].name" == "Sourcemeta One MCP Cancelled Notification"
jsonpath "$.result.resources[28].description" == "Cancellation hint from a client for an in-flight request. Sourcemeta One accepts and discards these"
jsonpath "$.result.resources[28].mimeType" == "application/schema+json"
jsonpath "$.result.resources[28].size" == 1163
jsonpath "$.result.resources[28].annotations.priority" == 0
jsonpath "$.result.resources[29].uri" == "{{base}}/self/v1/schemas/mcp/notifications/initialized"
jsonpath "$.result.resources[29].name" == "Sourcemeta One MCP Initialized Notification"
jsonpath "$.result.resources[29].description" == "Client signal that the handshake is complete and normal operation may begin"
jsonpath "$.result.resources[29].mimeType" == "application/schema+json"
jsonpath "$.result.resources[29].size" == 740
jsonpath "$.result.resources[29].annotations.priority" == 0
jsonpath "$.result.resources[30].uri" == "{{base}}/self/v1/schemas/mcp/ping/request"
jsonpath "$.result.resources[30].name" == "Sourcemeta One MCP Ping Request"
jsonpath "$.result.resources[30].description" == "Liveness check from a client"
jsonpath "$.result.resources[30].mimeType" == "application/schema+json"
jsonpath "$.result.resources[30].size" == 695
jsonpath "$.result.resources[30].annotations.priority" == 0
jsonpath "$.result.resources[31].uri" == "{{base}}/self/v1/schemas/mcp/ping/response"
jsonpath "$.result.resources[31].name" == "Sourcemeta One MCP Ping Response"
jsonpath "$.result.resources[31].description" == "Sourcemeta One's response to a liveness check"
jsonpath "$.result.resources[31].mimeType" == "application/schema+json"
jsonpath "$.result.resources[31].size" == 598
jsonpath "$.result.resources[31].annotations.priority" == 0
jsonpath "$.result.resources[32].uri" == "{{base}}/self/v1/schemas/mcp/prm/response"
jsonpath "$.result.resources[32].name" == "Sourcemeta One MCP Protected Resource Metadata Response"
jsonpath "$.result.resources[32].description" == "The OAuth 2.0 Protected Resource Metadata describing where a token for this instance's Model Context Protocol endpoint is obtained, as defined by RFC 9728"
jsonpath "$.result.resources[32].mimeType" == "application/schema+json"
jsonpath "$.result.resources[32].size" == 2176
jsonpath "$.result.resources[32].annotations.priority" == 0
jsonpath "$.result.resources[33].uri" == "{{base}}/self/v1/schemas/mcp/request"
jsonpath "$.result.resources[33].name" == "Sourcemeta One MCP Request"
jsonpath "$.result.resources[33].description" == "Any incoming MCP request the server accepts. The body may be a single JSON-RPC envelope or a JSON-RPC 2.0 batch (an array of envelopes) on protocol version `2025-03-26`"
jsonpath "$.result.resources[33].mimeType" == "application/schema+json"
jsonpath "$.result.resources[33].size" == 2520
jsonpath "$.result.resources[33].annotations.priority" == 0
jsonpath "$.result.resources[34].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/request"
jsonpath "$.result.resources[34].name" == "Sourcemeta One MCP Resources List Request"
jsonpath "$.result.resources[34].description" == "Request from a client to list MCP resources"
jsonpath "$.result.resources[34].mimeType" == "application/schema+json"
jsonpath "$.result.resources[34].size" == 1071
jsonpath "$.result.resources[34].annotations.priority" == 0
jsonpath "$.result.resources[35].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/response"
jsonpath "$.result.resources[35].name" == "Sourcemeta One MCP Resources List Response"
jsonpath "$.result.resources[35].description" == "Sourcemeta One's list of MCP resources"
jsonpath "$.result.resources[35].mimeType" == "application/schema+json"
jsonpath "$.result.resources[35].size" == 3062
jsonpath "$.result.resources[35].annotations.priority" == 0
jsonpath "$.result.resources[36].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/request"
jsonpath "$.result.resources[36].name" == "Sourcemeta One MCP Resources Read Request"
jsonpath "$.result.resources[36].description" == "Request from a client to read an MCP resource"
jsonpath "$.result.resources[36].mimeType" == "application/schema+json"
jsonpath "$.result.resources[36].size" == 1293
jsonpath "$.result.resources[36].annotations.priority" == 0
jsonpath "$.result.resources[37].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/response"
jsonpath "$.result.resources[37].name" == "Sourcemeta One MCP Resources Read Response"
jsonpath "$.result.resources[37].description" == "Sourcemeta One's response containing an MCP resource"
jsonpath "$.result.resources[37].mimeType" == "application/schema+json"
jsonpath "$.result.resources[37].size" == 1754
jsonpath "$.result.resources[37].annotations.priority" == 0
jsonpath "$.result.resources[38].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/request"
jsonpath "$.result.resources[38].name" == "Sourcemeta One MCP Resources Templates List Request"
jsonpath "$.result.resources[38].description" == "Request from a client to list MCP resource templates"
jsonpath "$.result.resources[38].mimeType" == "application/schema+json"
jsonpath "$.result.resources[38].size" == 922
jsonpath "$.result.resources[38].annotations.priority" == 0
jsonpath "$.result.resources[39].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/response"
jsonpath "$.result.resources[39].name" == "Sourcemeta One MCP Resources Templates List Response"
jsonpath "$.result.resources[39].description" == "Sourcemeta One's list of MCP resource templates"
jsonpath "$.result.resources[39].mimeType" == "application/schema+json"
jsonpath "$.result.resources[39].size" == 2927
jsonpath "$.result.resources[39].annotations.priority" == 0
jsonpath "$.result.resources[40].uri" == "{{base}}/self/v1/schemas/mcp/response"
jsonpath "$.result.resources[40].name" == "Sourcemeta One MCP Response"
jsonpath "$.result.resources[40].description" == "Any outgoing MCP response the server returns"
jsonpath "$.result.resources[40].mimeType" == "application/schema+json"
jsonpath "$.result.resources[40].size" == 4799
jsonpath "$.result.resources[40].annotations.priority" == 0
jsonpath "$.result.resources[41].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/request"
jsonpath "$.result.resources[41].name" == "Sourcemeta One Schema Evaluate RPC Input"
jsonpath "$.result.resources[41].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[41].mimeType" == "application/schema+json"
jsonpath "$.result.resources[41].size" == 1566
jsonpath "$.result.resources[41].annotations.priority" == 0
jsonpath "$.result.resources[42].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/response"
jsonpath "$.result.resources[42].name" == "Sourcemeta One Schema Evaluate RPC Output"
jsonpath "$.result.resources[42].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[42].mimeType" == "application/schema+json"
jsonpath "$.result.resources[42].size" == 441
jsonpath "$.result.resources[42].annotations.priority" == 0
jsonpath "$.result.resources[43].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/request"
jsonpath "$.result.resources[43].name" == "Sourcemeta One Schema Dependencies RPC Input"
jsonpath "$.result.resources[43].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[43].mimeType" == "application/schema+json"
jsonpath "$.result.resources[43].size" == 687
jsonpath "$.result.resources[43].annotations.priority" == 0
jsonpath "$.result.resources[44].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/response"
jsonpath "$.result.resources[44].name" == "Sourcemeta One Schema Dependencies RPC Output"
jsonpath "$.result.resources[44].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[44].mimeType" == "application/schema+json"
jsonpath "$.result.resources[44].size" == 741
jsonpath "$.result.resources[44].annotations.priority" == 0
jsonpath "$.result.resources[45].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/request"
jsonpath "$.result.resources[45].name" == "Sourcemeta One Schema Dependents RPC Input"
jsonpath "$.result.resources[45].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[45].mimeType" == "application/schema+json"
jsonpath "$.result.resources[45].size" == 683
jsonpath "$.result.resources[45].annotations.priority" == 0
jsonpath "$.result.resources[46].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/response"
jsonpath "$.result.resources[46].name" == "Sourcemeta One Schema Dependents RPC Output"
jsonpath "$.result.resources[46].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[46].mimeType" == "application/schema+json"
jsonpath "$.result.resources[46].size" == 735
jsonpath "$.result.resources[46].annotations.priority" == 0
jsonpath "$.result.resources[47].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/request"
jsonpath "$.result.resources[47].name" == "Sourcemeta One Schema Health RPC Input"
jsonpath "$.result.resources[47].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[47].mimeType" == "application/schema+json"
jsonpath "$.result.resources[47].size" == 668
jsonpath "$.result.resources[47].annotations.priority" == 0
jsonpath "$.result.resources[48].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/response"
jsonpath "$.result.resources[48].name" == "Sourcemeta One Schema Health RPC Output"
jsonpath "$.result.resources[48].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[48].mimeType" == "application/schema+json"
jsonpath "$.result.resources[48].size" == 415
jsonpath "$.result.resources[48].annotations.priority" == 0
jsonpath "$.result.resources[49].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/request"
jsonpath "$.result.resources[49].name" == "Sourcemeta One Schema Locations RPC Input"
jsonpath "$.result.resources[49].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[49].mimeType" == "application/schema+json"
jsonpath "$.result.resources[49].size" == 720
jsonpath "$.result.resources[49].annotations.priority" == 0

# The primary key's second page.
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer primary-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "resources/list",
  "params": { "cursor": "50" }
}
```
HTTP 200
Content-Type: application/json
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4
jsonpath "$.result.resources" count == 22
jsonpath "$.result.nextCursor" not exists
jsonpath "$.result.resources[0].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/response"
jsonpath "$.result.resources[0].name" == "Sourcemeta One Schema Locations RPC Output"
jsonpath "$.result.resources[0].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 471
jsonpath "$.result.resources[0].annotations.priority" == 0
jsonpath "$.result.resources[1].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/request"
jsonpath "$.result.resources[1].name" == "Sourcemeta One Schema Metadata RPC Input"
jsonpath "$.result.resources[1].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 666
jsonpath "$.result.resources[1].annotations.priority" == 0
jsonpath "$.result.resources[2].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/response"
jsonpath "$.result.resources[2].name" == "Sourcemeta One Schema Metadata RPC Output"
jsonpath "$.result.resources[2].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 843
jsonpath "$.result.resources[2].annotations.priority" == 0
jsonpath "$.result.resources[3].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/request"
jsonpath "$.result.resources[3].name" == "Sourcemeta One Schema Positions RPC Input"
jsonpath "$.result.resources[3].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 682
jsonpath "$.result.resources[3].annotations.priority" == 0
jsonpath "$.result.resources[4].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/response"
jsonpath "$.result.resources[4].name" == "Sourcemeta One Schema Positions RPC Output"
jsonpath "$.result.resources[4].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 435
jsonpath "$.result.resources[4].annotations.priority" == 0
jsonpath "$.result.resources[5].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/request"
jsonpath "$.result.resources[5].name" == "Sourcemeta One Schema Statistics RPC Input"
jsonpath "$.result.resources[5].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 703
jsonpath "$.result.resources[5].annotations.priority" == 0
jsonpath "$.result.resources[6].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/response"
jsonpath "$.result.resources[6].name" == "Sourcemeta One Schema Statistics RPC Output"
jsonpath "$.result.resources[6].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 709
jsonpath "$.result.resources[6].annotations.priority" == 0
jsonpath "$.result.resources[7].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/request"
jsonpath "$.result.resources[7].name" == "Sourcemeta One Schema RDF RPC Input"
jsonpath "$.result.resources[7].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 2558
jsonpath "$.result.resources[7].annotations.priority" == 0
jsonpath "$.result.resources[8].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/response"
jsonpath "$.result.resources[8].name" == "Sourcemeta One Schema RDF RPC Output"
jsonpath "$.result.resources[8].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 1589
jsonpath "$.result.resources[8].annotations.priority" == 0
jsonpath "$.result.resources[9].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/request"
jsonpath "$.result.resources[9].name" == "Sourcemeta One Directory Listing RPC Input"
jsonpath "$.result.resources[9].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 549
jsonpath "$.result.resources[9].annotations.priority" == 0
jsonpath "$.result.resources[10].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/response"
jsonpath "$.result.resources[10].name" == "Sourcemeta One Directory Listing RPC Output"
jsonpath "$.result.resources[10].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 609
jsonpath "$.result.resources[10].annotations.priority" == 0
jsonpath "$.result.resources[11].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/request"
jsonpath "$.result.resources[11].name" == "Sourcemeta One Playground Schema Trace RPC Input"
jsonpath "$.result.resources[11].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 2296
jsonpath "$.result.resources[11].annotations.priority" == 0
jsonpath "$.result.resources[12].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/response"
jsonpath "$.result.resources[12].name" == "Sourcemeta One Playground Schema Trace RPC Output"
jsonpath "$.result.resources[12].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 559
jsonpath "$.result.resources[12].annotations.priority" == 0
jsonpath "$.result.resources[13].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/request"
jsonpath "$.result.resources[13].name" == "Sourcemeta One MCP Tools Call Request"
jsonpath "$.result.resources[13].description" == "Request from a client to invoke an MCP tool by name"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 1161
jsonpath "$.result.resources[13].annotations.priority" == 0
jsonpath "$.result.resources[14].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/response"
jsonpath "$.result.resources[14].name" == "Sourcemeta One MCP Tools Call Response"
jsonpath "$.result.resources[14].description" == "Sourcemeta One's response to a tool invocation"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 4668
jsonpath "$.result.resources[14].annotations.priority" == 0
jsonpath "$.result.resources[15].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/request"
jsonpath "$.result.resources[15].name" == "Sourcemeta One Schema Search RPC Input"
jsonpath "$.result.resources[15].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 2155
jsonpath "$.result.resources[15].annotations.priority" == 0
jsonpath "$.result.resources[16].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/response"
jsonpath "$.result.resources[16].name" == "Sourcemeta One Schema Search RPC Output"
jsonpath "$.result.resources[16].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 777
jsonpath "$.result.resources[16].annotations.priority" == 0
jsonpath "$.result.resources[17].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"
jsonpath "$.result.resources[17].name" == "Sourcemeta One Schema Trace RPC Input"
jsonpath "$.result.resources[17].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 1735
jsonpath "$.result.resources[17].annotations.priority" == 0
jsonpath "$.result.resources[18].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"
jsonpath "$.result.resources[18].name" == "Sourcemeta One Schema Trace RPC Output"
jsonpath "$.result.resources[18].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 497
jsonpath "$.result.resources[18].annotations.priority" == 0
jsonpath "$.result.resources[19].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/request"
jsonpath "$.result.resources[19].name" == "Sourcemeta One MCP Tools List Request"
jsonpath "$.result.resources[19].description" == "Request from a client to list MCP tools"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 853
jsonpath "$.result.resources[19].annotations.priority" == 0
jsonpath "$.result.resources[20].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/response"
jsonpath "$.result.resources[20].name" == "Sourcemeta One MCP Tools List Response"
jsonpath "$.result.resources[20].description" == "Sourcemeta One's list of MCP tools"
jsonpath "$.result.resources[20].mimeType" == "application/schema+json"
jsonpath "$.result.resources[20].size" == 4495
jsonpath "$.result.resources[20].annotations.priority" == 0
jsonpath "$.result.resources[21].uri" == "{{base}}/self/v1/schemas/api/playground/schemas/trace/request"
jsonpath "$.result.resources[21].name" == "Sourcemeta One Playground Schema Trace API Request"
jsonpath "$.result.resources[21].description" == "A JSON instance and the schema to trace its evaluation against"
jsonpath "$.result.resources[21].mimeType" == "application/schema+json"
jsonpath "$.result.resources[21].size" == 1124
jsonpath "$.result.resources[21].annotations.priority" == 0

# The internal key adds only the `/internal` schema; the `/private` and
# `/reports` schemas stay hidden.
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer internal-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "resources/list"
}
```
HTTP 200
Content-Type: application/json
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 5
jsonpath "$.result.resources" count == 50
jsonpath "$.result.nextCursor" == "50"
jsonpath "$.result.resources[0].uri" == "{{base}}/internal/config"
jsonpath "$.result.resources[0].name" == "/internal/config"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 166
jsonpath "$.result.resources[0].annotations.priority" == 0.5
jsonpath "$.result.resources[1].uri" == "{{base}}/orphan/lonely"
jsonpath "$.result.resources[1].name" == "/orphan/lonely"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 208
jsonpath "$.result.resources[1].annotations.priority" == 0.5
jsonpath "$.result.resources[2].uri" == "{{base}}/public/string"
jsonpath "$.result.resources[2].name" == "/public/string"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 131
jsonpath "$.result.resources[2].annotations.priority" == 0.5
jsonpath "$.result.resources[3].uri" == "{{base}}/self/v1/schemas/api/auth/login/response"
jsonpath "$.result.resources[3].name" == "Sourcemeta One Login API Response"
jsonpath "$.result.resources[3].description" == "The ways of signing in to this instance, which a custom interface reads to offer them"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 1735
jsonpath "$.result.resources[3].annotations.priority" == 0
jsonpath "$.result.resources[4].uri" == "{{base}}/self/v1/schemas/api/error"
jsonpath "$.result.resources[4].name" == "Sourcemeta One API Error"
jsonpath "$.result.resources[4].description" == "The error response format returned by the Sourcemeta One API endpoints"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 11208
jsonpath "$.result.resources[4].annotations.priority" == 0
jsonpath "$.result.resources[5].uri" == "{{base}}/self/v1/schemas/api/list/response"
jsonpath "$.result.resources[5].name" == "Sourcemeta One List API Response"
jsonpath "$.result.resources[5].description" == "The response format for the directory listing API endpoint"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 3878
jsonpath "$.result.resources[5].annotations.priority" == 0
jsonpath "$.result.resources[6].uri" == "{{base}}/self/v1/schemas/api/playground/schemas/trace/response"
jsonpath "$.result.resources[6].name" == "Sourcemeta One Playground Schema Trace API Response"
jsonpath "$.result.resources[6].description" == "The response format for tracing evaluation against a schema supplied in the request, which is what tracing against a schema in the catalog returns"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 501
jsonpath "$.result.resources[6].annotations.priority" == 0
jsonpath "$.result.resources[7].uri" == "{{base}}/self/v1/schemas/api/schemas/dependencies/response"
jsonpath "$.result.resources[7].name" == "Sourcemeta One Schema Dependencies API Response"
jsonpath "$.result.resources[7].description" == "The response format for the schema dependencies API endpoint"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 992
jsonpath "$.result.resources[7].annotations.priority" == 0
jsonpath "$.result.resources[8].uri" == "{{base}}/self/v1/schemas/api/schemas/dependents/response"
jsonpath "$.result.resources[8].name" == "Sourcemeta One Schema Dependents API Response"
jsonpath "$.result.resources[8].description" == "The response format for the schema dependents API endpoint"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 986
jsonpath "$.result.resources[8].annotations.priority" == 0
jsonpath "$.result.resources[9].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/request"
jsonpath "$.result.resources[9].name" == "Sourcemeta One Schema Evaluate API Request"
jsonpath "$.result.resources[9].description" == "The JSON instance to validate against a schema in the catalog"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 417
jsonpath "$.result.resources[9].annotations.priority" == 0
jsonpath "$.result.resources[10].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/response"
jsonpath "$.result.resources[10].name" == "Sourcemeta One Schema Evaluate API Response"
jsonpath "$.result.resources[10].description" == "The response format for the schema evaluation API endpoint"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 2138
jsonpath "$.result.resources[10].annotations.priority" == 0
jsonpath "$.result.resources[11].uri" == "{{base}}/self/v1/schemas/api/schemas/health/response"
jsonpath "$.result.resources[11].name" == "Sourcemeta One Schema Health API Response"
jsonpath "$.result.resources[11].description" == "The response format for the schema health API endpoint"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 1584
jsonpath "$.result.resources[11].annotations.priority" == 0
jsonpath "$.result.resources[12].uri" == "{{base}}/self/v1/schemas/api/schemas/locations/response"
jsonpath "$.result.resources[12].name" == "Sourcemeta One Schema Locations API Response"
jsonpath "$.result.resources[12].description" == "The response format for the schema frame locations API endpoint"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 2391
jsonpath "$.result.resources[12].annotations.priority" == 0
jsonpath "$.result.resources[13].uri" == "{{base}}/self/v1/schemas/api/schemas/metadata/response"
jsonpath "$.result.resources[13].name" == "Sourcemeta One Schema Metadata API Response"
jsonpath "$.result.resources[13].description" == "The response format for the schema metadata API endpoint"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 2943
jsonpath "$.result.resources[13].annotations.priority" == 0
jsonpath "$.result.resources[14].uri" == "{{base}}/self/v1/schemas/api/schemas/output-error"
jsonpath "$.result.resources[14].name" == "Sourcemeta One Schema Output Error"
jsonpath "$.result.resources[14].description" == "A single entry of the standard JSON Schema output format that describes why an instance does not conform to a schema"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 1143
jsonpath "$.result.resources[14].annotations.priority" == 0
jsonpath "$.result.resources[15].uri" == "{{base}}/self/v1/schemas/api/schemas/position"
jsonpath "$.result.resources[15].name" == "Sourcemeta One Schema Position"
jsonpath "$.result.resources[15].description" == "Represents a position in a JSON document as line start, column start, line end, and column end"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 446
jsonpath "$.result.resources[15].annotations.priority" == 0
jsonpath "$.result.resources[16].uri" == "{{base}}/self/v1/schemas/api/schemas/positions/response"
jsonpath "$.result.resources[16].name" == "Sourcemeta One Schema Positions API Response"
jsonpath "$.result.resources[16].description" == "The response format for the schema positions API endpoint"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 435
jsonpath "$.result.resources[16].annotations.priority" == 0
jsonpath "$.result.resources[17].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/request"
jsonpath "$.result.resources[17].name" == "Sourcemeta One Schema RDF API Request"
jsonpath "$.result.resources[17].description" == "The JSON instance to promote to JSON-LD against a schema in the catalog, along with the desired output form"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 1422
jsonpath "$.result.resources[17].annotations.priority" == 0
jsonpath "$.result.resources[18].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/response"
jsonpath "$.result.resources[18].name" == "Sourcemeta One Schema RDF API Response"
jsonpath "$.result.resources[18].description" == "The instance promoted to JSON-LD, in expanded, flattened, or compacted form"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 799
jsonpath "$.result.resources[18].annotations.priority" == 0
jsonpath "$.result.resources[19].uri" == "{{base}}/self/v1/schemas/api/schemas/search/response"
jsonpath "$.result.resources[19].name" == "Sourcemeta One Schema Search API Response"
jsonpath "$.result.resources[19].description" == "The response format for the schema search API endpoint"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 1341
jsonpath "$.result.resources[19].annotations.priority" == 0
jsonpath "$.result.resources[20].uri" == "{{base}}/self/v1/schemas/api/schemas/stats/response"
jsonpath "$.result.resources[20].name" == "Sourcemeta One Schema Stats API Response"
jsonpath "$.result.resources[20].description" == "The response format for the schema statistics API endpoint"
jsonpath "$.result.resources[20].mimeType" == "application/schema+json"
jsonpath "$.result.resources[20].size" == 2345
jsonpath "$.result.resources[20].annotations.priority" == 0
jsonpath "$.result.resources[21].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/request"
jsonpath "$.result.resources[21].name" == "Sourcemeta One Schema Trace API Request"
jsonpath "$.result.resources[21].description" == "The JSON instance to trace evaluation against a schema in the catalog"
jsonpath "$.result.resources[21].mimeType" == "application/schema+json"
jsonpath "$.result.resources[21].size" == 419
jsonpath "$.result.resources[21].annotations.priority" == 0
jsonpath "$.result.resources[22].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/response"
jsonpath "$.result.resources[22].name" == "Sourcemeta One Schema Trace API Response"
jsonpath "$.result.resources[22].description" == "The response format for the schema trace API endpoint"
jsonpath "$.result.resources[22].mimeType" == "application/schema+json"
jsonpath "$.result.resources[22].size" == 2290
jsonpath "$.result.resources[22].annotations.priority" == 0
jsonpath "$.result.resources[23].uri" == "{{base}}/self/v1/schemas/mcp/error"
jsonpath "$.result.resources[23].name" == "Sourcemeta One MCP Error Response"
jsonpath "$.result.resources[23].description" == "The error response Sourcemeta One returns when an MCP request fails"
jsonpath "$.result.resources[23].mimeType" == "application/schema+json"
jsonpath "$.result.resources[23].size" == 5860
jsonpath "$.result.resources[23].annotations.priority" == 0
jsonpath "$.result.resources[24].uri" == "{{base}}/self/v1/schemas/mcp/initialize/request"
jsonpath "$.result.resources[24].name" == "Sourcemeta One MCP Initialize Request"
jsonpath "$.result.resources[24].description" == "Connection handshake from a client"
jsonpath "$.result.resources[24].mimeType" == "application/schema+json"
jsonpath "$.result.resources[24].size" == 4617
jsonpath "$.result.resources[24].annotations.priority" == 0
jsonpath "$.result.resources[25].uri" == "{{base}}/self/v1/schemas/mcp/initialize/response"
jsonpath "$.result.resources[25].name" == "Sourcemeta One MCP Initialize Response"
jsonpath "$.result.resources[25].description" == "Sourcemeta One's response to a client's initialization"
jsonpath "$.result.resources[25].mimeType" == "application/schema+json"
jsonpath "$.result.resources[25].size" == 2524
jsonpath "$.result.resources[25].annotations.priority" == 0
jsonpath "$.result.resources[26].uri" == "{{base}}/self/v1/schemas/mcp/notifications/cancelled"
jsonpath "$.result.resources[26].name" == "Sourcemeta One MCP Cancelled Notification"
jsonpath "$.result.resources[26].description" == "Cancellation hint from a client for an in-flight request. Sourcemeta One accepts and discards these"
jsonpath "$.result.resources[26].mimeType" == "application/schema+json"
jsonpath "$.result.resources[26].size" == 1163
jsonpath "$.result.resources[26].annotations.priority" == 0
jsonpath "$.result.resources[27].uri" == "{{base}}/self/v1/schemas/mcp/notifications/initialized"
jsonpath "$.result.resources[27].name" == "Sourcemeta One MCP Initialized Notification"
jsonpath "$.result.resources[27].description" == "Client signal that the handshake is complete and normal operation may begin"
jsonpath "$.result.resources[27].mimeType" == "application/schema+json"
jsonpath "$.result.resources[27].size" == 740
jsonpath "$.result.resources[27].annotations.priority" == 0
jsonpath "$.result.resources[28].uri" == "{{base}}/self/v1/schemas/mcp/ping/request"
jsonpath "$.result.resources[28].name" == "Sourcemeta One MCP Ping Request"
jsonpath "$.result.resources[28].description" == "Liveness check from a client"
jsonpath "$.result.resources[28].mimeType" == "application/schema+json"
jsonpath "$.result.resources[28].size" == 695
jsonpath "$.result.resources[28].annotations.priority" == 0
jsonpath "$.result.resources[29].uri" == "{{base}}/self/v1/schemas/mcp/ping/response"
jsonpath "$.result.resources[29].name" == "Sourcemeta One MCP Ping Response"
jsonpath "$.result.resources[29].description" == "Sourcemeta One's response to a liveness check"
jsonpath "$.result.resources[29].mimeType" == "application/schema+json"
jsonpath "$.result.resources[29].size" == 598
jsonpath "$.result.resources[29].annotations.priority" == 0
jsonpath "$.result.resources[30].uri" == "{{base}}/self/v1/schemas/mcp/prm/response"
jsonpath "$.result.resources[30].name" == "Sourcemeta One MCP Protected Resource Metadata Response"
jsonpath "$.result.resources[30].description" == "The OAuth 2.0 Protected Resource Metadata describing where a token for this instance's Model Context Protocol endpoint is obtained, as defined by RFC 9728"
jsonpath "$.result.resources[30].mimeType" == "application/schema+json"
jsonpath "$.result.resources[30].size" == 2176
jsonpath "$.result.resources[30].annotations.priority" == 0
jsonpath "$.result.resources[31].uri" == "{{base}}/self/v1/schemas/mcp/request"
jsonpath "$.result.resources[31].name" == "Sourcemeta One MCP Request"
jsonpath "$.result.resources[31].description" == "Any incoming MCP request the server accepts. The body may be a single JSON-RPC envelope or a JSON-RPC 2.0 batch (an array of envelopes) on protocol version `2025-03-26`"
jsonpath "$.result.resources[31].mimeType" == "application/schema+json"
jsonpath "$.result.resources[31].size" == 2520
jsonpath "$.result.resources[31].annotations.priority" == 0
jsonpath "$.result.resources[32].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/request"
jsonpath "$.result.resources[32].name" == "Sourcemeta One MCP Resources List Request"
jsonpath "$.result.resources[32].description" == "Request from a client to list MCP resources"
jsonpath "$.result.resources[32].mimeType" == "application/schema+json"
jsonpath "$.result.resources[32].size" == 1071
jsonpath "$.result.resources[32].annotations.priority" == 0
jsonpath "$.result.resources[33].uri" == "{{base}}/self/v1/schemas/mcp/resources/list/response"
jsonpath "$.result.resources[33].name" == "Sourcemeta One MCP Resources List Response"
jsonpath "$.result.resources[33].description" == "Sourcemeta One's list of MCP resources"
jsonpath "$.result.resources[33].mimeType" == "application/schema+json"
jsonpath "$.result.resources[33].size" == 3062
jsonpath "$.result.resources[33].annotations.priority" == 0
jsonpath "$.result.resources[34].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/request"
jsonpath "$.result.resources[34].name" == "Sourcemeta One MCP Resources Read Request"
jsonpath "$.result.resources[34].description" == "Request from a client to read an MCP resource"
jsonpath "$.result.resources[34].mimeType" == "application/schema+json"
jsonpath "$.result.resources[34].size" == 1293
jsonpath "$.result.resources[34].annotations.priority" == 0
jsonpath "$.result.resources[35].uri" == "{{base}}/self/v1/schemas/mcp/resources/read/response"
jsonpath "$.result.resources[35].name" == "Sourcemeta One MCP Resources Read Response"
jsonpath "$.result.resources[35].description" == "Sourcemeta One's response containing an MCP resource"
jsonpath "$.result.resources[35].mimeType" == "application/schema+json"
jsonpath "$.result.resources[35].size" == 1754
jsonpath "$.result.resources[35].annotations.priority" == 0
jsonpath "$.result.resources[36].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/request"
jsonpath "$.result.resources[36].name" == "Sourcemeta One MCP Resources Templates List Request"
jsonpath "$.result.resources[36].description" == "Request from a client to list MCP resource templates"
jsonpath "$.result.resources[36].mimeType" == "application/schema+json"
jsonpath "$.result.resources[36].size" == 922
jsonpath "$.result.resources[36].annotations.priority" == 0
jsonpath "$.result.resources[37].uri" == "{{base}}/self/v1/schemas/mcp/resources/templates/list/response"
jsonpath "$.result.resources[37].name" == "Sourcemeta One MCP Resources Templates List Response"
jsonpath "$.result.resources[37].description" == "Sourcemeta One's list of MCP resource templates"
jsonpath "$.result.resources[37].mimeType" == "application/schema+json"
jsonpath "$.result.resources[37].size" == 2927
jsonpath "$.result.resources[37].annotations.priority" == 0
jsonpath "$.result.resources[38].uri" == "{{base}}/self/v1/schemas/mcp/response"
jsonpath "$.result.resources[38].name" == "Sourcemeta One MCP Response"
jsonpath "$.result.resources[38].description" == "Any outgoing MCP response the server returns"
jsonpath "$.result.resources[38].mimeType" == "application/schema+json"
jsonpath "$.result.resources[38].size" == 4799
jsonpath "$.result.resources[38].annotations.priority" == 0
jsonpath "$.result.resources[39].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/request"
jsonpath "$.result.resources[39].name" == "Sourcemeta One Schema Evaluate RPC Input"
jsonpath "$.result.resources[39].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[39].mimeType" == "application/schema+json"
jsonpath "$.result.resources[39].size" == 1566
jsonpath "$.result.resources[39].annotations.priority" == 0
jsonpath "$.result.resources[40].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/response"
jsonpath "$.result.resources[40].name" == "Sourcemeta One Schema Evaluate RPC Output"
jsonpath "$.result.resources[40].description" == "Evaluate a JSON instance against a schema in the catalog and return whether it is valid plus any errors"
jsonpath "$.result.resources[40].mimeType" == "application/schema+json"
jsonpath "$.result.resources[40].size" == 441
jsonpath "$.result.resources[40].annotations.priority" == 0
jsonpath "$.result.resources[41].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/request"
jsonpath "$.result.resources[41].name" == "Sourcemeta One Schema Dependencies RPC Input"
jsonpath "$.result.resources[41].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[41].mimeType" == "application/schema+json"
jsonpath "$.result.resources[41].size" == 687
jsonpath "$.result.resources[41].annotations.priority" == 0
jsonpath "$.result.resources[42].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/response"
jsonpath "$.result.resources[42].name" == "Sourcemeta One Schema Dependencies RPC Output"
jsonpath "$.result.resources[42].description" == "Get all direct and indirect dependencies of a schema in the catalog"
jsonpath "$.result.resources[42].mimeType" == "application/schema+json"
jsonpath "$.result.resources[42].size" == 741
jsonpath "$.result.resources[42].annotations.priority" == 0
jsonpath "$.result.resources[43].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/request"
jsonpath "$.result.resources[43].name" == "Sourcemeta One Schema Dependents RPC Input"
jsonpath "$.result.resources[43].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[43].mimeType" == "application/schema+json"
jsonpath "$.result.resources[43].size" == 683
jsonpath "$.result.resources[43].annotations.priority" == 0
jsonpath "$.result.resources[44].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/response"
jsonpath "$.result.resources[44].name" == "Sourcemeta One Schema Dependents RPC Output"
jsonpath "$.result.resources[44].description" == "Get all direct and transitive dependents of a schema in the catalog"
jsonpath "$.result.resources[44].mimeType" == "application/schema+json"
jsonpath "$.result.resources[44].size" == 735
jsonpath "$.result.resources[44].annotations.priority" == 0
jsonpath "$.result.resources[45].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/request"
jsonpath "$.result.resources[45].name" == "Sourcemeta One Schema Health RPC Input"
jsonpath "$.result.resources[45].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[45].mimeType" == "application/schema+json"
jsonpath "$.result.resources[45].size" == 668
jsonpath "$.result.resources[45].annotations.priority" == 0
jsonpath "$.result.resources[46].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/response"
jsonpath "$.result.resources[46].name" == "Sourcemeta One Schema Health RPC Output"
jsonpath "$.result.resources[46].description" == "Get the health analysis and score of a schema in the catalog"
jsonpath "$.result.resources[46].mimeType" == "application/schema+json"
jsonpath "$.result.resources[46].size" == 415
jsonpath "$.result.resources[46].annotations.priority" == 0
jsonpath "$.result.resources[47].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/request"
jsonpath "$.result.resources[47].name" == "Sourcemeta One Schema Locations RPC Input"
jsonpath "$.result.resources[47].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[47].mimeType" == "application/schema+json"
jsonpath "$.result.resources[47].size" == 720
jsonpath "$.result.resources[47].annotations.priority" == 0
jsonpath "$.result.resources[48].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/response"
jsonpath "$.result.resources[48].name" == "Sourcemeta One Schema Locations RPC Output"
jsonpath "$.result.resources[48].description" == "Get metadata about every URI associated with a schema, including schema resources, subschemas, and anchors"
jsonpath "$.result.resources[48].mimeType" == "application/schema+json"
jsonpath "$.result.resources[48].size" == 471
jsonpath "$.result.resources[48].annotations.priority" == 0
jsonpath "$.result.resources[49].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/request"
jsonpath "$.result.resources[49].name" == "Sourcemeta One Schema Metadata RPC Input"
jsonpath "$.result.resources[49].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[49].mimeType" == "application/schema+json"
jsonpath "$.result.resources[49].size" == 666
jsonpath "$.result.resources[49].annotations.priority" == 0

# The internal key's second page.
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer internal-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 6,
  "method": "resources/list",
  "params": { "cursor": "50" }
}
```
HTTP 200
Content-Type: application/json
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 6
jsonpath "$.result.resources" count == 20
jsonpath "$.result.nextCursor" not exists
jsonpath "$.result.resources[0].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/response"
jsonpath "$.result.resources[0].name" == "Sourcemeta One Schema Metadata RPC Output"
jsonpath "$.result.resources[0].description" == "Get metadata information about a schema in the catalog"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 843
jsonpath "$.result.resources[0].annotations.priority" == 0
jsonpath "$.result.resources[1].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/request"
jsonpath "$.result.resources[1].name" == "Sourcemeta One Schema Positions RPC Input"
jsonpath "$.result.resources[1].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 682
jsonpath "$.result.resources[1].annotations.priority" == 0
jsonpath "$.result.resources[2].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/response"
jsonpath "$.result.resources[2].name" == "Sourcemeta One Schema Positions RPC Output"
jsonpath "$.result.resources[2].description" == "Get line and column position information for every token in a schema"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 435
jsonpath "$.result.resources[2].annotations.priority" == 0
jsonpath "$.result.resources[3].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/request"
jsonpath "$.result.resources[3].name" == "Sourcemeta One Schema Statistics RPC Input"
jsonpath "$.result.resources[3].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 703
jsonpath "$.result.resources[3].annotations.priority" == 0
jsonpath "$.result.resources[4].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/response"
jsonpath "$.result.resources[4].name" == "Sourcemeta One Schema Statistics RPC Output"
jsonpath "$.result.resources[4].description" == "Get keyword statistics by vocabulary about every URI associated with a schema in the catalog"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 709
jsonpath "$.result.resources[4].annotations.priority" == 0
jsonpath "$.result.resources[5].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/request"
jsonpath "$.result.resources[5].name" == "Sourcemeta One Schema RDF RPC Input"
jsonpath "$.result.resources[5].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 2558
jsonpath "$.result.resources[5].annotations.priority" == 0
jsonpath "$.result.resources[6].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/response"
jsonpath "$.result.resources[6].name" == "Sourcemeta One Schema RDF RPC Output"
jsonpath "$.result.resources[6].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 1589
jsonpath "$.result.resources[6].annotations.priority" == 0
jsonpath "$.result.resources[7].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/request"
jsonpath "$.result.resources[7].name" == "Sourcemeta One Directory Listing RPC Input"
jsonpath "$.result.resources[7].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 549
jsonpath "$.result.resources[7].annotations.priority" == 0
jsonpath "$.result.resources[8].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/response"
jsonpath "$.result.resources[8].name" == "Sourcemeta One Directory Listing RPC Output"
jsonpath "$.result.resources[8].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 609
jsonpath "$.result.resources[8].annotations.priority" == 0
jsonpath "$.result.resources[9].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/request"
jsonpath "$.result.resources[9].name" == "Sourcemeta One Playground Schema Trace RPC Input"
jsonpath "$.result.resources[9].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 2296
jsonpath "$.result.resources[9].annotations.priority" == 0
jsonpath "$.result.resources[10].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/playground-trace-schema/response"
jsonpath "$.result.resources[10].name" == "Sourcemeta One Playground Schema Trace RPC Output"
jsonpath "$.result.resources[10].description" == "Trace step-by-step evaluation of a JSON instance against a schema supplied in the request rather than one in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 559
jsonpath "$.result.resources[10].annotations.priority" == 0
jsonpath "$.result.resources[11].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/request"
jsonpath "$.result.resources[11].name" == "Sourcemeta One MCP Tools Call Request"
jsonpath "$.result.resources[11].description" == "Request from a client to invoke an MCP tool by name"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 1161
jsonpath "$.result.resources[11].annotations.priority" == 0
jsonpath "$.result.resources[12].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/response"
jsonpath "$.result.resources[12].name" == "Sourcemeta One MCP Tools Call Response"
jsonpath "$.result.resources[12].description" == "Sourcemeta One's response to a tool invocation"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 4668
jsonpath "$.result.resources[12].annotations.priority" == 0
jsonpath "$.result.resources[13].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/request"
jsonpath "$.result.resources[13].name" == "Sourcemeta One Schema Search RPC Input"
jsonpath "$.result.resources[13].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 2155
jsonpath "$.result.resources[13].annotations.priority" == 0
jsonpath "$.result.resources[14].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/response"
jsonpath "$.result.resources[14].name" == "Sourcemeta One Schema Search RPC Output"
jsonpath "$.result.resources[14].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 777
jsonpath "$.result.resources[14].annotations.priority" == 0
jsonpath "$.result.resources[15].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"
jsonpath "$.result.resources[15].name" == "Sourcemeta One Schema Trace RPC Input"
jsonpath "$.result.resources[15].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 1735
jsonpath "$.result.resources[15].annotations.priority" == 0
jsonpath "$.result.resources[16].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"
jsonpath "$.result.resources[16].name" == "Sourcemeta One Schema Trace RPC Output"
jsonpath "$.result.resources[16].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 497
jsonpath "$.result.resources[16].annotations.priority" == 0
jsonpath "$.result.resources[17].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/request"
jsonpath "$.result.resources[17].name" == "Sourcemeta One MCP Tools List Request"
jsonpath "$.result.resources[17].description" == "Request from a client to list MCP tools"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 853
jsonpath "$.result.resources[17].annotations.priority" == 0
jsonpath "$.result.resources[18].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/response"
jsonpath "$.result.resources[18].name" == "Sourcemeta One MCP Tools List Response"
jsonpath "$.result.resources[18].description" == "Sourcemeta One's list of MCP tools"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 4495
jsonpath "$.result.resources[18].annotations.priority" == 0
jsonpath "$.result.resources[19].uri" == "{{base}}/self/v1/schemas/api/playground/schemas/trace/request"
jsonpath "$.result.resources[19].name" == "Sourcemeta One Playground Schema Trace API Request"
jsonpath "$.result.resources[19].description" == "A JSON instance and the schema to trace its evaluation against"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 1124
jsonpath "$.result.resources[19].annotations.priority" == 0

# A cursor that is not aligned to a page boundary is rejected before the catalog
# is scanned, so a malformed cursor cannot force a full scan.
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 7,
  "method": "resources/list",
  "params": { "cursor": "7" }
}
```
HTTP 200
Content-Type: application/json
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 7
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid resource list cursor"
jsonpath "$.error.data" == "Use the `nextCursor` returned by a prior resources/list response, or omit it to start from the beginning"
jsonpath "$.result" not exists

# A page-aligned cursor past the end of the filtered catalog is out of range.
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 8,
  "method": "resources/list",
  "params": { "cursor": "5000" }
}
```
HTTP 200
Content-Type: application/json
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 8
jsonpath "$.error.code" == -32602
jsonpath "$.result" not exists

# A non-numeric cursor is rejected outright.
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 9,
  "method": "resources/list",
  "params": { "cursor": "abc" }
}
```
HTTP 200
Content-Type: application/json
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 9
jsonpath "$.error.code" == -32602
