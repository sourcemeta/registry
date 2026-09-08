# Here the playground namespace itself is ungated, so the tool is offered to
# anybody and the compiler is reachable without a credential. That makes this
# the sharper test of the two: what a supplied schema may reference is decided
# per reference, against whoever is asking, rather than by whether they were
# admitted to the tool at all.

# The tool is offered to anybody, since nothing governs the namespace here
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 4000,
  "method": "tools/list"
}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.result.tools" count == 13
jsonpath "$.result.tools[*].name" contains "playground_trace_schema"

# An anonymous caller reaches the compiler and traces a schema of their own
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 4001,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"type\": \"string\"}",
      "stringifiedInstance": "\"hello\""
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4001
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.structuredContent.valid" == true
jsonpath "$.result.structuredContent.steps" count == 2
jsonpath "$.result.structuredContent.steps[0].type" == "push"
jsonpath "$.result.structuredContent.steps[0].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[0].evaluatePath" == "/type"
jsonpath "$.result.structuredContent.steps[0].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[0].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[0].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[0].keywordLocation" == "#/type"
jsonpath "$.result.structuredContent.steps[0].annotation" == null
jsonpath "$.result.structuredContent.steps[0].message" == null
jsonpath "$.result.structuredContent.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[1].type" == "pass"
jsonpath "$.result.structuredContent.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[1].evaluatePath" == "/type"
jsonpath "$.result.structuredContent.steps[1].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[1].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[1].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[1].keywordLocation" == "#/type"
jsonpath "$.result.structuredContent.steps[1].annotation" == null
jsonpath "$.result.structuredContent.steps[1].message" == "The value was expected to be of type string"
jsonpath "$.result.structuredContent.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"

# The envelope is described by a schema this instance serves
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# And may reference what is public
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 4002,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/public/string\"}",
      "stringifiedInstance": "\"hello\""
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4002
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.structuredContent.valid" == true
jsonpath "$.result.structuredContent.steps" count == 4
jsonpath "$.result.structuredContent.steps[0].type" == "push"
jsonpath "$.result.structuredContent.steps[0].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[0].evaluatePath" == "/$ref"
jsonpath "$.result.structuredContent.steps[0].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[0].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[0].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.result.structuredContent.steps[0].annotation" == null
jsonpath "$.result.structuredContent.steps[0].message" == null
jsonpath "$.result.structuredContent.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.result.structuredContent.steps[1].type" == "push"
jsonpath "$.result.structuredContent.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[1].evaluatePath" == "/$ref/type"
jsonpath "$.result.structuredContent.steps[1].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[1].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[1].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[1].keywordLocation" == "{{base}}/public/string#/type"
jsonpath "$.result.structuredContent.steps[1].annotation" == null
jsonpath "$.result.structuredContent.steps[1].message" == null
jsonpath "$.result.structuredContent.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[2].type" == "pass"
jsonpath "$.result.structuredContent.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[2].evaluatePath" == "/$ref/type"
jsonpath "$.result.structuredContent.steps[2].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[2].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[2].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[2].keywordLocation" == "{{base}}/public/string#/type"
jsonpath "$.result.structuredContent.steps[2].annotation" == null
jsonpath "$.result.structuredContent.steps[2].message" == "The value was expected to be of type string"
jsonpath "$.result.structuredContent.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[3].type" == "pass"
jsonpath "$.result.structuredContent.steps[3].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[3].evaluatePath" == "/$ref"
jsonpath "$.result.structuredContent.steps[3].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[3].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[3].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[3].keywordLocation" == "#/$ref"
jsonpath "$.result.structuredContent.steps[3].annotation" == null
jsonpath "$.result.structuredContent.steps[3].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.result.structuredContent.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

# The envelope is described by a schema this instance serves
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# THE ONE THAT MATTERS. The same anonymous caller, holding the tool, names a
# schema they may not read. It must not resolve, and none of what it says may
# come back
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 4003,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/private/secret\"}",
      "stringifiedInstance": "{\"token\": \"abc\"}"
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4003
jsonpath "$.result.isError" == true
jsonpath "$.result.content" count == 1
jsonpath "$.result.content[0].text" == "A reference in the supplied schema could not be resolved"
jsonpath "$.result.structuredContent" not exists
body not contains "additionalProperties"
body not contains "structuredContent"

