# The playground namespace is gated here, so the tool it publishes is only
# offered to a caller admitted to it, and what a supplied schema may reference
# is still decided per reference against that same caller.

# A caller admitted to the namespace may reference what their own key gates
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 2000,
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
[Asserts]
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 2000
jsonpath "$.result.isError" == false
jsonpath "$.result.structuredContent.valid" == true
jsonpath "$.result.structuredContent.steps" count == 17

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
  "id": 2001,
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
[Asserts]
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 2001
jsonpath "$.result.isError" == false
jsonpath "$.result.structuredContent.valid" == false
jsonpath "$.result.structuredContent.steps" count == 12

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
  "id": 2002,
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
[Asserts]
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 2002
jsonpath "$.result.isError" == true
jsonpath "$.result.content[0].text" == "A reference in the supplied schema could not be resolved"
body not contains "A schema gated by a second policy"
body not contains "structuredContent"

# A reference to what is public resolves for anybody admitted to the tool
POST {{base}}/self/v1/mcp
Accept: application/json, text/event-stream
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "jsonrpc": "2.0",
  "id": 2003,
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
[Asserts]
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 2003
jsonpath "$.result.isError" == false
jsonpath "$.result.structuredContent.valid" == true
jsonpath "$.result.structuredContent.steps" count == 5
