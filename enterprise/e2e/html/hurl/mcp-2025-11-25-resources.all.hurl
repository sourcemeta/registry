POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 10,
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
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 10
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
  "id": 11,
  "method": "resources/list",
  "params": {
    "cursor": "50"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 11
jsonpath "$.result.resources" count == 50
jsonpath "$.result.resources[0].uri" == "{{base}}/test/bare/25"
jsonpath "$.result.resources[0].name" == "/test/bare/25"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 130
jsonpath "$.result.resources[0].annotations.priority" == 0.5
jsonpath "$.result.resources[1].uri" == "{{base}}/test/bare/26"
jsonpath "$.result.resources[1].name" == "/test/bare/26"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 130
jsonpath "$.result.resources[1].annotations.priority" == 0.5
jsonpath "$.result.resources[2].uri" == "{{base}}/test/bare/27"
jsonpath "$.result.resources[2].name" == "/test/bare/27"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 130
jsonpath "$.result.resources[2].annotations.priority" == 0.5
jsonpath "$.result.resources[3].uri" == "{{base}}/test/bare/28"
jsonpath "$.result.resources[3].name" == "/test/bare/28"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 130
jsonpath "$.result.resources[3].annotations.priority" == 0.5
jsonpath "$.result.resources[4].uri" == "{{base}}/test/bare/29"
jsonpath "$.result.resources[4].name" == "/test/bare/29"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 130
jsonpath "$.result.resources[4].annotations.priority" == 0.5
jsonpath "$.result.resources[5].uri" == "{{base}}/test/bare/30"
jsonpath "$.result.resources[5].name" == "/test/bare/30"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 130
jsonpath "$.result.resources[5].annotations.priority" == 0.5
jsonpath "$.result.resources[6].uri" == "{{base}}/test/bare/31"
jsonpath "$.result.resources[6].name" == "/test/bare/31"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 130
jsonpath "$.result.resources[6].annotations.priority" == 0.5
jsonpath "$.result.resources[7].uri" == "{{base}}/test/bare/32"
jsonpath "$.result.resources[7].name" == "/test/bare/32"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 130
jsonpath "$.result.resources[7].annotations.priority" == 0.5
jsonpath "$.result.resources[8].uri" == "{{base}}/test/bare/33"
jsonpath "$.result.resources[8].name" == "/test/bare/33"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 130
jsonpath "$.result.resources[8].annotations.priority" == 0.5
jsonpath "$.result.resources[9].uri" == "{{base}}/test/bare/34"
jsonpath "$.result.resources[9].name" == "/test/bare/34"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 130
jsonpath "$.result.resources[9].annotations.priority" == 0.5
jsonpath "$.result.resources[10].uri" == "{{base}}/test/bare/35"
jsonpath "$.result.resources[10].name" == "/test/bare/35"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 130
jsonpath "$.result.resources[10].annotations.priority" == 0.5
jsonpath "$.result.resources[11].uri" == "{{base}}/test/bare/36"
jsonpath "$.result.resources[11].name" == "/test/bare/36"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 130
jsonpath "$.result.resources[11].annotations.priority" == 0.5
jsonpath "$.result.resources[12].uri" == "{{base}}/test/bare/37"
jsonpath "$.result.resources[12].name" == "/test/bare/37"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 130
jsonpath "$.result.resources[12].annotations.priority" == 0.5
jsonpath "$.result.resources[13].uri" == "{{base}}/test/bare/38"
jsonpath "$.result.resources[13].name" == "/test/bare/38"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 130
jsonpath "$.result.resources[13].annotations.priority" == 0.5
jsonpath "$.result.resources[14].uri" == "{{base}}/test/bare/39"
jsonpath "$.result.resources[14].name" == "/test/bare/39"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 130
jsonpath "$.result.resources[14].annotations.priority" == 0.5
jsonpath "$.result.resources[15].uri" == "{{base}}/test/bare/40"
jsonpath "$.result.resources[15].name" == "/test/bare/40"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 130
jsonpath "$.result.resources[15].annotations.priority" == 0.5
jsonpath "$.result.resources[16].uri" == "{{base}}/test/bare/41"
jsonpath "$.result.resources[16].name" == "/test/bare/41"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 130
jsonpath "$.result.resources[16].annotations.priority" == 0.5
jsonpath "$.result.resources[17].uri" == "{{base}}/test/bare/42"
jsonpath "$.result.resources[17].name" == "/test/bare/42"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 130
jsonpath "$.result.resources[17].annotations.priority" == 0.5
jsonpath "$.result.resources[18].uri" == "{{base}}/test/bare/43"
jsonpath "$.result.resources[18].name" == "/test/bare/43"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 130
jsonpath "$.result.resources[18].annotations.priority" == 0.5
jsonpath "$.result.resources[19].uri" == "{{base}}/test/bare/44"
jsonpath "$.result.resources[19].name" == "/test/bare/44"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 130
jsonpath "$.result.resources[19].annotations.priority" == 0.5
jsonpath "$.result.resources[20].uri" == "{{base}}/test/bare/45"
jsonpath "$.result.resources[20].name" == "/test/bare/45"
jsonpath "$.result.resources[20].mimeType" == "application/schema+json"
jsonpath "$.result.resources[20].size" == 130
jsonpath "$.result.resources[20].annotations.priority" == 0.5
jsonpath "$.result.resources[21].uri" == "{{base}}/test/bare/46"
jsonpath "$.result.resources[21].name" == "/test/bare/46"
jsonpath "$.result.resources[21].mimeType" == "application/schema+json"
jsonpath "$.result.resources[21].size" == 130
jsonpath "$.result.resources[21].annotations.priority" == 0.5
jsonpath "$.result.resources[22].uri" == "{{base}}/test/bare/47"
jsonpath "$.result.resources[22].name" == "/test/bare/47"
jsonpath "$.result.resources[22].mimeType" == "application/schema+json"
jsonpath "$.result.resources[22].size" == 130
jsonpath "$.result.resources[22].annotations.priority" == 0.5
jsonpath "$.result.resources[23].uri" == "{{base}}/test/bare/48"
jsonpath "$.result.resources[23].name" == "/test/bare/48"
jsonpath "$.result.resources[23].mimeType" == "application/schema+json"
jsonpath "$.result.resources[23].size" == 130
jsonpath "$.result.resources[23].annotations.priority" == 0.5
jsonpath "$.result.resources[24].uri" == "{{base}}/test/bare/49"
jsonpath "$.result.resources[24].name" == "/test/bare/49"
jsonpath "$.result.resources[24].mimeType" == "application/schema+json"
jsonpath "$.result.resources[24].size" == 130
jsonpath "$.result.resources[24].annotations.priority" == 0.5
jsonpath "$.result.resources[25].uri" == "{{base}}/test/bare/50"
jsonpath "$.result.resources[25].name" == "/test/bare/50"
jsonpath "$.result.resources[25].mimeType" == "application/schema+json"
jsonpath "$.result.resources[25].size" == 130
jsonpath "$.result.resources[25].annotations.priority" == 0.5
jsonpath "$.result.resources[26].uri" == "{{base}}/test/draft3/string"
jsonpath "$.result.resources[26].name" == "/test/draft3/string"
jsonpath "$.result.resources[26].mimeType" == "application/schema+json"
jsonpath "$.result.resources[26].size" == 130
jsonpath "$.result.resources[26].annotations.priority" == 0.5
jsonpath "$.result.resources[27].uri" == "{{base}}/self/v1/schemas/api/auth/login/response"
jsonpath "$.result.resources[27].name" == "Sourcemeta One Login API Response"
jsonpath "$.result.resources[27].description" == "The ways of signing in to this instance, which a custom interface reads to offer them"
jsonpath "$.result.resources[27].mimeType" == "application/schema+json"
jsonpath "$.result.resources[27].size" == 1735
jsonpath "$.result.resources[27].annotations.priority" == 0
jsonpath "$.result.resources[28].uri" == "{{base}}/self/v1/schemas/api/error"
jsonpath "$.result.resources[28].name" == "Sourcemeta One API Error"
jsonpath "$.result.resources[28].description" == "The error response format returned by the Sourcemeta One API endpoints"
jsonpath "$.result.resources[28].mimeType" == "application/schema+json"
jsonpath "$.result.resources[28].size" == 10190
jsonpath "$.result.resources[28].annotations.priority" == 0
jsonpath "$.result.resources[29].uri" == "{{base}}/self/v1/schemas/api/list/response"
jsonpath "$.result.resources[29].name" == "Sourcemeta One List API Response"
jsonpath "$.result.resources[29].description" == "The response format for the directory listing API endpoint"
jsonpath "$.result.resources[29].mimeType" == "application/schema+json"
jsonpath "$.result.resources[29].size" == 3878
jsonpath "$.result.resources[29].annotations.priority" == 0
jsonpath "$.result.resources[30].uri" == "{{base}}/self/v1/schemas/api/schemas/dependencies/response"
jsonpath "$.result.resources[30].name" == "Sourcemeta One Schema Dependencies API Response"
jsonpath "$.result.resources[30].description" == "The response format for the schema dependencies API endpoint"
jsonpath "$.result.resources[30].mimeType" == "application/schema+json"
jsonpath "$.result.resources[30].size" == 992
jsonpath "$.result.resources[30].annotations.priority" == 0
jsonpath "$.result.resources[31].uri" == "{{base}}/self/v1/schemas/api/schemas/dependents/response"
jsonpath "$.result.resources[31].name" == "Sourcemeta One Schema Dependents API Response"
jsonpath "$.result.resources[31].description" == "The response format for the schema dependents API endpoint"
jsonpath "$.result.resources[31].mimeType" == "application/schema+json"
jsonpath "$.result.resources[31].size" == 986
jsonpath "$.result.resources[31].annotations.priority" == 0
jsonpath "$.result.resources[32].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/request"
jsonpath "$.result.resources[32].name" == "Sourcemeta One Schema Evaluate API Request"
jsonpath "$.result.resources[32].description" == "The JSON instance to validate against a schema in the catalog"
jsonpath "$.result.resources[32].mimeType" == "application/schema+json"
jsonpath "$.result.resources[32].size" == 417
jsonpath "$.result.resources[32].annotations.priority" == 0
jsonpath "$.result.resources[33].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/response"
jsonpath "$.result.resources[33].name" == "Sourcemeta One Schema Evaluate API Response"
jsonpath "$.result.resources[33].description" == "The response format for the schema evaluation API endpoint"
jsonpath "$.result.resources[33].mimeType" == "application/schema+json"
jsonpath "$.result.resources[33].size" == 2138
jsonpath "$.result.resources[33].annotations.priority" == 0
jsonpath "$.result.resources[34].uri" == "{{base}}/self/v1/schemas/api/schemas/health/response"
jsonpath "$.result.resources[34].name" == "Sourcemeta One Schema Health API Response"
jsonpath "$.result.resources[34].description" == "The response format for the schema health API endpoint"
jsonpath "$.result.resources[34].mimeType" == "application/schema+json"
jsonpath "$.result.resources[34].size" == 1584
jsonpath "$.result.resources[34].annotations.priority" == 0
jsonpath "$.result.resources[35].uri" == "{{base}}/self/v1/schemas/api/schemas/locations/response"
jsonpath "$.result.resources[35].name" == "Sourcemeta One Schema Locations API Response"
jsonpath "$.result.resources[35].description" == "The response format for the schema frame locations API endpoint"
jsonpath "$.result.resources[35].mimeType" == "application/schema+json"
jsonpath "$.result.resources[35].size" == 2391
jsonpath "$.result.resources[35].annotations.priority" == 0
jsonpath "$.result.resources[36].uri" == "{{base}}/self/v1/schemas/api/schemas/metadata/response"
jsonpath "$.result.resources[36].name" == "Sourcemeta One Schema Metadata API Response"
jsonpath "$.result.resources[36].description" == "The response format for the schema metadata API endpoint"
jsonpath "$.result.resources[36].mimeType" == "application/schema+json"
jsonpath "$.result.resources[36].size" == 2943
jsonpath "$.result.resources[36].annotations.priority" == 0
jsonpath "$.result.resources[37].uri" == "{{base}}/self/v1/schemas/api/schemas/output-error"
jsonpath "$.result.resources[37].name" == "Sourcemeta One Schema Output Error"
jsonpath "$.result.resources[37].description" == "A single entry of the standard JSON Schema output format that describes why an instance does not conform to a schema"
jsonpath "$.result.resources[37].mimeType" == "application/schema+json"
jsonpath "$.result.resources[37].size" == 1143
jsonpath "$.result.resources[37].annotations.priority" == 0
jsonpath "$.result.resources[38].uri" == "{{base}}/self/v1/schemas/api/schemas/position"
jsonpath "$.result.resources[38].name" == "Sourcemeta One Schema Position"
jsonpath "$.result.resources[38].description" == "Represents a position in a JSON document as line start, column start, line end, and column end"
jsonpath "$.result.resources[38].mimeType" == "application/schema+json"
jsonpath "$.result.resources[38].size" == 446
jsonpath "$.result.resources[38].annotations.priority" == 0
jsonpath "$.result.resources[39].uri" == "{{base}}/self/v1/schemas/api/schemas/positions/response"
jsonpath "$.result.resources[39].name" == "Sourcemeta One Schema Positions API Response"
jsonpath "$.result.resources[39].description" == "The response format for the schema positions API endpoint"
jsonpath "$.result.resources[39].mimeType" == "application/schema+json"
jsonpath "$.result.resources[39].size" == 435
jsonpath "$.result.resources[39].annotations.priority" == 0
jsonpath "$.result.resources[40].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/request"
jsonpath "$.result.resources[40].name" == "Sourcemeta One Schema RDF API Request"
jsonpath "$.result.resources[40].description" == "The JSON instance to promote to JSON-LD against a schema in the catalog, along with the desired output form"
jsonpath "$.result.resources[40].mimeType" == "application/schema+json"
jsonpath "$.result.resources[40].size" == 1422
jsonpath "$.result.resources[40].annotations.priority" == 0
jsonpath "$.result.resources[41].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/response"
jsonpath "$.result.resources[41].name" == "Sourcemeta One Schema RDF API Response"
jsonpath "$.result.resources[41].description" == "The instance promoted to JSON-LD, in expanded, flattened, or compacted form"
jsonpath "$.result.resources[41].mimeType" == "application/schema+json"
jsonpath "$.result.resources[41].size" == 799
jsonpath "$.result.resources[41].annotations.priority" == 0
jsonpath "$.result.resources[42].uri" == "{{base}}/self/v1/schemas/api/schemas/search/response"
jsonpath "$.result.resources[42].name" == "Sourcemeta One Schema Search API Response"
jsonpath "$.result.resources[42].description" == "The response format for the schema search API endpoint"
jsonpath "$.result.resources[42].mimeType" == "application/schema+json"
jsonpath "$.result.resources[42].size" == 1341
jsonpath "$.result.resources[42].annotations.priority" == 0
jsonpath "$.result.resources[43].uri" == "{{base}}/self/v1/schemas/api/schemas/stats/response"
jsonpath "$.result.resources[43].name" == "Sourcemeta One Schema Stats API Response"
jsonpath "$.result.resources[43].description" == "The response format for the schema statistics API endpoint"
jsonpath "$.result.resources[43].mimeType" == "application/schema+json"
jsonpath "$.result.resources[43].size" == 2345
jsonpath "$.result.resources[43].annotations.priority" == 0
jsonpath "$.result.resources[44].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/inline/request"
jsonpath "$.result.resources[44].name" == "Sourcemeta One Schema Inline Trace API Request"
jsonpath "$.result.resources[44].description" == "A JSON instance and the schema to trace its evaluation against"
jsonpath "$.result.resources[44].mimeType" == "application/schema+json"
jsonpath "$.result.resources[44].size" == 852
jsonpath "$.result.resources[44].annotations.priority" == 0
jsonpath "$.result.resources[45].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/request"
jsonpath "$.result.resources[45].name" == "Sourcemeta One Schema Trace API Request"
jsonpath "$.result.resources[45].description" == "The JSON instance to trace evaluation against a schema in the catalog"
jsonpath "$.result.resources[45].mimeType" == "application/schema+json"
jsonpath "$.result.resources[45].size" == 419
jsonpath "$.result.resources[45].annotations.priority" == 0
jsonpath "$.result.resources[46].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/response"
jsonpath "$.result.resources[46].name" == "Sourcemeta One Schema Trace API Response"
jsonpath "$.result.resources[46].description" == "The response format for the schema trace API endpoint"
jsonpath "$.result.resources[46].mimeType" == "application/schema+json"
jsonpath "$.result.resources[46].size" == 2290
jsonpath "$.result.resources[46].annotations.priority" == 0
jsonpath "$.result.resources[47].uri" == "{{base}}/self/v1/schemas/mcp/error"
jsonpath "$.result.resources[47].name" == "Sourcemeta One MCP Error Response"
jsonpath "$.result.resources[47].description" == "The error response Sourcemeta One returns when an MCP request fails"
jsonpath "$.result.resources[47].mimeType" == "application/schema+json"
jsonpath "$.result.resources[47].size" == 5860
jsonpath "$.result.resources[47].annotations.priority" == 0
jsonpath "$.result.resources[48].uri" == "{{base}}/self/v1/schemas/mcp/initialize/request"
jsonpath "$.result.resources[48].name" == "Sourcemeta One MCP Initialize Request"
jsonpath "$.result.resources[48].description" == "Connection handshake from a client"
jsonpath "$.result.resources[48].mimeType" == "application/schema+json"
jsonpath "$.result.resources[48].size" == 4617
jsonpath "$.result.resources[48].annotations.priority" == 0
jsonpath "$.result.resources[49].uri" == "{{base}}/self/v1/schemas/mcp/initialize/response"
jsonpath "$.result.resources[49].name" == "Sourcemeta One MCP Initialize Response"
jsonpath "$.result.resources[49].description" == "Sourcemeta One's response to a client's initialization"
jsonpath "$.result.resources[49].mimeType" == "application/schema+json"
jsonpath "$.result.resources[49].size" == 2524
jsonpath "$.result.resources[49].annotations.priority" == 0
jsonpath "$.result.nextCursor" == "100"

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
  "id": 12,
  "method": "resources/list",
  "params": {
    "cursor": "100"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 12
jsonpath "$.result.resources" count == 41
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
jsonpath "$.result.resources[33].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/request"
jsonpath "$.result.resources[33].name" == "Sourcemeta One MCP Tools Call Request"
jsonpath "$.result.resources[33].description" == "Request from a client to invoke an MCP tool by name"
jsonpath "$.result.resources[33].mimeType" == "application/schema+json"
jsonpath "$.result.resources[33].size" == 1161
jsonpath "$.result.resources[33].annotations.priority" == 0
jsonpath "$.result.resources[34].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/response"
jsonpath "$.result.resources[34].name" == "Sourcemeta One MCP Tools Call Response"
jsonpath "$.result.resources[34].description" == "Sourcemeta One's response to a tool invocation"
jsonpath "$.result.resources[34].mimeType" == "application/schema+json"
jsonpath "$.result.resources[34].size" == 4668
jsonpath "$.result.resources[34].annotations.priority" == 0
jsonpath "$.result.resources[35].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/request"
jsonpath "$.result.resources[35].name" == "Sourcemeta One Schema Search RPC Input"
jsonpath "$.result.resources[35].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[35].mimeType" == "application/schema+json"
jsonpath "$.result.resources[35].size" == 2155
jsonpath "$.result.resources[35].annotations.priority" == 0
jsonpath "$.result.resources[36].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/search-schemas/response"
jsonpath "$.result.resources[36].name" == "Sourcemeta One Schema Search RPC Output"
jsonpath "$.result.resources[36].description" == "Search for schemas in the catalog by query term"
jsonpath "$.result.resources[36].mimeType" == "application/schema+json"
jsonpath "$.result.resources[36].size" == 777
jsonpath "$.result.resources[36].annotations.priority" == 0
jsonpath "$.result.resources[37].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/request"
jsonpath "$.result.resources[37].name" == "Sourcemeta One Schema Trace RPC Input"
jsonpath "$.result.resources[37].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[37].mimeType" == "application/schema+json"
jsonpath "$.result.resources[37].size" == 1735
jsonpath "$.result.resources[37].annotations.priority" == 0
jsonpath "$.result.resources[38].uri" == "{{base}}/self/v1/schemas/mcp/tools/call/trace-schema-evaluation/response"
jsonpath "$.result.resources[38].name" == "Sourcemeta One Schema Trace RPC Output"
jsonpath "$.result.resources[38].description" == "Trace step-by-step evaluation of a JSON instance against a schema in the catalog, exposing each step, rule application, and decision point"
jsonpath "$.result.resources[38].mimeType" == "application/schema+json"
jsonpath "$.result.resources[38].size" == 497
jsonpath "$.result.resources[38].annotations.priority" == 0
jsonpath "$.result.resources[39].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/request"
jsonpath "$.result.resources[39].name" == "Sourcemeta One MCP Tools List Request"
jsonpath "$.result.resources[39].description" == "Request from a client to list MCP tools"
jsonpath "$.result.resources[39].mimeType" == "application/schema+json"
jsonpath "$.result.resources[39].size" == 853
jsonpath "$.result.resources[39].annotations.priority" == 0
jsonpath "$.result.resources[40].uri" == "{{base}}/self/v1/schemas/mcp/tools/list/response"
jsonpath "$.result.resources[40].name" == "Sourcemeta One MCP Tools List Response"
jsonpath "$.result.resources[40].description" == "Sourcemeta One's list of MCP tools"
jsonpath "$.result.resources[40].mimeType" == "application/schema+json"
jsonpath "$.result.resources[40].size" == 4495
jsonpath "$.result.resources[40].annotations.priority" == 0
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
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 40,
  "method": "resources/list",
  "params": {
    "cursor": "abc"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 40
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid resource list cursor"
jsonpath "$.error.data" == "Use the `nextCursor` returned by a prior resources/list response, or omit it to start from the beginning"

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
  "id": 41,
  "method": "resources/list",
  "params": {
    "cursor": "-1"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 41
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid resource list cursor"
jsonpath "$.error.data" == "Use the `nextCursor` returned by a prior resources/list response, or omit it to start from the beginning"

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

# resources/list rejects parseable cursors that do not match any page
# boundary so callers can distinguish "end of pages" from a stale cursor

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 42,
  "method": "resources/list",
  "params": {
    "cursor": "999998"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 42
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid resource list cursor"
jsonpath "$.error.data" == "Use the `nextCursor` returned by a prior resources/list response, or omit it to start from the beginning"

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

# Leading zeros are tolerated and the cursor is normalized to its
# canonical decimal form, so "050" hits the same page as "50"

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 44,
  "method": "resources/list",
  "params": {
    "cursor": "050"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 44
jsonpath "$.result.resources" count == 50
jsonpath "$.result.resources[0].uri" == "{{base}}/test/bare/25"
jsonpath "$.result.resources[0].name" == "/test/bare/25"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 130
jsonpath "$.result.resources[0].annotations.priority" == 0.5
jsonpath "$.result.resources[1].uri" == "{{base}}/test/bare/26"
jsonpath "$.result.resources[1].name" == "/test/bare/26"
jsonpath "$.result.resources[1].mimeType" == "application/schema+json"
jsonpath "$.result.resources[1].size" == 130
jsonpath "$.result.resources[1].annotations.priority" == 0.5
jsonpath "$.result.resources[2].uri" == "{{base}}/test/bare/27"
jsonpath "$.result.resources[2].name" == "/test/bare/27"
jsonpath "$.result.resources[2].mimeType" == "application/schema+json"
jsonpath "$.result.resources[2].size" == 130
jsonpath "$.result.resources[2].annotations.priority" == 0.5
jsonpath "$.result.resources[3].uri" == "{{base}}/test/bare/28"
jsonpath "$.result.resources[3].name" == "/test/bare/28"
jsonpath "$.result.resources[3].mimeType" == "application/schema+json"
jsonpath "$.result.resources[3].size" == 130
jsonpath "$.result.resources[3].annotations.priority" == 0.5
jsonpath "$.result.resources[4].uri" == "{{base}}/test/bare/29"
jsonpath "$.result.resources[4].name" == "/test/bare/29"
jsonpath "$.result.resources[4].mimeType" == "application/schema+json"
jsonpath "$.result.resources[4].size" == 130
jsonpath "$.result.resources[4].annotations.priority" == 0.5
jsonpath "$.result.resources[5].uri" == "{{base}}/test/bare/30"
jsonpath "$.result.resources[5].name" == "/test/bare/30"
jsonpath "$.result.resources[5].mimeType" == "application/schema+json"
jsonpath "$.result.resources[5].size" == 130
jsonpath "$.result.resources[5].annotations.priority" == 0.5
jsonpath "$.result.resources[6].uri" == "{{base}}/test/bare/31"
jsonpath "$.result.resources[6].name" == "/test/bare/31"
jsonpath "$.result.resources[6].mimeType" == "application/schema+json"
jsonpath "$.result.resources[6].size" == 130
jsonpath "$.result.resources[6].annotations.priority" == 0.5
jsonpath "$.result.resources[7].uri" == "{{base}}/test/bare/32"
jsonpath "$.result.resources[7].name" == "/test/bare/32"
jsonpath "$.result.resources[7].mimeType" == "application/schema+json"
jsonpath "$.result.resources[7].size" == 130
jsonpath "$.result.resources[7].annotations.priority" == 0.5
jsonpath "$.result.resources[8].uri" == "{{base}}/test/bare/33"
jsonpath "$.result.resources[8].name" == "/test/bare/33"
jsonpath "$.result.resources[8].mimeType" == "application/schema+json"
jsonpath "$.result.resources[8].size" == 130
jsonpath "$.result.resources[8].annotations.priority" == 0.5
jsonpath "$.result.resources[9].uri" == "{{base}}/test/bare/34"
jsonpath "$.result.resources[9].name" == "/test/bare/34"
jsonpath "$.result.resources[9].mimeType" == "application/schema+json"
jsonpath "$.result.resources[9].size" == 130
jsonpath "$.result.resources[9].annotations.priority" == 0.5
jsonpath "$.result.resources[10].uri" == "{{base}}/test/bare/35"
jsonpath "$.result.resources[10].name" == "/test/bare/35"
jsonpath "$.result.resources[10].mimeType" == "application/schema+json"
jsonpath "$.result.resources[10].size" == 130
jsonpath "$.result.resources[10].annotations.priority" == 0.5
jsonpath "$.result.resources[11].uri" == "{{base}}/test/bare/36"
jsonpath "$.result.resources[11].name" == "/test/bare/36"
jsonpath "$.result.resources[11].mimeType" == "application/schema+json"
jsonpath "$.result.resources[11].size" == 130
jsonpath "$.result.resources[11].annotations.priority" == 0.5
jsonpath "$.result.resources[12].uri" == "{{base}}/test/bare/37"
jsonpath "$.result.resources[12].name" == "/test/bare/37"
jsonpath "$.result.resources[12].mimeType" == "application/schema+json"
jsonpath "$.result.resources[12].size" == 130
jsonpath "$.result.resources[12].annotations.priority" == 0.5
jsonpath "$.result.resources[13].uri" == "{{base}}/test/bare/38"
jsonpath "$.result.resources[13].name" == "/test/bare/38"
jsonpath "$.result.resources[13].mimeType" == "application/schema+json"
jsonpath "$.result.resources[13].size" == 130
jsonpath "$.result.resources[13].annotations.priority" == 0.5
jsonpath "$.result.resources[14].uri" == "{{base}}/test/bare/39"
jsonpath "$.result.resources[14].name" == "/test/bare/39"
jsonpath "$.result.resources[14].mimeType" == "application/schema+json"
jsonpath "$.result.resources[14].size" == 130
jsonpath "$.result.resources[14].annotations.priority" == 0.5
jsonpath "$.result.resources[15].uri" == "{{base}}/test/bare/40"
jsonpath "$.result.resources[15].name" == "/test/bare/40"
jsonpath "$.result.resources[15].mimeType" == "application/schema+json"
jsonpath "$.result.resources[15].size" == 130
jsonpath "$.result.resources[15].annotations.priority" == 0.5
jsonpath "$.result.resources[16].uri" == "{{base}}/test/bare/41"
jsonpath "$.result.resources[16].name" == "/test/bare/41"
jsonpath "$.result.resources[16].mimeType" == "application/schema+json"
jsonpath "$.result.resources[16].size" == 130
jsonpath "$.result.resources[16].annotations.priority" == 0.5
jsonpath "$.result.resources[17].uri" == "{{base}}/test/bare/42"
jsonpath "$.result.resources[17].name" == "/test/bare/42"
jsonpath "$.result.resources[17].mimeType" == "application/schema+json"
jsonpath "$.result.resources[17].size" == 130
jsonpath "$.result.resources[17].annotations.priority" == 0.5
jsonpath "$.result.resources[18].uri" == "{{base}}/test/bare/43"
jsonpath "$.result.resources[18].name" == "/test/bare/43"
jsonpath "$.result.resources[18].mimeType" == "application/schema+json"
jsonpath "$.result.resources[18].size" == 130
jsonpath "$.result.resources[18].annotations.priority" == 0.5
jsonpath "$.result.resources[19].uri" == "{{base}}/test/bare/44"
jsonpath "$.result.resources[19].name" == "/test/bare/44"
jsonpath "$.result.resources[19].mimeType" == "application/schema+json"
jsonpath "$.result.resources[19].size" == 130
jsonpath "$.result.resources[19].annotations.priority" == 0.5
jsonpath "$.result.resources[20].uri" == "{{base}}/test/bare/45"
jsonpath "$.result.resources[20].name" == "/test/bare/45"
jsonpath "$.result.resources[20].mimeType" == "application/schema+json"
jsonpath "$.result.resources[20].size" == 130
jsonpath "$.result.resources[20].annotations.priority" == 0.5
jsonpath "$.result.resources[21].uri" == "{{base}}/test/bare/46"
jsonpath "$.result.resources[21].name" == "/test/bare/46"
jsonpath "$.result.resources[21].mimeType" == "application/schema+json"
jsonpath "$.result.resources[21].size" == 130
jsonpath "$.result.resources[21].annotations.priority" == 0.5
jsonpath "$.result.resources[22].uri" == "{{base}}/test/bare/47"
jsonpath "$.result.resources[22].name" == "/test/bare/47"
jsonpath "$.result.resources[22].mimeType" == "application/schema+json"
jsonpath "$.result.resources[22].size" == 130
jsonpath "$.result.resources[22].annotations.priority" == 0.5
jsonpath "$.result.resources[23].uri" == "{{base}}/test/bare/48"
jsonpath "$.result.resources[23].name" == "/test/bare/48"
jsonpath "$.result.resources[23].mimeType" == "application/schema+json"
jsonpath "$.result.resources[23].size" == 130
jsonpath "$.result.resources[23].annotations.priority" == 0.5
jsonpath "$.result.resources[24].uri" == "{{base}}/test/bare/49"
jsonpath "$.result.resources[24].name" == "/test/bare/49"
jsonpath "$.result.resources[24].mimeType" == "application/schema+json"
jsonpath "$.result.resources[24].size" == 130
jsonpath "$.result.resources[24].annotations.priority" == 0.5
jsonpath "$.result.resources[25].uri" == "{{base}}/test/bare/50"
jsonpath "$.result.resources[25].name" == "/test/bare/50"
jsonpath "$.result.resources[25].mimeType" == "application/schema+json"
jsonpath "$.result.resources[25].size" == 130
jsonpath "$.result.resources[25].annotations.priority" == 0.5
jsonpath "$.result.resources[26].uri" == "{{base}}/test/draft3/string"
jsonpath "$.result.resources[26].name" == "/test/draft3/string"
jsonpath "$.result.resources[26].mimeType" == "application/schema+json"
jsonpath "$.result.resources[26].size" == 130
jsonpath "$.result.resources[26].annotations.priority" == 0.5
jsonpath "$.result.resources[27].uri" == "{{base}}/self/v1/schemas/api/auth/login/response"
jsonpath "$.result.resources[27].name" == "Sourcemeta One Login API Response"
jsonpath "$.result.resources[27].description" == "The ways of signing in to this instance, which a custom interface reads to offer them"
jsonpath "$.result.resources[27].mimeType" == "application/schema+json"
jsonpath "$.result.resources[27].size" == 1735
jsonpath "$.result.resources[27].annotations.priority" == 0
jsonpath "$.result.resources[28].uri" == "{{base}}/self/v1/schemas/api/error"
jsonpath "$.result.resources[28].name" == "Sourcemeta One API Error"
jsonpath "$.result.resources[28].description" == "The error response format returned by the Sourcemeta One API endpoints"
jsonpath "$.result.resources[28].mimeType" == "application/schema+json"
jsonpath "$.result.resources[28].size" == 10190
jsonpath "$.result.resources[28].annotations.priority" == 0
jsonpath "$.result.resources[29].uri" == "{{base}}/self/v1/schemas/api/list/response"
jsonpath "$.result.resources[29].name" == "Sourcemeta One List API Response"
jsonpath "$.result.resources[29].description" == "The response format for the directory listing API endpoint"
jsonpath "$.result.resources[29].mimeType" == "application/schema+json"
jsonpath "$.result.resources[29].size" == 3878
jsonpath "$.result.resources[29].annotations.priority" == 0
jsonpath "$.result.resources[30].uri" == "{{base}}/self/v1/schemas/api/schemas/dependencies/response"
jsonpath "$.result.resources[30].name" == "Sourcemeta One Schema Dependencies API Response"
jsonpath "$.result.resources[30].description" == "The response format for the schema dependencies API endpoint"
jsonpath "$.result.resources[30].mimeType" == "application/schema+json"
jsonpath "$.result.resources[30].size" == 992
jsonpath "$.result.resources[30].annotations.priority" == 0
jsonpath "$.result.resources[31].uri" == "{{base}}/self/v1/schemas/api/schemas/dependents/response"
jsonpath "$.result.resources[31].name" == "Sourcemeta One Schema Dependents API Response"
jsonpath "$.result.resources[31].description" == "The response format for the schema dependents API endpoint"
jsonpath "$.result.resources[31].mimeType" == "application/schema+json"
jsonpath "$.result.resources[31].size" == 986
jsonpath "$.result.resources[31].annotations.priority" == 0
jsonpath "$.result.resources[32].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/request"
jsonpath "$.result.resources[32].name" == "Sourcemeta One Schema Evaluate API Request"
jsonpath "$.result.resources[32].description" == "The JSON instance to validate against a schema in the catalog"
jsonpath "$.result.resources[32].mimeType" == "application/schema+json"
jsonpath "$.result.resources[32].size" == 417
jsonpath "$.result.resources[32].annotations.priority" == 0
jsonpath "$.result.resources[33].uri" == "{{base}}/self/v1/schemas/api/schemas/evaluate/response"
jsonpath "$.result.resources[33].name" == "Sourcemeta One Schema Evaluate API Response"
jsonpath "$.result.resources[33].description" == "The response format for the schema evaluation API endpoint"
jsonpath "$.result.resources[33].mimeType" == "application/schema+json"
jsonpath "$.result.resources[33].size" == 2138
jsonpath "$.result.resources[33].annotations.priority" == 0
jsonpath "$.result.resources[34].uri" == "{{base}}/self/v1/schemas/api/schemas/health/response"
jsonpath "$.result.resources[34].name" == "Sourcemeta One Schema Health API Response"
jsonpath "$.result.resources[34].description" == "The response format for the schema health API endpoint"
jsonpath "$.result.resources[34].mimeType" == "application/schema+json"
jsonpath "$.result.resources[34].size" == 1584
jsonpath "$.result.resources[34].annotations.priority" == 0
jsonpath "$.result.resources[35].uri" == "{{base}}/self/v1/schemas/api/schemas/locations/response"
jsonpath "$.result.resources[35].name" == "Sourcemeta One Schema Locations API Response"
jsonpath "$.result.resources[35].description" == "The response format for the schema frame locations API endpoint"
jsonpath "$.result.resources[35].mimeType" == "application/schema+json"
jsonpath "$.result.resources[35].size" == 2391
jsonpath "$.result.resources[35].annotations.priority" == 0
jsonpath "$.result.resources[36].uri" == "{{base}}/self/v1/schemas/api/schemas/metadata/response"
jsonpath "$.result.resources[36].name" == "Sourcemeta One Schema Metadata API Response"
jsonpath "$.result.resources[36].description" == "The response format for the schema metadata API endpoint"
jsonpath "$.result.resources[36].mimeType" == "application/schema+json"
jsonpath "$.result.resources[36].size" == 2943
jsonpath "$.result.resources[36].annotations.priority" == 0
jsonpath "$.result.resources[37].uri" == "{{base}}/self/v1/schemas/api/schemas/output-error"
jsonpath "$.result.resources[37].name" == "Sourcemeta One Schema Output Error"
jsonpath "$.result.resources[37].description" == "A single entry of the standard JSON Schema output format that describes why an instance does not conform to a schema"
jsonpath "$.result.resources[37].mimeType" == "application/schema+json"
jsonpath "$.result.resources[37].size" == 1143
jsonpath "$.result.resources[37].annotations.priority" == 0
jsonpath "$.result.resources[38].uri" == "{{base}}/self/v1/schemas/api/schemas/position"
jsonpath "$.result.resources[38].name" == "Sourcemeta One Schema Position"
jsonpath "$.result.resources[38].description" == "Represents a position in a JSON document as line start, column start, line end, and column end"
jsonpath "$.result.resources[38].mimeType" == "application/schema+json"
jsonpath "$.result.resources[38].size" == 446
jsonpath "$.result.resources[38].annotations.priority" == 0
jsonpath "$.result.resources[39].uri" == "{{base}}/self/v1/schemas/api/schemas/positions/response"
jsonpath "$.result.resources[39].name" == "Sourcemeta One Schema Positions API Response"
jsonpath "$.result.resources[39].description" == "The response format for the schema positions API endpoint"
jsonpath "$.result.resources[39].mimeType" == "application/schema+json"
jsonpath "$.result.resources[39].size" == 435
jsonpath "$.result.resources[39].annotations.priority" == 0
jsonpath "$.result.resources[40].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/request"
jsonpath "$.result.resources[40].name" == "Sourcemeta One Schema RDF API Request"
jsonpath "$.result.resources[40].description" == "The JSON instance to promote to JSON-LD against a schema in the catalog, along with the desired output form"
jsonpath "$.result.resources[40].mimeType" == "application/schema+json"
jsonpath "$.result.resources[40].size" == 1422
jsonpath "$.result.resources[40].annotations.priority" == 0
jsonpath "$.result.resources[41].uri" == "{{base}}/self/v1/schemas/api/schemas/rdf/response"
jsonpath "$.result.resources[41].name" == "Sourcemeta One Schema RDF API Response"
jsonpath "$.result.resources[41].description" == "The instance promoted to JSON-LD, in expanded, flattened, or compacted form"
jsonpath "$.result.resources[41].mimeType" == "application/schema+json"
jsonpath "$.result.resources[41].size" == 799
jsonpath "$.result.resources[41].annotations.priority" == 0
jsonpath "$.result.resources[42].uri" == "{{base}}/self/v1/schemas/api/schemas/search/response"
jsonpath "$.result.resources[42].name" == "Sourcemeta One Schema Search API Response"
jsonpath "$.result.resources[42].description" == "The response format for the schema search API endpoint"
jsonpath "$.result.resources[42].mimeType" == "application/schema+json"
jsonpath "$.result.resources[42].size" == 1341
jsonpath "$.result.resources[42].annotations.priority" == 0
jsonpath "$.result.resources[43].uri" == "{{base}}/self/v1/schemas/api/schemas/stats/response"
jsonpath "$.result.resources[43].name" == "Sourcemeta One Schema Stats API Response"
jsonpath "$.result.resources[43].description" == "The response format for the schema statistics API endpoint"
jsonpath "$.result.resources[43].mimeType" == "application/schema+json"
jsonpath "$.result.resources[43].size" == 2345
jsonpath "$.result.resources[43].annotations.priority" == 0
jsonpath "$.result.resources[44].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/inline/request"
jsonpath "$.result.resources[44].name" == "Sourcemeta One Schema Inline Trace API Request"
jsonpath "$.result.resources[44].description" == "A JSON instance and the schema to trace its evaluation against"
jsonpath "$.result.resources[44].mimeType" == "application/schema+json"
jsonpath "$.result.resources[44].size" == 852
jsonpath "$.result.resources[44].annotations.priority" == 0
jsonpath "$.result.resources[45].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/request"
jsonpath "$.result.resources[45].name" == "Sourcemeta One Schema Trace API Request"
jsonpath "$.result.resources[45].description" == "The JSON instance to trace evaluation against a schema in the catalog"
jsonpath "$.result.resources[45].mimeType" == "application/schema+json"
jsonpath "$.result.resources[45].size" == 419
jsonpath "$.result.resources[45].annotations.priority" == 0
jsonpath "$.result.resources[46].uri" == "{{base}}/self/v1/schemas/api/schemas/trace/response"
jsonpath "$.result.resources[46].name" == "Sourcemeta One Schema Trace API Response"
jsonpath "$.result.resources[46].description" == "The response format for the schema trace API endpoint"
jsonpath "$.result.resources[46].mimeType" == "application/schema+json"
jsonpath "$.result.resources[46].size" == 2290
jsonpath "$.result.resources[46].annotations.priority" == 0
jsonpath "$.result.resources[47].uri" == "{{base}}/self/v1/schemas/mcp/error"
jsonpath "$.result.resources[47].name" == "Sourcemeta One MCP Error Response"
jsonpath "$.result.resources[47].description" == "The error response Sourcemeta One returns when an MCP request fails"
jsonpath "$.result.resources[47].mimeType" == "application/schema+json"
jsonpath "$.result.resources[47].size" == 5860
jsonpath "$.result.resources[47].annotations.priority" == 0
jsonpath "$.result.resources[48].uri" == "{{base}}/self/v1/schemas/mcp/initialize/request"
jsonpath "$.result.resources[48].name" == "Sourcemeta One MCP Initialize Request"
jsonpath "$.result.resources[48].description" == "Connection handshake from a client"
jsonpath "$.result.resources[48].mimeType" == "application/schema+json"
jsonpath "$.result.resources[48].size" == 4617
jsonpath "$.result.resources[48].annotations.priority" == 0
jsonpath "$.result.resources[49].uri" == "{{base}}/self/v1/schemas/mcp/initialize/response"
jsonpath "$.result.resources[49].name" == "Sourcemeta One MCP Initialize Response"
jsonpath "$.result.resources[49].description" == "Sourcemeta One's response to a client's initialization"
jsonpath "$.result.resources[49].mimeType" == "application/schema+json"
jsonpath "$.result.resources[49].size" == 2524
jsonpath "$.result.resources[49].annotations.priority" == 0
jsonpath "$.result.nextCursor" == "100"

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

# The out-of-bounds error echoes the original input verbatim, not the
# canonicalized form, so callers always see what they sent

POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 45,
  "method": "resources/list",
  "params": {
    "cursor": "0999998"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 45
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid resource list cursor"
jsonpath "$.error.data" == "Use the `nextCursor` returned by a prior resources/list response, or omit it to start from the beginning"

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
  "id": 12,
  "method": "resources/templates/list"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 12
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
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 20,
  "method": "resources/read",
  "params": {
    "uri": "not a uri"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 20
jsonpath "$.error.code" == -32600
jsonpath "$.error.message" == "Invalid Request"

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
  "id": 22,
  "method": "resources/read",
  "params": {
    "uri": "{{base}}/does/not/exist"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 22
jsonpath "$.error.code" == -32002
jsonpath "$.error.message" == "Resource not found"

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
  "id": 40,
  "method": "resources/read",
  "params": {
    "uri": "{{base}}/self/v1/schemas/mcp/response#/properties"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 40
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid resource schema URI"
jsonpath "$.error.data" == "URIs accepted by resources/read must not contain a fragment and may only carry an optional `bundle` query parameter"

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
  "id": 41,
  "method": "resources/read",
  "params": {
    "uri": "{{base}}/self/v1/schemas/mcp/response#"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 41
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid resource schema URI"
jsonpath "$.error.data" == "URIs accepted by resources/read must not contain a fragment and may only carry an optional `bundle` query parameter"

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

GET {{base}}/self/v1/schemas/mcp/response
HTTP 200
Cache-Control: public, max-age=0, must-revalidate
[Captures]
unbundled_response_text: body
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
  "id": 42,
  "method": "resources/read",
  "params": {
    "uri": "HTTP://localhost:{{port}}/self/v1/schemas/mcp/response"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 42
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "HTTP://localhost:{{port}}/self/v1/schemas/mcp/response"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"
jsonpath "$.result.contents[0].text" == "{{unbundled_response_text}}"

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
  "id": 43,
  "method": "resources/read",
  "params": {
    "uri": "http://LOCALHOST:{{port}}/self/v1/schemas/mcp/response"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 43
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "http://LOCALHOST:{{port}}/self/v1/schemas/mcp/response"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"
jsonpath "$.result.contents[0].text" == "{{unbundled_response_text}}"

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
  "id": 44,
  "method": "resources/read",
  "params": {
    "uri": "{{base}}/SELF/V1/SCHEMAS/MCP/RESPONSE"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 44
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/SELF/V1/SCHEMAS/MCP/RESPONSE"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"
jsonpath "$.result.contents[0].text" == "{{unbundled_response_text}}"

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
  "id": 30,
  "method": "resources/read",
  "params": {
    "uri": "{{base}}/test/object"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 30
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

GET {{base}}/test/object.json
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
  "id": 31,
  "method": "resources/read",
  "params": {
    "uri": "{{base}}/test/object.json"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 31
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/test/object.json"
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

GET {{base}}/self/v1/schemas/mcp/response?bundle=1
HTTP 200
Cache-Control: public, max-age=0, must-revalidate
[Captures]
bundled_schema_text: body
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
  "id": 32,
  "method": "resources/read",
  "params": {
    "uri": "{{base}}/self/v1/schemas/mcp/response?bundle=1"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 32
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/self/v1/schemas/mcp/response?bundle=1"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"
jsonpath "$.result.contents[0].text" == "{{bundled_schema_text}}"

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
  "id": 35,
  "method": "resources/read",
  "params": {
    "uri": "{{base}}/self/v1/schemas/mcp/response?bundle"
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 35
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/self/v1/schemas/mcp/response?bundle"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"
jsonpath "$.result.contents[0].text" == "{{bundled_schema_text}}"

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
  "id": 36,
  "method": "resources/read",
  "params": {
    "uri": "{{base}}/self/v1/schemas/mcp/response?bundle="
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
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 36
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/self/v1/schemas/mcp/response?bundle="
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"
jsonpath "$.result.contents[0].text" == "{{bundled_schema_text}}"

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