# The envelope is described by a schema this instance serves
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# Present the credential that governs it and the very same call resolves,
# which is what proves the refusal above was authorization rather than an
# accident
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer primary-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 4004,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/private/secret\"}",
      "stringifiedInstance": "{\"token\": \"abc\"}"
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4004
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.structuredContent.valid" == true
jsonpath "$.result.structuredContent.steps" count == 13
jsonpath "$.result.structuredContent.steps[0].type" == "push"
jsonpath "$.result.structuredContent.steps[0].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[0].evaluatePath" == "/$ref"
jsonpath "$.result.structuredContent.steps[0].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[0].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[0].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.result.structuredContent.steps[0].annotation" == null
jsonpath "$.result.structuredContent.steps[0].message" == null
jsonpath "$.result.structuredContent.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.result.structuredContent.steps[1].type" == "push"
jsonpath "$.result.structuredContent.steps[1].name" == "AssertionDefinesStrict"
jsonpath "$.result.structuredContent.steps[1].evaluatePath" == "/$ref/required"
jsonpath "$.result.structuredContent.steps[1].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[1].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[1].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[1].keywordLocation" == "{{base}}/private/secret#/required"
jsonpath "$.result.structuredContent.steps[1].annotation" == null
jsonpath "$.result.structuredContent.steps[1].message" == null
jsonpath "$.result.structuredContent.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[2].type" == "pass"
jsonpath "$.result.structuredContent.steps[2].name" == "AssertionDefinesStrict"
jsonpath "$.result.structuredContent.steps[2].evaluatePath" == "/$ref/required"
jsonpath "$.result.structuredContent.steps[2].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[2].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[2].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[2].keywordLocation" == "{{base}}/private/secret#/required"
jsonpath "$.result.structuredContent.steps[2].annotation" == null
jsonpath "$.result.structuredContent.steps[2].message" == "The value was expected to be an object that defines the property \"token\""
jsonpath "$.result.structuredContent.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[3].type" == "push"
jsonpath "$.result.structuredContent.steps[3].name" == "LogicalWhenType"
jsonpath "$.result.structuredContent.steps[3].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[3].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[3].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[3].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[3].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.result.structuredContent.steps[3].annotation" == null
jsonpath "$.result.structuredContent.steps[3].message" == null
jsonpath "$.result.structuredContent.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[4].type" == "push"
jsonpath "$.result.structuredContent.steps[4].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[4].evaluatePath" == "/$ref/properties/token/type"
jsonpath "$.result.structuredContent.steps[4].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[4].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[4].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[4].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[3]" == 15
jsonpath "$.result.structuredContent.steps[4].keywordLocation" == "{{base}}/private/secret#/properties/token/type"
jsonpath "$.result.structuredContent.steps[4].annotation" == null
jsonpath "$.result.structuredContent.steps[4].message" == null
jsonpath "$.result.structuredContent.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[5].type" == "pass"
jsonpath "$.result.structuredContent.steps[5].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[5].evaluatePath" == "/$ref/properties/token/type"
jsonpath "$.result.structuredContent.steps[5].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[5].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[5].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[5].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[5].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[5].instancePositions[3]" == 15
jsonpath "$.result.structuredContent.steps[5].keywordLocation" == "{{base}}/private/secret#/properties/token/type"
jsonpath "$.result.structuredContent.steps[5].annotation" == null
jsonpath "$.result.structuredContent.steps[5].message" == "The value was expected to be of type string"
jsonpath "$.result.structuredContent.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[6].type" == "pass"
jsonpath "$.result.structuredContent.steps[6].name" == "AnnotationEmitWrapped"
jsonpath "$.result.structuredContent.steps[6].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[6].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[6].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[6].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[6].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.result.structuredContent.steps[6].annotation" == "token"
jsonpath "$.result.structuredContent.steps[6].message" == "The object property \"token\" successfully validated against its property subschema"
jsonpath "$.result.structuredContent.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[7].type" == "pass"
jsonpath "$.result.structuredContent.steps[7].name" == "LogicalWhenType"
jsonpath "$.result.structuredContent.steps[7].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[7].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[7].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[7].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[7].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.result.structuredContent.steps[7].annotation" == null
jsonpath "$.result.structuredContent.steps[7].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.result.structuredContent.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[8].type" == "push"
jsonpath "$.result.structuredContent.steps[8].name" == "LoopPropertiesExcept"
jsonpath "$.result.structuredContent.steps[8].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.result.structuredContent.steps[8].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[8].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[8].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[8].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[8].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[8].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[8].keywordLocation" == "{{base}}/private/secret#/additionalProperties"
jsonpath "$.result.structuredContent.steps[8].annotation" == null
jsonpath "$.result.structuredContent.steps[8].message" == null
jsonpath "$.result.structuredContent.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[9].type" == "pass"
jsonpath "$.result.structuredContent.steps[9].name" == "LoopPropertiesExcept"
jsonpath "$.result.structuredContent.steps[9].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.result.structuredContent.steps[9].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[9].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[9].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[9].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[9].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[9].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[9].keywordLocation" == "{{base}}/private/secret#/additionalProperties"
jsonpath "$.result.structuredContent.steps[9].annotation" == null
jsonpath "$.result.structuredContent.steps[9].message" == "The object value was not expected to define additional properties"
jsonpath "$.result.structuredContent.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[10].type" == "push"
jsonpath "$.result.structuredContent.steps[10].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[10].evaluatePath" == "/$ref/type"
jsonpath "$.result.structuredContent.steps[10].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[10].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[10].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[10].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[10].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[10].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[10].keywordLocation" == "{{base}}/private/secret#/type"
jsonpath "$.result.structuredContent.steps[10].annotation" == null
jsonpath "$.result.structuredContent.steps[10].message" == null
jsonpath "$.result.structuredContent.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[11].type" == "pass"
jsonpath "$.result.structuredContent.steps[11].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[11].evaluatePath" == "/$ref/type"
jsonpath "$.result.structuredContent.steps[11].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[11].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[11].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[11].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[11].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[11].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[11].keywordLocation" == "{{base}}/private/secret#/type"
jsonpath "$.result.structuredContent.steps[11].annotation" == null
jsonpath "$.result.structuredContent.steps[11].message" == "The value was expected to be of type object"
jsonpath "$.result.structuredContent.steps[11].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[12].type" == "pass"
jsonpath "$.result.structuredContent.steps[12].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[12].evaluatePath" == "/$ref"
jsonpath "$.result.structuredContent.steps[12].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[12].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[12].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[12].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[12].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[12].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[12].keywordLocation" == "#/$ref"
jsonpath "$.result.structuredContent.steps[12].annotation" == null
jsonpath "$.result.structuredContent.steps[12].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.result.structuredContent.steps[12].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

