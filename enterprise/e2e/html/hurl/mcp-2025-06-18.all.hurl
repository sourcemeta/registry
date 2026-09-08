POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-06-18
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "initialize",
  "params": {
    "protocolVersion": "2025-06-18",
    "capabilities": {},
    "clientInfo": { "name": "hurl", "version": "1.0.0" }
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:8000
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-06-18
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
jsonpath "$.id" == 1
jsonpath "$.result.protocolVersion" matches "^\\d{4}-\\d{2}-\\d{2}$"
jsonpath "$.result.capabilities.resources" isObject
jsonpath "$.result.capabilities.resources" isEmpty
jsonpath "$.result.capabilities.tools" isObject
jsonpath "$.result.capabilities.tools" isEmpty
jsonpath "$.result.serverInfo.name" == "sourcemeta-one-enterprise"
jsonpath "$.result.serverInfo.title" == "Sourcemeta One Enterprise"
jsonpath "$.result.serverInfo.version" matches "^.+$"
jsonpath "$.result.instructions" matches "^.+$"
# Added in 2025-11-25
# https://modelcontextprotocol.io/specification/2025-11-25/changelog
jsonpath "$.result.serverInfo.description" not exists
jsonpath "$.result.serverInfo.websiteUrl" not exists

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
MCP-Protocol-Version: 2025-06-18
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 2, "method": "resources/templates/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:8000
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-06-18
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
jsonpath "$.id" == 2
jsonpath "$.result.resourceTemplates" count == 1
jsonpath "$.result.resourceTemplates[0].uriTemplate" == "{{base}}/{+path}{?bundle}"
jsonpath "$.result.resourceTemplates[0].name" == "JSON Schema"
jsonpath "$.result.resourceTemplates[0].description" == "A JSON Schema in this catalog, addressable by its canonical absolute URI under this server's origin. This instance is sovereign over its own URL namespace. Schemas whose URIs lie outside this namespace will not be served here. Substitute `{+path}` with the schema's catalog path. Include `{?bundle}` (its presence alone triggers bundling, any value is ignored) to receive the schema with every external `$ref` inlined into a single self-contained document. The URI must not contain a fragment. Use `resources/list` to discover the available schemas rather than guessing paths"
jsonpath "$.result.resourceTemplates[0].mimeType" == "application/schema+json"
# Added in 2025-11-25 (SEP-973)
# https://github.com/modelcontextprotocol/modelcontextprotocol/issues/973
jsonpath "$..icons" not exists

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
MCP-Protocol-Version: 2025-06-18
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 3, "method": "resources/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:8000
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-06-18
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
jsonpath "$.id" == 3
jsonpath "$.result.resources" count == 50
jsonpath "$.result.resources[0].uri" == "{{base}}/twins/foo"
jsonpath "$.result.resources[0].name" == "Twin Foo Schema"
jsonpath "$.result.resources[0].description" == "A schema whose base name collides with a sibling directory"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 263
jsonpath "$.result.resources[0].annotations.priority" == 0.5
jsonpath "$.result.resources[1].uri" == "{{base}}/twins/foo/inner"
jsonpath "$.result.resources[1].name" == "Twin Foo Inner"
jsonpath "$.result.resources[1].description" == "A schema inside the foo directory whose name collides with a sibling schema"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 280
jsonpath "$.result.resources[1].annotations.priority" == 0.5
jsonpath "$.result.resources[2].uri" == "{{base}}/test/jsonld/product"
jsonpath "$.result.resources[2].name" == "Product"
jsonpath "$.result.resources[2].description" == "A product annotated with JSON-LD mappings"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 1319
jsonpath "$.result.resources[2].annotations.priority" == 0.5
jsonpath "$.result.resources[3].uri" == "{{base}}/test/jsonld/facets"
jsonpath "$.result.resources[3].name" == "Unresolvable Facets"
jsonpath "$.result.resources[3].description" == "A schema whose JSON-LD annotations fail on a distinct facet per property"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 545
jsonpath "$.result.resources[3].annotations.priority" == 0.5
jsonpath "$.result.resources[4].uri" == "{{base}}/test/object"
jsonpath "$.result.resources[4].name" == "My Object"
jsonpath "$.result.resources[4].description" == "An Object Example"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 322
jsonpath "$.result.resources[4].annotations.priority" == 0.5
jsonpath "$.result.resources[5].uri" == "{{base}}/test/jsonld/draft7"
jsonpath "$.result.resources[5].name" == "Legacy Dialect"
jsonpath "$.result.resources[5].description" == "A schema on a dialect without annotation support"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 343
jsonpath "$.result.resources[5].annotations.priority" == 0.5
jsonpath "$.result.resources[6].uri" == "{{base}}/test/full/01"
jsonpath "$.result.resources[6].name" == "Full 01"
jsonpath "$.result.resources[6].description" == "A schema with both a title and a description (01)"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 222
jsonpath "$.result.resources[6].annotations.priority" == 0.5
jsonpath "$.result.resources[7].uri" == "{{base}}/test/full/02"
jsonpath "$.result.resources[7].name" == "Full 02"
jsonpath "$.result.resources[7].description" == "A schema with both a title and a description (02)"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 222
jsonpath "$.result.resources[7].annotations.priority" == 0.5
jsonpath "$.result.resources[8].uri" == "{{base}}/test/full/03"
jsonpath "$.result.resources[8].name" == "Full 03"
jsonpath "$.result.resources[8].description" == "A schema with both a title and a description (03)"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 222
jsonpath "$.result.resources[8].annotations.priority" == 0.5
jsonpath "$.result.resources[9].uri" == "{{base}}/test/full/04"
jsonpath "$.result.resources[9].name" == "Full 04"
jsonpath "$.result.resources[9].description" == "A schema with both a title and a description (04)"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 222
jsonpath "$.result.resources[9].annotations.priority" == 0.5
jsonpath "$.result.resources[10].uri" == "{{base}}/test/full/05"
jsonpath "$.result.resources[10].name" == "Full 05"
jsonpath "$.result.resources[10].description" == "A schema with both a title and a description (05)"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 222
jsonpath "$.result.resources[10].annotations.priority" == 0.5
jsonpath "$.result.resources[11].uri" == "{{base}}/test/jsonld/conflict"
jsonpath "$.result.resources[11].name" == "Conflicting Mapping"
jsonpath "$.result.resources[11].description" == "A schema whose JSON-LD annotations cannot resolve"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 286
jsonpath "$.result.resources[11].annotations.priority" == 0.5
jsonpath "$.result.resources[12].uri" == "{{base}}/test/jsonld/plain"
jsonpath "$.result.resources[12].name" == "Plain"
jsonpath "$.result.resources[12].description" == "A schema without JSON-LD annotations"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 212
jsonpath "$.result.resources[12].annotations.priority" == 0.5
jsonpath "$.result.resources[13].uri" == "{{base}}/test/description-only/01"
jsonpath "$.result.resources[13].name" == "/test/description-only/01"
jsonpath "$.result.resources[13].description" == "A schema with only a description (01)"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 200
jsonpath "$.result.resources[13].annotations.priority" == 0.5
jsonpath "$.result.resources[14].uri" == "{{base}}/test/description-only/02"
jsonpath "$.result.resources[14].name" == "/test/description-only/02"
jsonpath "$.result.resources[14].description" == "A schema with only a description (02)"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 200
jsonpath "$.result.resources[14].annotations.priority" == 0.5
jsonpath "$.result.resources[15].uri" == "{{base}}/test/description-only/03"
jsonpath "$.result.resources[15].name" == "/test/description-only/03"
jsonpath "$.result.resources[15].description" == "A schema with only a description (03)"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 200
jsonpath "$.result.resources[15].annotations.priority" == 0.5
jsonpath "$.result.resources[16].uri" == "{{base}}/test/description-only/04"
jsonpath "$.result.resources[16].name" == "/test/description-only/04"
jsonpath "$.result.resources[16].description" == "A schema with only a description (04)"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 200
jsonpath "$.result.resources[16].annotations.priority" == 0.5
jsonpath "$.result.resources[17].uri" == "{{base}}/test/description-only/05"
jsonpath "$.result.resources[17].name" == "/test/description-only/05"
jsonpath "$.result.resources[17].description" == "A schema with only a description (05)"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 200
jsonpath "$.result.resources[17].annotations.priority" == 0.5
jsonpath "$.result.resources[18].uri" == "{{base}}/test/title-only/01"
jsonpath "$.result.resources[18].name" == "Title Only 01"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 164
jsonpath "$.result.resources[18].annotations.priority" == 0.5
jsonpath "$.result.resources[19].uri" == "{{base}}/test/title-only/02"
jsonpath "$.result.resources[19].name" == "Title Only 02"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 164
jsonpath "$.result.resources[19].annotations.priority" == 0.5
jsonpath "$.result.resources[20].uri" == "{{base}}/test/title-only/03"
jsonpath "$.result.resources[20].name" == "Title Only 03"
jsonpath "$.result.resources[20].mimeType" == "application/schema+json"
jsonpath "$.result.resources[20].size" == 164
jsonpath "$.result.resources[20].annotations.priority" == 0.5
jsonpath "$.result.resources[21].uri" == "{{base}}/test/title-only/04"
jsonpath "$.result.resources[21].name" == "Title Only 04"
jsonpath "$.result.resources[21].mimeType" == "application/schema+json"
jsonpath "$.result.resources[21].size" == 164
jsonpath "$.result.resources[21].annotations.priority" == 0.5
jsonpath "$.result.resources[22].uri" == "{{base}}/test/title-only/05"
jsonpath "$.result.resources[22].name" == "Title Only 05"
jsonpath "$.result.resources[22].mimeType" == "application/schema+json"
jsonpath "$.result.resources[22].size" == 164
jsonpath "$.result.resources[22].annotations.priority" == 0.5
jsonpath "$.result.resources[23].uri" == "{{base}}/test/draft3/with-ref"
jsonpath "$.result.resources[23].name" == "/test/draft3/with-ref"
jsonpath "$.result.resources[23].mimeType" == "application/schema+json"
jsonpath "$.result.resources[23].size" == 197
jsonpath "$.result.resources[23].annotations.priority" == 0.5
jsonpath "$.result.resources[24].uri" == "{{base}}/no-blaze/jsonld"
jsonpath "$.result.resources[24].name" == "/no-blaze/jsonld"
jsonpath "$.result.resources[24].mimeType" == "application/schema+json"
jsonpath "$.result.resources[24].size" == 180
jsonpath "$.result.resources[24].annotations.priority" == 0.5
jsonpath "$.result.resources[25].uri" == "{{base}}/no-blaze/string"
jsonpath "$.result.resources[25].name" == "/no-blaze/string"
jsonpath "$.result.resources[25].mimeType" == "application/schema+json"
jsonpath "$.result.resources[25].size" == 133
jsonpath "$.result.resources[25].annotations.priority" == 0.5
jsonpath "$.result.resources[26].uri" == "{{base}}/test/bare/01"
jsonpath "$.result.resources[26].name" == "/test/bare/01"
jsonpath "$.result.resources[26].mimeType" == "application/schema+json"
jsonpath "$.result.resources[26].size" == 130
jsonpath "$.result.resources[26].annotations.priority" == 0.5
jsonpath "$.result.resources[27].uri" == "{{base}}/test/bare/02"
jsonpath "$.result.resources[27].name" == "/test/bare/02"
jsonpath "$.result.resources[27].mimeType" == "application/schema+json"
jsonpath "$.result.resources[27].size" == 130
jsonpath "$.result.resources[27].annotations.priority" == 0.5
jsonpath "$.result.resources[28].uri" == "{{base}}/test/bare/03"
jsonpath "$.result.resources[28].name" == "/test/bare/03"
jsonpath "$.result.resources[28].mimeType" == "application/schema+json"
jsonpath "$.result.resources[28].size" == 130
jsonpath "$.result.resources[28].annotations.priority" == 0.5
jsonpath "$.result.resources[29].uri" == "{{base}}/test/bare/04"
jsonpath "$.result.resources[29].name" == "/test/bare/04"
jsonpath "$.result.resources[29].mimeType" == "application/schema+json"
jsonpath "$.result.resources[29].size" == 130
jsonpath "$.result.resources[29].annotations.priority" == 0.5
jsonpath "$.result.resources[30].uri" == "{{base}}/test/bare/05"
jsonpath "$.result.resources[30].name" == "/test/bare/05"
jsonpath "$.result.resources[30].mimeType" == "application/schema+json"
jsonpath "$.result.resources[30].size" == 130
jsonpath "$.result.resources[30].annotations.priority" == 0.5
jsonpath "$.result.resources[31].uri" == "{{base}}/test/bare/06"
jsonpath "$.result.resources[31].name" == "/test/bare/06"
jsonpath "$.result.resources[31].mimeType" == "application/schema+json"
jsonpath "$.result.resources[31].size" == 130
jsonpath "$.result.resources[31].annotations.priority" == 0.5
jsonpath "$.result.resources[32].uri" == "{{base}}/test/bare/07"
jsonpath "$.result.resources[32].name" == "/test/bare/07"
jsonpath "$.result.resources[32].mimeType" == "application/schema+json"
jsonpath "$.result.resources[32].size" == 130
jsonpath "$.result.resources[32].annotations.priority" == 0.5
jsonpath "$.result.resources[33].uri" == "{{base}}/test/bare/08"
jsonpath "$.result.resources[33].name" == "/test/bare/08"
jsonpath "$.result.resources[33].mimeType" == "application/schema+json"
jsonpath "$.result.resources[33].size" == 130
jsonpath "$.result.resources[33].annotations.priority" == 0.5
jsonpath "$.result.resources[34].uri" == "{{base}}/test/bare/09"
jsonpath "$.result.resources[34].name" == "/test/bare/09"
jsonpath "$.result.resources[34].mimeType" == "application/schema+json"
jsonpath "$.result.resources[34].size" == 130
jsonpath "$.result.resources[34].annotations.priority" == 0.5
jsonpath "$.result.resources[35].uri" == "{{base}}/test/bare/10"
jsonpath "$.result.resources[35].name" == "/test/bare/10"
jsonpath "$.result.resources[35].mimeType" == "application/schema+json"
jsonpath "$.result.resources[35].size" == 130
jsonpath "$.result.resources[35].annotations.priority" == 0.5
jsonpath "$.result.resources[36].uri" == "{{base}}/test/bare/11"
jsonpath "$.result.resources[36].name" == "/test/bare/11"
jsonpath "$.result.resources[36].mimeType" == "application/schema+json"
jsonpath "$.result.resources[36].size" == 130
jsonpath "$.result.resources[36].annotations.priority" == 0.5
jsonpath "$.result.resources[37].uri" == "{{base}}/test/bare/12"
jsonpath "$.result.resources[37].name" == "/test/bare/12"
jsonpath "$.result.resources[37].mimeType" == "application/schema+json"
jsonpath "$.result.resources[37].size" == 130
jsonpath "$.result.resources[37].annotations.priority" == 0.5
jsonpath "$.result.resources[38].uri" == "{{base}}/test/bare/13"
jsonpath "$.result.resources[38].name" == "/test/bare/13"
jsonpath "$.result.resources[38].mimeType" == "application/schema+json"
jsonpath "$.result.resources[38].size" == 130
jsonpath "$.result.resources[38].annotations.priority" == 0.5
jsonpath "$.result.resources[39].uri" == "{{base}}/test/bare/14"
jsonpath "$.result.resources[39].name" == "/test/bare/14"
jsonpath "$.result.resources[39].mimeType" == "application/schema+json"
jsonpath "$.result.resources[39].size" == 130
jsonpath "$.result.resources[39].annotations.priority" == 0.5
jsonpath "$.result.resources[40].uri" == "{{base}}/test/bare/15"
jsonpath "$.result.resources[40].name" == "/test/bare/15"
jsonpath "$.result.resources[40].mimeType" == "application/schema+json"
jsonpath "$.result.resources[40].size" == 130
jsonpath "$.result.resources[40].annotations.priority" == 0.5
jsonpath "$.result.resources[41].uri" == "{{base}}/test/bare/16"
jsonpath "$.result.resources[41].name" == "/test/bare/16"
jsonpath "$.result.resources[41].mimeType" == "application/schema+json"
jsonpath "$.result.resources[41].size" == 130
jsonpath "$.result.resources[41].annotations.priority" == 0.5
jsonpath "$.result.resources[42].uri" == "{{base}}/test/bare/17"
jsonpath "$.result.resources[42].name" == "/test/bare/17"
jsonpath "$.result.resources[42].mimeType" == "application/schema+json"
jsonpath "$.result.resources[42].size" == 130
jsonpath "$.result.resources[42].annotations.priority" == 0.5
jsonpath "$.result.resources[43].uri" == "{{base}}/test/bare/18"
jsonpath "$.result.resources[43].name" == "/test/bare/18"
jsonpath "$.result.resources[43].mimeType" == "application/schema+json"
jsonpath "$.result.resources[43].size" == 130
jsonpath "$.result.resources[43].annotations.priority" == 0.5
jsonpath "$.result.resources[44].uri" == "{{base}}/test/bare/19"
jsonpath "$.result.resources[44].name" == "/test/bare/19"
jsonpath "$.result.resources[44].mimeType" == "application/schema+json"
jsonpath "$.result.resources[44].size" == 130
jsonpath "$.result.resources[44].annotations.priority" == 0.5
jsonpath "$.result.resources[45].uri" == "{{base}}/test/bare/20"
jsonpath "$.result.resources[45].name" == "/test/bare/20"
jsonpath "$.result.resources[45].mimeType" == "application/schema+json"
jsonpath "$.result.resources[45].size" == 130
jsonpath "$.result.resources[45].annotations.priority" == 0.5
jsonpath "$.result.resources[46].uri" == "{{base}}/test/bare/21"
jsonpath "$.result.resources[46].name" == "/test/bare/21"
jsonpath "$.result.resources[46].mimeType" == "application/schema+json"
jsonpath "$.result.resources[46].size" == 130
jsonpath "$.result.resources[46].annotations.priority" == 0.5
jsonpath "$.result.resources[47].uri" == "{{base}}/test/bare/22"
jsonpath "$.result.resources[47].name" == "/test/bare/22"
jsonpath "$.result.resources[47].mimeType" == "application/schema+json"
jsonpath "$.result.resources[47].size" == 130
jsonpath "$.result.resources[47].annotations.priority" == 0.5
jsonpath "$.result.resources[48].uri" == "{{base}}/test/bare/23"
jsonpath "$.result.resources[48].name" == "/test/bare/23"
jsonpath "$.result.resources[48].mimeType" == "application/schema+json"
jsonpath "$.result.resources[48].size" == 130
jsonpath "$.result.resources[48].annotations.priority" == 0.5
jsonpath "$.result.resources[49].uri" == "{{base}}/test/bare/24"
jsonpath "$.result.resources[49].name" == "/test/bare/24"
jsonpath "$.result.resources[49].mimeType" == "application/schema+json"
jsonpath "$.result.resources[49].size" == 130
jsonpath "$.result.resources[49].annotations.priority" == 0.5
jsonpath "$.result.nextCursor" == "50"
# Added in 2025-11-25 (SEP-973)
# https://github.com/modelcontextprotocol/modelcontextprotocol/issues/973
jsonpath "$..icons" not exists

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
MCP-Protocol-Version: 2025-06-18
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "resources/read",
  "params": { "uri": "{{base}}/self/v1/schemas/api/error" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:8000
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-06-18
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
jsonpath "$.id" == 4
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/self/v1/schemas/api/error"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"
jsonpath "$.result.contents[0].text" isString

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
MCP-Protocol-Version: 2025-06-18
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 5, "method": "tools/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:8000
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-06-18
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
jsonpath "$.id" == 5
jsonpath "$.result.tools" count == 12
jsonpath "$.result.tools[0].name" == "list_directory"
jsonpath "$.result.tools[0].description" == "List the contents of a directory in the catalog"
jsonpath "$.result.tools[0].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/request"
jsonpath "$.result.tools[0].inputSchema.type" == "object"
jsonpath "$.result.tools[0].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/list-directory/response"
jsonpath "$.result.tools[0].outputSchema.type" == "object"
jsonpath "$.result.tools[0].annotations.title" == "List Directory"
jsonpath "$.result.tools[0].annotations.readOnlyHint" == true
jsonpath "$.result.tools[0].annotations.destructiveHint" == false
jsonpath "$.result.tools[0].annotations.idempotentHint" == true
jsonpath "$.result.tools[0].annotations.openWorldHint" == false
jsonpath "$.result.tools[1].name" == "get_schema_dependencies"
jsonpath "$.result.tools[1].description" == "List the schemas this schema directly or transitively references, the outgoing edges of the dependency graph"
jsonpath "$.result.tools[1].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/request"
jsonpath "$.result.tools[1].inputSchema.type" == "object"
jsonpath "$.result.tools[1].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependencies/response"
jsonpath "$.result.tools[1].outputSchema.type" == "object"
jsonpath "$.result.tools[1].annotations.title" == "Get Schema Dependencies"
jsonpath "$.result.tools[1].annotations.readOnlyHint" == true
jsonpath "$.result.tools[1].annotations.destructiveHint" == false
jsonpath "$.result.tools[1].annotations.idempotentHint" == true
jsonpath "$.result.tools[1].annotations.openWorldHint" == false
jsonpath "$.result.tools[2].name" == "get_schema_dependents"
jsonpath "$.result.tools[2].description" == "List the schemas that directly or transitively reference this schema, the incoming edges of the dependency graph"
jsonpath "$.result.tools[2].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/request"
jsonpath "$.result.tools[2].inputSchema.type" == "object"
jsonpath "$.result.tools[2].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-dependents/response"
jsonpath "$.result.tools[2].outputSchema.type" == "object"
jsonpath "$.result.tools[2].annotations.title" == "Get Schema Dependents"
jsonpath "$.result.tools[2].annotations.readOnlyHint" == true
jsonpath "$.result.tools[2].annotations.destructiveHint" == false
jsonpath "$.result.tools[2].annotations.idempotentHint" == true
jsonpath "$.result.tools[2].annotations.openWorldHint" == false
jsonpath "$.result.tools[3].name" == "get_schema_health"
jsonpath "$.result.tools[3].description" == "Return the lint health score (0 to 100) and any lint findings for a schema in the catalog"
jsonpath "$.result.tools[3].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/request"
jsonpath "$.result.tools[3].inputSchema.type" == "object"
jsonpath "$.result.tools[3].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-health/response"
jsonpath "$.result.tools[3].outputSchema.type" == "object"
jsonpath "$.result.tools[3].annotations.title" == "Get Schema Health"
jsonpath "$.result.tools[3].annotations.readOnlyHint" == true
jsonpath "$.result.tools[3].annotations.destructiveHint" == false
jsonpath "$.result.tools[3].annotations.idempotentHint" == true
jsonpath "$.result.tools[3].annotations.openWorldHint" == false
jsonpath "$.result.tools[4].name" == "get_schema_locations"
jsonpath "$.result.tools[4].description" == "Return every URI exposed by a schema, including subschemas and anchors, with their parent and base URI relationships. The response carries per-pointer metadata and grows with the schema's pointer count, so substantial payloads are expected for large schemas"
jsonpath "$.result.tools[4].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/request"
jsonpath "$.result.tools[4].inputSchema.type" == "object"
jsonpath "$.result.tools[4].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-locations/response"
jsonpath "$.result.tools[4].outputSchema.type" == "object"
jsonpath "$.result.tools[4].annotations.title" == "Get Schema Locations"
jsonpath "$.result.tools[4].annotations.readOnlyHint" == true
jsonpath "$.result.tools[4].annotations.destructiveHint" == false
jsonpath "$.result.tools[4].annotations.idempotentHint" == true
jsonpath "$.result.tools[4].annotations.openWorldHint" == false
jsonpath "$.result.tools[5].name" == "get_schema_positions"
jsonpath "$.result.tools[5].description" == "Return the source line and column position of every JSON Pointer inside a schema"
jsonpath "$.result.tools[5].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/request"
jsonpath "$.result.tools[5].inputSchema.type" == "object"
jsonpath "$.result.tools[5].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-positions/response"
jsonpath "$.result.tools[5].outputSchema.type" == "object"
jsonpath "$.result.tools[5].annotations.title" == "Get Schema Positions"
jsonpath "$.result.tools[5].annotations.readOnlyHint" == true
jsonpath "$.result.tools[5].annotations.destructiveHint" == false
jsonpath "$.result.tools[5].annotations.idempotentHint" == true
jsonpath "$.result.tools[5].annotations.openWorldHint" == false
jsonpath "$.result.tools[6].name" == "get_schema_stats"
jsonpath "$.result.tools[6].description" == "Return per-vocabulary keyword usage statistics for a schema in the catalog, identifying which JSON Schema keywords the schema relies on and how often each appears"
jsonpath "$.result.tools[6].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/request"
jsonpath "$.result.tools[6].inputSchema.type" == "object"
jsonpath "$.result.tools[6].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-stats/response"
jsonpath "$.result.tools[6].outputSchema.type" == "object"
jsonpath "$.result.tools[6].annotations.title" == "Get Schema Stats"
jsonpath "$.result.tools[6].annotations.readOnlyHint" == true
jsonpath "$.result.tools[6].annotations.destructiveHint" == false
jsonpath "$.result.tools[6].annotations.idempotentHint" == true
jsonpath "$.result.tools[6].annotations.openWorldHint" == false
jsonpath "$.result.tools[7].name" == "get_schema_metadata"
jsonpath "$.result.tools[7].description" == "Return navigation metadata for a schema in the catalog, including title, description, dialect, byte size, dependency count, and breadcrumb path"
jsonpath "$.result.tools[7].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/request"
jsonpath "$.result.tools[7].inputSchema.type" == "object"
jsonpath "$.result.tools[7].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/get-schema-metadata/response"
jsonpath "$.result.tools[7].outputSchema.type" == "object"
jsonpath "$.result.tools[7].annotations.title" == "Get Schema Metadata"
jsonpath "$.result.tools[7].annotations.readOnlyHint" == true
jsonpath "$.result.tools[7].annotations.destructiveHint" == false
jsonpath "$.result.tools[7].annotations.idempotentHint" == true
jsonpath "$.result.tools[7].annotations.openWorldHint" == false
jsonpath "$.result.tools[8].name" == "evaluate_schema"
jsonpath "$.result.tools[8].description" == "Validate a JSON instance against a schema and return whether it is valid plus any errors"
jsonpath "$.result.tools[8].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/request"
jsonpath "$.result.tools[8].inputSchema.type" == "object"
jsonpath "$.result.tools[8].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/evaluate-schema/response"
jsonpath "$.result.tools[8].outputSchema.type" == "object"
jsonpath "$.result.tools[8].annotations.title" == "Evaluate Schema"
jsonpath "$.result.tools[8].annotations.readOnlyHint" == true
jsonpath "$.result.tools[8].annotations.destructiveHint" == false
jsonpath "$.result.tools[8].annotations.idempotentHint" == true
jsonpath "$.result.tools[8].annotations.openWorldHint" == false
jsonpath "$.result.tools[9].name" == "instance_to_rdf"
jsonpath "$.result.tools[9].description" == "Validate a JSON instance against a schema in the catalog and promote it to JSON-LD using the x-jsonld-* annotations of the schema"
jsonpath "$.result.tools[9].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/request"
jsonpath "$.result.tools[9].inputSchema.type" == "object"
jsonpath "$.result.tools[9].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/instance-to-rdf/response"
jsonpath "$.result.tools[9].outputSchema.type" == "object"
jsonpath "$.result.tools[9].annotations.title" == "Instance To Rdf"
jsonpath "$.result.tools[9].annotations.readOnlyHint" == true
jsonpath "$.result.tools[9].annotations.destructiveHint" == false
jsonpath "$.result.tools[9].annotations.idempotentHint" == true
jsonpath "$.result.tools[9].annotations.openWorldHint" == false
jsonpath "$.result.tools[10].name" == "trace_schema_evaluation"
jsonpath "$.result.tools[10].description" == "Validate a JSON instance against a schema and return a step-by-step trace of the evaluation. The trace can be substantial, so prefer non-tracing evaluation when only a valid or invalid verdict is needed and use this when per-step detail is required"
jsonpath "$.result.tools[10].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"
jsonpath "$.result.tools[10].inputSchema.type" == "object"
jsonpath "$.result.tools[10].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"
jsonpath "$.result.tools[10].outputSchema.type" == "object"
jsonpath "$.result.tools[10].annotations.title" == "Trace Schema Evaluation"
jsonpath "$.result.tools[10].annotations.readOnlyHint" == true
jsonpath "$.result.tools[10].annotations.destructiveHint" == false
jsonpath "$.result.tools[10].annotations.idempotentHint" == true
jsonpath "$.result.tools[10].annotations.openWorldHint" == false
jsonpath "$.result.tools[11].name" == "search_schemas"
jsonpath "$.result.tools[11].description" == "Search for schemas by query term"
jsonpath "$.result.tools[11].inputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/request"
jsonpath "$.result.tools[11].inputSchema.type" == "object"
jsonpath "$.result.tools[11].outputSchema['$ref']" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/response"
jsonpath "$.result.tools[11].outputSchema.type" == "object"
jsonpath "$.result.tools[11].annotations.title" == "Search Schemas"
jsonpath "$.result.tools[11].annotations.readOnlyHint" == true
jsonpath "$.result.tools[11].annotations.destructiveHint" == false
jsonpath "$.result.tools[11].annotations.idempotentHint" == true
jsonpath "$.result.tools[11].annotations.openWorldHint" == false
# Added in 2025-11-25 (SEP-973)
# https://github.com/modelcontextprotocol/modelcontextprotocol/issues/973
jsonpath "$..icons" not exists
# Added in 2025-11-25 (SEP-1686)
# https://github.com/modelcontextprotocol/modelcontextprotocol/issues/1686
jsonpath "$..execution" not exists

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
MCP-Protocol-Version: 2025-06-18
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 6,
  "method": "tools/call",
  "params": {
    "name": "list_directory",
    "arguments": {}
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:8000
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-06-18
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
jsonpath "$.id" == 6
jsonpath "$.result.isError" == false
jsonpath "$.result.content[0].type" == "text"
jsonpath "$.result.structuredContent.path" == "/"
jsonpath "$.result.structuredContent.url" == "{{base}}"
jsonpath "$.result.structuredContent.entries" count >= 1
jsonpath "$.result.structuredContent.private" == false

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
MCP-Protocol-Version: 2025-06-18
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 60,
  "method": "tools/call",
  "params": {
    "name": "list_directory"
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:8000
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-06-18
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
jsonpath "$.id" == 60
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.content[0].type" == "text"
jsonpath "$.result.structuredContent.path" == "/"
variable "text" jsonpath "$.path" == "/"
jsonpath "$.result.structuredContent.url" == "{{base}}"
variable "text" jsonpath "$.url" == "{{base}}"
jsonpath "$.result.structuredContent.breadcrumb" count == 0
variable "text" jsonpath "$.breadcrumb" count == 0
jsonpath "$.result.structuredContent.schemas" == 142
variable "text" jsonpath "$.schemas" == 142
jsonpath "$.result.structuredContent.entries" count == 4
jsonpath "$.result.structuredContent.private" == false
variable "text" jsonpath "$.entries" count == 4
variable "text" jsonpath "$.private" == false
jsonpath "$.result.structuredContent.entries[0].name" == "no-blaze"
jsonpath "$.result.structuredContent.entries[0].private" == false
variable "text" jsonpath "$.entries[0].name" == "no-blaze"
variable "text" jsonpath "$.entries[0].private" == false
jsonpath "$.result.structuredContent.entries[0].type" == "directory"
variable "text" jsonpath "$.entries[0].type" == "directory"
jsonpath "$.result.structuredContent.entries[0].health" == 0
variable "text" jsonpath "$.entries[0].health" == 0
jsonpath "$.result.structuredContent.entries[0].schemas" == 2
variable "text" jsonpath "$.entries[0].schemas" == 2
jsonpath "$.result.structuredContent.entries[0].path" == "/no-blaze/"
variable "text" jsonpath "$.entries[0].path" == "/no-blaze/"
jsonpath "$.result.structuredContent.entries[1].name" == "self"
jsonpath "$.result.structuredContent.entries[1].private" == false
variable "text" jsonpath "$.entries[1].name" == "self"
variable "text" jsonpath "$.entries[1].private" == false
jsonpath "$.result.structuredContent.entries[1].title" == "Self"
variable "text" jsonpath "$.entries[1].title" == "Self"
jsonpath "$.result.structuredContent.entries[1].description" == "The schemas that define the current version of this instance"
variable "text" jsonpath "$.entries[1].description" == "The schemas that define the current version of this instance"
jsonpath "$.result.structuredContent.entries[1].type" == "directory"
variable "text" jsonpath "$.entries[1].type" == "directory"
jsonpath "$.result.structuredContent.entries[1].health" == 99
variable "text" jsonpath "$.entries[1].health" == 99
jsonpath "$.result.structuredContent.entries[1].schemas" == 65
variable "text" jsonpath "$.entries[1].schemas" == 65
jsonpath "$.result.structuredContent.entries[1].path" == "/self/"
variable "text" jsonpath "$.entries[1].path" == "/self/"
jsonpath "$.result.structuredContent.entries[2].name" == "test"
jsonpath "$.result.structuredContent.entries[2].private" == false
variable "text" jsonpath "$.entries[2].name" == "test"
variable "text" jsonpath "$.entries[2].private" == false
jsonpath "$.result.structuredContent.entries[2].type" == "directory"
variable "text" jsonpath "$.entries[2].type" == "directory"
jsonpath "$.result.structuredContent.entries[2].health" == 19
variable "text" jsonpath "$.entries[2].health" == 19
jsonpath "$.result.structuredContent.entries[2].schemas" == 73
variable "text" jsonpath "$.entries[2].schemas" == 73
jsonpath "$.result.structuredContent.entries[2].path" == "/test/"
variable "text" jsonpath "$.entries[2].path" == "/test/"
jsonpath "$.result.structuredContent.entries[3].name" == "twins"
jsonpath "$.result.structuredContent.entries[3].private" == false
variable "text" jsonpath "$.entries[3].name" == "twins"
variable "text" jsonpath "$.entries[3].private" == false
jsonpath "$.result.structuredContent.entries[3].title" == "Twins"
variable "text" jsonpath "$.entries[3].title" == "Twins"
jsonpath "$.result.structuredContent.entries[3].description" == "Schemas whose base name collides with a sibling directory"
variable "text" jsonpath "$.entries[3].description" == "Schemas whose base name collides with a sibling directory"
jsonpath "$.result.structuredContent.entries[3].type" == "directory"
variable "text" jsonpath "$.entries[3].type" == "directory"
jsonpath "$.result.structuredContent.entries[3].health" == 100
variable "text" jsonpath "$.entries[3].health" == 100
jsonpath "$.result.structuredContent.entries[3].schemas" == 2
variable "text" jsonpath "$.entries[3].schemas" == 2
jsonpath "$.result.structuredContent.entries[3].path" == "/twins/"
variable "text" jsonpath "$.entries[3].path" == "/twins/"

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
MCP-Protocol-Version: 2025-06-18
Content-Type: application/json
```
[ { "jsonrpc": "2.0", "id": 1, "method": "ping" } ]
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: http://localhost:8000
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/mcp/response>; rel="describedby"
MCP-Protocol-Version: 2025-06-18
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
jsonpath "$.id" == null
jsonpath "$.error.code" == -32600
jsonpath "$.error.message" == "Invalid Request"
jsonpath "$.error.data" not exists

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
