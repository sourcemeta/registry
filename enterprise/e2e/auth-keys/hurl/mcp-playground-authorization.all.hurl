# The playground namespace is gated here, so the tool it publishes is only
# offered to a caller admitted to it, and what a supplied schema may reference
# is still decided per reference against that same caller.
#
# A tool a caller cannot see is also a tool they cannot call. That matters more
# than the listing does: hiding a tool that could still be invoked would be
# decoration rather than a gate.

# Anonymous is offered everything ungoverned, and not this
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 3000,
  "method": "tools/list"
}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.result.tools" count == 11
jsonpath "$.result.tools[*].name" not contains "playground_trace_schema"

# Nor is the holder of a key for another collection
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer ledger-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3001,
  "method": "tools/list"
}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.result.tools" count == 11
jsonpath "$.result.tools[*].name" not contains "playground_trace_schema"

# The key that governs the namespace is offered it
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3002,
  "method": "tools/list"
}
```
HTTP 200
Cache-Control: no-store
[Asserts]
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.result.tools" count == 13
jsonpath "$.result.tools[*].name" contains "playground_trace_schema"

# Anonymous naming the tool anyway is refused as though it did not exist,
# which is the same answer a genuinely unknown name gets, so the refusal
# reveals nothing about what this instance holds
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 3003,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"type\": \"string\"}",
      "stringifiedInstance": "\"x\""
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
jsonpath "$.id" == 3003
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid tool name"
jsonpath "$.error.data" == "Use `tools/list` to discover the available tools"
jsonpath "$.result" not exists

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

# A credential this instance does not know fares the same
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer not-a-real-key
```
{
  "jsonrpc": "2.0",
  "id": 3004,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"type\": \"string\"}",
      "stringifiedInstance": "\"x\""
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
jsonpath "$.id" == 3004
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid tool name"
jsonpath "$.error.data" == "Use `tools/list` to discover the available tools"
jsonpath "$.result" not exists

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

# So does a key that governs some other collection
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer ledger-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3005,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"type\": \"string\"}",
      "stringifiedInstance": "\"x\""
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
jsonpath "$.id" == 3005
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" == "Invalid tool name"
jsonpath "$.error.data" == "Use `tools/list` to discover the available tools"
jsonpath "$.result" not exists

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

# The admitted caller reaches the compiler
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3006,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"type\": \"string\"}",
      "stringifiedInstance": "\"x\""
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
jsonpath "$.id" == 3006
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
jsonpath "$.result.structuredContent.steps[0].instancePositions[3]" == 3
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
jsonpath "$.result.structuredContent.steps[1].instancePositions[3]" == 3
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

# And may reference what their own key gates
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3007,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/vault/secret\"}",
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
jsonpath "$.id" == 3007
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.structuredContent.valid" == true
jsonpath "$.result.structuredContent.steps" count == 17
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
jsonpath "$.result.structuredContent.steps[1].keywordLocation" == "{{base}}/vault/secret#/required"
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
jsonpath "$.result.structuredContent.steps[2].keywordLocation" == "{{base}}/vault/secret#/required"
jsonpath "$.result.structuredContent.steps[2].annotation" == null
jsonpath "$.result.structuredContent.steps[2].message" == "The value was expected to be an object that defines the property \"token\""
jsonpath "$.result.structuredContent.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[3].type" == "pass"
jsonpath "$.result.structuredContent.steps[3].name" == "AnnotationEmit"
jsonpath "$.result.structuredContent.steps[3].evaluatePath" == "/$ref/title"
jsonpath "$.result.structuredContent.steps[3].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[3].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[3].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[3].keywordLocation" == "{{base}}/vault/secret#/title"
jsonpath "$.result.structuredContent.steps[3].annotation" == "A gated object"
jsonpath "$.result.structuredContent.steps[3].message" == "The title of the instance was \"A gated object\""
jsonpath "$.result.structuredContent.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.result.structuredContent.steps[4].type" == "push"
jsonpath "$.result.structuredContent.steps[4].name" == "LogicalWhenType"
jsonpath "$.result.structuredContent.steps[4].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[4].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[4].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[4].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[4].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.result.structuredContent.steps[4].annotation" == null
jsonpath "$.result.structuredContent.steps[4].message" == null
jsonpath "$.result.structuredContent.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[5].type" == "push"
jsonpath "$.result.structuredContent.steps[5].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[5].evaluatePath" == "/$ref/properties/token/$ref"
jsonpath "$.result.structuredContent.steps[5].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[5].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[5].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[5].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[5].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[5].instancePositions[3]" == 15
jsonpath "$.result.structuredContent.steps[5].keywordLocation" == "{{base}}/vault/secret#/properties/token/$ref"
jsonpath "$.result.structuredContent.steps[5].annotation" == null
jsonpath "$.result.structuredContent.steps[5].message" == null
jsonpath "$.result.structuredContent.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.result.structuredContent.steps[6].type" == "pass"
jsonpath "$.result.structuredContent.steps[6].name" == "AnnotationEmit"
jsonpath "$.result.structuredContent.steps[6].evaluatePath" == "/$ref/properties/token/$ref/title"
jsonpath "$.result.structuredContent.steps[6].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[6].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[6].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[6].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[3]" == 15
jsonpath "$.result.structuredContent.steps[6].keywordLocation" == "{{base}}/open/string#/title"
jsonpath "$.result.structuredContent.steps[6].annotation" == "An open string"
jsonpath "$.result.structuredContent.steps[6].message" == "The title of the instance location \"/token\" was \"An open string\""
jsonpath "$.result.structuredContent.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.result.structuredContent.steps[7].type" == "push"
jsonpath "$.result.structuredContent.steps[7].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[7].evaluatePath" == "/$ref/properties/token/$ref/type"
jsonpath "$.result.structuredContent.steps[7].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[7].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[7].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[7].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[3]" == 15
jsonpath "$.result.structuredContent.steps[7].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.result.structuredContent.steps[7].annotation" == null
jsonpath "$.result.structuredContent.steps[7].message" == null
jsonpath "$.result.structuredContent.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[8].type" == "pass"
jsonpath "$.result.structuredContent.steps[8].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[8].evaluatePath" == "/$ref/properties/token/$ref/type"
jsonpath "$.result.structuredContent.steps[8].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[8].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[8].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[8].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[8].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[8].instancePositions[3]" == 15
jsonpath "$.result.structuredContent.steps[8].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.result.structuredContent.steps[8].annotation" == null
jsonpath "$.result.structuredContent.steps[8].message" == "The value was expected to be of type string"
jsonpath "$.result.structuredContent.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[9].type" == "pass"
jsonpath "$.result.structuredContent.steps[9].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[9].evaluatePath" == "/$ref/properties/token/$ref"
jsonpath "$.result.structuredContent.steps[9].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[9].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[9].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[9].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[9].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[9].instancePositions[3]" == 15
jsonpath "$.result.structuredContent.steps[9].keywordLocation" == "{{base}}/vault/secret#/properties/token/$ref"
jsonpath "$.result.structuredContent.steps[9].annotation" == null
jsonpath "$.result.structuredContent.steps[9].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.result.structuredContent.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.result.structuredContent.steps[10].type" == "pass"
jsonpath "$.result.structuredContent.steps[10].name" == "AnnotationEmitWrapped"
jsonpath "$.result.structuredContent.steps[10].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[10].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[10].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[10].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[10].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[10].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[10].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[10].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.result.structuredContent.steps[10].annotation" == "token"
jsonpath "$.result.structuredContent.steps[10].message" == "The object property \"token\" successfully validated against its property subschema"
jsonpath "$.result.structuredContent.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[11].type" == "pass"
jsonpath "$.result.structuredContent.steps[11].name" == "LogicalWhenType"
jsonpath "$.result.structuredContent.steps[11].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[11].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[11].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[11].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[11].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[11].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[11].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[11].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.result.structuredContent.steps[11].annotation" == null
jsonpath "$.result.structuredContent.steps[11].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.result.structuredContent.steps[11].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[12].type" == "push"
jsonpath "$.result.structuredContent.steps[12].name" == "LoopPropertiesExcept"
jsonpath "$.result.structuredContent.steps[12].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.result.structuredContent.steps[12].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[12].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[12].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[12].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[12].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[12].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[12].keywordLocation" == "{{base}}/vault/secret#/additionalProperties"
jsonpath "$.result.structuredContent.steps[12].annotation" == null
jsonpath "$.result.structuredContent.steps[12].message" == null
jsonpath "$.result.structuredContent.steps[12].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[13].type" == "pass"
jsonpath "$.result.structuredContent.steps[13].name" == "LoopPropertiesExcept"
jsonpath "$.result.structuredContent.steps[13].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.result.structuredContent.steps[13].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[13].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[13].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[13].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[13].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[13].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[13].keywordLocation" == "{{base}}/vault/secret#/additionalProperties"
jsonpath "$.result.structuredContent.steps[13].annotation" == null
jsonpath "$.result.structuredContent.steps[13].message" == "The object value was not expected to define additional properties"
jsonpath "$.result.structuredContent.steps[13].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[14].type" == "push"
jsonpath "$.result.structuredContent.steps[14].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[14].evaluatePath" == "/$ref/type"
jsonpath "$.result.structuredContent.steps[14].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[14].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[14].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[14].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[14].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[14].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[14].keywordLocation" == "{{base}}/vault/secret#/type"
jsonpath "$.result.structuredContent.steps[14].annotation" == null
jsonpath "$.result.structuredContent.steps[14].message" == null
jsonpath "$.result.structuredContent.steps[14].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[15].type" == "pass"
jsonpath "$.result.structuredContent.steps[15].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[15].evaluatePath" == "/$ref/type"
jsonpath "$.result.structuredContent.steps[15].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[15].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[15].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[15].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[15].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[15].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[15].keywordLocation" == "{{base}}/vault/secret#/type"
jsonpath "$.result.structuredContent.steps[15].annotation" == null
jsonpath "$.result.structuredContent.steps[15].message" == "The value was expected to be of type object"
jsonpath "$.result.structuredContent.steps[15].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[16].type" == "pass"
jsonpath "$.result.structuredContent.steps[16].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[16].evaluatePath" == "/$ref"
jsonpath "$.result.structuredContent.steps[16].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[16].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[16].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[16].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[16].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[16].instancePositions[3]" == 16
jsonpath "$.result.structuredContent.steps[16].keywordLocation" == "#/$ref"
jsonpath "$.result.structuredContent.steps[16].annotation" == null
jsonpath "$.result.structuredContent.steps[16].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.result.structuredContent.steps[16].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

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

# The same reference with an instance that schema refuses, which proves it
# resolved rather than being skipped
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3008,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/vault/secret\"}",
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
jsonpath "$.id" == 3008
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.structuredContent.valid" == false
jsonpath "$.result.structuredContent.steps" count == 12
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
jsonpath "$.result.structuredContent.steps[1].keywordLocation" == "{{base}}/vault/secret#/required"
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
jsonpath "$.result.structuredContent.steps[2].keywordLocation" == "{{base}}/vault/secret#/required"
jsonpath "$.result.structuredContent.steps[2].annotation" == null
jsonpath "$.result.structuredContent.steps[2].message" == "The value was expected to be an object that defines the property \"token\""
jsonpath "$.result.structuredContent.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[3].type" == "pass"
jsonpath "$.result.structuredContent.steps[3].name" == "AnnotationEmit"
jsonpath "$.result.structuredContent.steps[3].evaluatePath" == "/$ref/title"
jsonpath "$.result.structuredContent.steps[3].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[3].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[3].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[3].keywordLocation" == "{{base}}/vault/secret#/title"
jsonpath "$.result.structuredContent.steps[3].annotation" == "A gated object"
jsonpath "$.result.structuredContent.steps[3].message" == "The title of the instance was \"A gated object\""
jsonpath "$.result.structuredContent.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.result.structuredContent.steps[4].type" == "push"
jsonpath "$.result.structuredContent.steps[4].name" == "LogicalWhenType"
jsonpath "$.result.structuredContent.steps[4].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[4].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[4].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[4].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[4].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.result.structuredContent.steps[4].annotation" == null
jsonpath "$.result.structuredContent.steps[4].message" == null
jsonpath "$.result.structuredContent.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[5].type" == "push"
jsonpath "$.result.structuredContent.steps[5].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[5].evaluatePath" == "/$ref/properties/token/$ref"
jsonpath "$.result.structuredContent.steps[5].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[5].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[5].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[5].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[5].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[5].instancePositions[3]" == 12
jsonpath "$.result.structuredContent.steps[5].keywordLocation" == "{{base}}/vault/secret#/properties/token/$ref"
jsonpath "$.result.structuredContent.steps[5].annotation" == null
jsonpath "$.result.structuredContent.steps[5].message" == null
jsonpath "$.result.structuredContent.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.result.structuredContent.steps[6].type" == "pass"
jsonpath "$.result.structuredContent.steps[6].name" == "AnnotationEmit"
jsonpath "$.result.structuredContent.steps[6].evaluatePath" == "/$ref/properties/token/$ref/title"
jsonpath "$.result.structuredContent.steps[6].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[6].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[6].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[6].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[6].instancePositions[3]" == 12
jsonpath "$.result.structuredContent.steps[6].keywordLocation" == "{{base}}/open/string#/title"
jsonpath "$.result.structuredContent.steps[6].annotation" == "An open string"
jsonpath "$.result.structuredContent.steps[6].message" == "The title of the instance location \"/token\" was \"An open string\""
jsonpath "$.result.structuredContent.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.result.structuredContent.steps[7].type" == "push"
jsonpath "$.result.structuredContent.steps[7].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[7].evaluatePath" == "/$ref/properties/token/$ref/type"
jsonpath "$.result.structuredContent.steps[7].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[7].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[7].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[7].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[7].instancePositions[3]" == 12
jsonpath "$.result.structuredContent.steps[7].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.result.structuredContent.steps[7].annotation" == null
jsonpath "$.result.structuredContent.steps[7].message" == null
jsonpath "$.result.structuredContent.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[8].type" == "fail"
jsonpath "$.result.structuredContent.steps[8].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[8].evaluatePath" == "/$ref/properties/token/$ref/type"
jsonpath "$.result.structuredContent.steps[8].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[8].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[8].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[8].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[8].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[8].instancePositions[3]" == 12
jsonpath "$.result.structuredContent.steps[8].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.result.structuredContent.steps[8].annotation" == null
jsonpath "$.result.structuredContent.steps[8].message" == "The value was expected to be of type string but it was of type integer"
jsonpath "$.result.structuredContent.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[9].type" == "fail"
jsonpath "$.result.structuredContent.steps[9].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[9].evaluatePath" == "/$ref/properties/token/$ref"
jsonpath "$.result.structuredContent.steps[9].instanceLocation" == "/token"
jsonpath "$.result.structuredContent.steps[9].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[9].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[9].instancePositions[1]" == 2
jsonpath "$.result.structuredContent.steps[9].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[9].instancePositions[3]" == 12
jsonpath "$.result.structuredContent.steps[9].keywordLocation" == "{{base}}/vault/secret#/properties/token/$ref"
jsonpath "$.result.structuredContent.steps[9].annotation" == null
jsonpath "$.result.structuredContent.steps[9].message" == "The integer value was expected to validate against the referenced schema"
jsonpath "$.result.structuredContent.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.result.structuredContent.steps[10].type" == "fail"
jsonpath "$.result.structuredContent.steps[10].name" == "LogicalWhenType"
jsonpath "$.result.structuredContent.steps[10].evaluatePath" == "/$ref/properties"
jsonpath "$.result.structuredContent.steps[10].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[10].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[10].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[10].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[10].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[10].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[10].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.result.structuredContent.steps[10].annotation" == null
jsonpath "$.result.structuredContent.steps[10].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.result.structuredContent.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.result.structuredContent.steps[11].type" == "fail"
jsonpath "$.result.structuredContent.steps[11].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[11].evaluatePath" == "/$ref"
jsonpath "$.result.structuredContent.steps[11].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[11].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[11].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[11].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[11].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[11].instancePositions[3]" == 13
jsonpath "$.result.structuredContent.steps[11].keywordLocation" == "#/$ref"
jsonpath "$.result.structuredContent.steps[11].annotation" == null
jsonpath "$.result.structuredContent.steps[11].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.result.structuredContent.steps[11].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

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

# A reference to what is public resolves for anybody admitted to the tool
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3009,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/open/string\"}",
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
jsonpath "$.id" == 3009
jsonpath "$.result.isError" == false
jsonpath "$.result.content" count == 1
jsonpath "$.result.structuredContent.valid" == true
jsonpath "$.result.structuredContent.steps" count == 5
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
jsonpath "$.result.structuredContent.steps[1].type" == "pass"
jsonpath "$.result.structuredContent.steps[1].name" == "AnnotationEmit"
jsonpath "$.result.structuredContent.steps[1].evaluatePath" == "/$ref/title"
jsonpath "$.result.structuredContent.steps[1].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[1].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[1].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[1].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[1].keywordLocation" == "{{base}}/open/string#/title"
jsonpath "$.result.structuredContent.steps[1].annotation" == "An open string"
jsonpath "$.result.structuredContent.steps[1].message" == "The title of the instance was \"An open string\""
jsonpath "$.result.structuredContent.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.result.structuredContent.steps[2].type" == "push"
jsonpath "$.result.structuredContent.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[2].evaluatePath" == "/$ref/type"
jsonpath "$.result.structuredContent.steps[2].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[2].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[2].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[2].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[2].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.result.structuredContent.steps[2].annotation" == null
jsonpath "$.result.structuredContent.steps[2].message" == null
jsonpath "$.result.structuredContent.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[3].type" == "pass"
jsonpath "$.result.structuredContent.steps[3].name" == "AssertionTypeStrict"
jsonpath "$.result.structuredContent.steps[3].evaluatePath" == "/$ref/type"
jsonpath "$.result.structuredContent.steps[3].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[3].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[3].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[3].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[3].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.result.structuredContent.steps[3].annotation" == null
jsonpath "$.result.structuredContent.steps[3].message" == "The value was expected to be of type string"
jsonpath "$.result.structuredContent.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.result.structuredContent.steps[4].type" == "pass"
jsonpath "$.result.structuredContent.steps[4].name" == "ControlJump"
jsonpath "$.result.structuredContent.steps[4].evaluatePath" == "/$ref"
jsonpath "$.result.structuredContent.steps[4].instanceLocation" == ""
jsonpath "$.result.structuredContent.steps[4].instancePositions" count == 4
jsonpath "$.result.structuredContent.steps[4].instancePositions[0]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[1]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[2]" == 1
jsonpath "$.result.structuredContent.steps[4].instancePositions[3]" == 7
jsonpath "$.result.structuredContent.steps[4].keywordLocation" == "#/$ref"
jsonpath "$.result.structuredContent.steps[4].annotation" == null
jsonpath "$.result.structuredContent.steps[4].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.result.structuredContent.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

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

# THE ONE THAT MATTERS OVER MCP. The other collection is gated by a key this
# caller does not hold, so its schema must not resolve and nothing of it may
# appear in the answer
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3010,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/ledger/entry\"}",
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
jsonpath "$.id" == 3010
jsonpath "$.result.isError" == true
jsonpath "$.result.content" count == 1
jsonpath "$.result.content[0].text" == "A reference in the supplied schema could not be resolved"
jsonpath "$.result.structuredContent" not exists
body not contains "A schema gated by a second policy"
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

# Being refused and never having been there are one answer, so a path under
# that collection which does not exist reads exactly the same
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 3011,
  "method": "tools/call",
  "params": {
    "name": "playground_trace_schema",
    "arguments": {
      "stringifiedSchema": "{\"$schema\": \"https://json-schema.org/draft/2020-12/schema\", \"$ref\": \"{{base}}/ledger/no-such-schema\"}",
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
jsonpath "$.id" == 3011
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