# The envelope is described by a schema this instance serves
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# With an instance that schema refuses, so the reference is demonstrably
# being evaluated rather than skipped
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer primary-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 4005,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/private/secret\"}",
      "stringifiedInstance": "{\"token\": 42}"
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4005
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.structuredContent.valid" == false
jsonpath "$.result.structuredContent.steps" count == 8
jsonpath "$.result.structuredContent.steps[0].type" == "push"
jsonpath "$.result.structuredContent.steps[0].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[0].evaluatePath" == "/$ref"
jsonpath "$.result.structuredContent.steps[0].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[0].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[0].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[0].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.result.structuredContent.steps[0].annotation" == null
jsonpath "$.result.structuredContent.steps[0].message" == null
jsonpath "$.result.structuredContent.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.result.structuredContent.steps[1].type" == "push"
jsonpath "$.result.structuredContent.steps[1].name" == "AssertionDefinesStrict"
jsonpath "$.result.structuredContent.steps[1].evaluatePath" == "/$ref/required"
jsonpath "$.result.structuredContent.steps[1].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[1].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[1].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[1].keywordLocation" == "{{base}}/private/secret#/required"
jsonpath "$.result.structuredContent.steps[1].annotation" == null
jsonpath "$.result.structuredContent.steps[1].message" == null
jsonpath "$.result.structuredContent.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[2].type" == "pass"
jsonpath "$.result.structuredContent.steps[2].name" == "AssertionDefinesStrict"
jsonpath "$.result.structuredContent.steps[2].evaluatePath" == "/$ref/required"
jsonpath "$.result.structuredContent.steps[2].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[2].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[2].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[2].keywordLocation" == "{{base}}/private/secret#/required"
jsonpath "$.result.structuredContent.steps[2].annotation" == null
jsonpath "$.result.structuredContent.steps[2].message" == "The value was expected to be an object that defines the property \"token\""
jsonpath "$.result.structuredContent.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[3].type" == "push"
jsonpath "$.result.structuredContent.steps[3].name" == "LogicalWhenType"
jsonpath "$.result.structuredContent.steps[3].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[3].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[3].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[3].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[3].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.result.structuredContent.steps[3].annotation" == null
jsonpath "$.result.structuredContent.steps[3].message" == null
jsonpath "$.result.structuredContent.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[4].type" == "push"
jsonpath "$.result.structuredContent.steps[4].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[4].evaluatePath" == "/$ref/properties/token/type"
jsonpath "$.result.structuredContent.steps[4].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[4].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[4].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[4].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[3]" == 12
jsonpath "$.result.structuredContent.steps[4].keywordLocation" == "{{base}}/private/secret#/properties/token/type"
jsonpath "$.result.structuredContent.steps[4].annotation" == null
jsonpath "$.result.structuredContent.steps[4].message" == null
jsonpath "$.result.structuredContent.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[5].type" == "fail"
jsonpath "$.result.structuredContent.steps[5].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[5].evaluatePath" == "/$ref/properties/token/type"
jsonpath "$.result.structuredContent.steps[5].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[5].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[5].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[5].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[5].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[5].instancePositions[3]" == 12
jsonpath "$.result.structuredContent.steps[5].keywordLocation" == "{{base}}/private/secret#/properties/token/type"
jsonpath "$.result.structuredContent.steps[5].annotation" == null
jsonpath "$.result.structuredContent.steps[5].message" == "The value was expected to be of type string but it was of type integer"
jsonpath "$.result.structuredContent.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[6].type" == "fail"
jsonpath "$.result.structuredContent.steps[6].name" == "LogicalWhenType"
jsonpath "$.result.structuredContent.steps[6].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[6].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[6].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[6].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[6].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.result.structuredContent.steps[6].annotation" == null
jsonpath "$.result.structuredContent.steps[6].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.result.structuredContent.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[7].type" == "fail"
jsonpath "$.result.structuredContent.steps[7].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[7].evaluatePath" == "/$ref"
jsonpath "$.result.structuredContent.steps[7].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[7].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[7].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[7].keywordLocation" == "#/$ref"
jsonpath "$.result.structuredContent.steps[7].annotation" == null
jsonpath "$.result.structuredContent.steps[7].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.result.structuredContent.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

# The envelope is described by a schema this instance serves
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# A credential for a different collection does not open this one
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer internal-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 4006,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/private/secret\"}",
      "stringifiedInstance": "{\"token\": \"abc\"}"
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4006
jsonpath "$.result.isError" == true
jsonpath "$.result.content" count == 1
jsonpath "$.result.content[0].text" == "A reference in the supplied schema could not be resolved"
jsonpath "$.result.structuredContent" not exists
body not contains "additionalProperties"
body not contains "structuredContent"

# The envelope is described by a schema this instance serves
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# And the reverse, so neither key stands in for the other
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer primary-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 4007,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/internal/config\"}",
      "stringifiedInstance": "{}"
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4007
jsonpath "$.result.isError" == true
jsonpath "$.result.content" count == 1
jsonpath "$.result.content[0].text" == "A reference in the supplied schema could not be resolved"
jsonpath "$.result.structuredContent" not exists

# The envelope is described by a schema this instance serves
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# A credential this instance does not know leaves the caller anonymous for
# the purposes of what a reference may reach
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer not-a-real-key
```
{
  "jsonrpc": "2.0",
  "id": 4008,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/private/secret\"}",
      "stringifiedInstance": "{\"token\": \"abc\"}"
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4008
jsonpath "$.result.isError" == true
jsonpath "$.result.content" count == 1
jsonpath "$.result.content[0].text" == "A reference in the supplied schema could not be resolved"
jsonpath "$.result.structuredContent" not exists
body not contains "additionalProperties"
body not contains "structuredContent"

# The envelope is described by a schema this instance serves
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# A gated schema reached through a chain rather than named directly is
# refused at the hop that needs the credential
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 4009,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$defs\": {\"hop\": {\"$ref\": \"{{base}}/private/secret\"}}, \"$ref\": \"#/$defs/hop\"}",
      "stringifiedInstance": "{\"token\": \"abc\"}"
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 4009
jsonpath "$.result.isError" == true
jsonpath "$.result.content" count == 1
jsonpath "$.result.content[0].text" == "A reference in the supplied schema could not be resolved"
jsonpath "$.result.structuredContent" not exists
body not contains "additionalProperties"
body not contains "structuredContent"

# The envelope is described by a schema this instance serves
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true
