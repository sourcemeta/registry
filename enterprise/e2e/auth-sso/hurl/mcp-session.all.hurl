# The third credential type over MCP. A browser signs in and holds a session
# cookie, and the catalog it sees through MCP has to be the one that session
# admits, not the anonymous one and not everything.
#
# This is the case the specification says nothing about: cookies are unmentioned
# on the MCP transport in every revision. Unmentioned is not forbidden, and the
# gate here admits whatever a covering policy admits, so the answer has to be
# consistent with what the same credential gets everywhere else.
#
# The session is obtained by signing in at the real provider, exactly as
# `login.all.hurl` does, so what is exercised is the session this instance
# actually mints rather than one composed here.

# Anonymously, the catalog holds one schema outside `/self`, since `/private`,
# `/archive`, `/discovery`, `/unavailable` and `/rotated` are all governed
POST {{base}}/self/v1/mcp
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{ "jsonrpc": "2.0", "id": 1, "method": "resources/list" }
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
anonymous_body: body
mcp_schema: header "Link" regex "<([^>]+)>"
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.resources" count == 50
jsonpath "$.result.nextCursor" == "50"
jsonpath "$.result.resources[0].uri" == "{{base}}/public/string"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/private/secret"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/archive/record"

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{anonymous_body}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# The same read without the session is refused, so the cookie is what admitted
# it rather than the schema being reachable all along
POST {{base}}/self/v1/mcp
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 5,
  "method": "resources/read",
  "params": { "uri": "{{base}}/private/secret" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
anonymous_read: body
{
  "jsonrpc": "2.0",
  "id": 5,
  "error": {
    "code": -32002,
    "message": "Resource not found"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{anonymous_read}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# A cookie signed by nobody this instance trusts admits nothing, so a forged
# session reads exactly like the anonymous refusal above
POST {{base}}/self/v1/mcp
Cookie: sourcemeta_one_session=1.4102444800.4102448400.eyJwb2xpY3kiOiJrZXljbG9hayJ9.bm90LWEtc2lnbmF0dXJlLXRoaXMtaW5zdGFuY2UtbWludGVk
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 8,
  "method": "resources/read",
  "params": { "uri": "{{base}}/private/secret" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
forged_read: body
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
{{forged_read}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# What a credential admits is this instance's own decision, so it cannot move
# with the protocol revision a client happens to speak. Each supported revision
# is asked the same denied read, and each must answer the same way. The
# envelope around a successful result does change by revision, which
# `mcp-2025-*` in the `html` sandbox covers, and that is exactly why the
# invariant half is worth stating here: a client negotiating an older revision
# must not thereby be admitted to more, or less
POST {{base}}/self/v1/mcp
MCP-Protocol-Version: 2025-03-26
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 20,
  "method": "resources/read",
  "params": { "uri": "{{base}}/private/secret" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
denial_2025_03_26: body
{
  "jsonrpc": "2.0",
  "id": 20,
  "error": {
    "code": -32002,
    "message": "Resource not found"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{denial_2025_03_26}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
MCP-Protocol-Version: 2025-06-18
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 20,
  "method": "resources/read",
  "params": { "uri": "{{base}}/private/secret" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
denial_2025_06_18: body
[Asserts]
body == {{denial_2025_03_26}}
{
  "jsonrpc": "2.0",
  "id": 20,
  "error": {
    "code": -32002,
    "message": "Resource not found"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{denial_2025_06_18}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

POST {{base}}/self/v1/mcp
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 20,
  "method": "resources/read",
  "params": { "uri": "{{base}}/private/secret" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
denial_2025_11_25: body
[Asserts]
body == {{denial_2025_03_26}}
{
  "jsonrpc": "2.0",
  "id": 20,
  "error": {
    "code": -32002,
    "message": "Resource not found"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{denial_2025_11_25}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# An unsupported revision is refused before any of that, so the invariant above
# is over the revisions this instance actually speaks
POST {{base}}/self/v1/mcp
MCP-Protocol-Version: 2026-07-28
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 21,
  "method": "resources/read",
  "params": { "uri": "{{base}}/private/secret" }
}
```
HTTP 400
Cache-Control: no-store
[Asserts]
jsonpath "$.error.code" == -32003

# Signing in at the provider, which is what every later request presents. The
# cookie jar carries the session from here, so nothing below names it
GET {{base}}/self/v1/auth/login/keycloak
HTTP 303
[Captures]
authorize_url: header "Location"

GET {{authorize_url}}
HTTP 200
[Captures]
login_action: xpath "string(//form[@id='kc-form-login']/@action)"

POST {{login_action}}
[FormParams]
username: jane
password: jane-password
HTTP 302
[Captures]
callback_url: header "Location"

GET {{callback_url}}
HTTP 303
Cache-Control: no-store
[Asserts]
cookie "sourcemeta_one_session" exists

# The same request under a session admits the two collections that policy
# governs, and nothing else. `/discovery` is governed by a different
# interactive policy, so it stays out: holding a session is not holding every
# session
POST {{base}}/self/v1/mcp
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
session_body: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.resources" count == 50
jsonpath "$.result.nextCursor" == "50"
jsonpath "$.result.resources[0].uri" == "{{base}}/archive/record"
jsonpath "$.result.resources[0].name" == "/archive/record"
jsonpath "$.result.resources[0].mimeType" == "application/schema+json"
jsonpath "$.result.resources[0].size" == 181
jsonpath "$.result.resources[0].annotations.priority" == 0.5
jsonpath "$.result.resources[1].uri" == "{{base}}/private/secret"
jsonpath "$.result.resources[1].name" == "/private/secret"
jsonpath "$.result.resources[1].size" == 209
jsonpath "$.result.resources[2].uri" == "{{base}}/public/string"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/discovery/thing"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/unavailable/thing"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/rotated/thing"

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{session_body}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# The second page completes it, so the two together are everything the session
# may see and the exclusions above hold across the whole catalog rather than
# across one page of it
POST {{base}}/self/v1/mcp
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
session_page_two: body
[Asserts]
jsonpath "$.result.resources" count == 20
jsonpath "$.result.nextCursor" not exists
jsonpath "$.result.resources[*].uri" not includes "{{base}}/discovery/thing"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/unavailable/thing"
jsonpath "$.result.resources[*].uri" not includes "{{base}}/rotated/thing"

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{session_page_two}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# Reading a governed schema under the session returns it, so the filter above
# is not merely cosmetic
POST {{base}}/self/v1/mcp
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 4,
  "method": "resources/read",
  "params": { "uri": "{{base}}/private/secret" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
session_read: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.contents" count == 1
jsonpath "$.result.contents[0].uri" == "{{base}}/private/secret"
jsonpath "$.result.contents[0].mimeType" == "application/schema+json"

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{session_read}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# A schema governed by the other interactive policy is refused under this
# session, which is the same refusal an anonymous caller gets. One session is
# one policy's worth of access
POST {{base}}/self/v1/mcp
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 6,
  "method": "resources/read",
  "params": { "uri": "{{base}}/discovery/thing" }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/mcp/response>; rel="describedby"
[Captures]
other_policy_read: body
{
  "jsonrpc": "2.0",
  "id": 6,
  "error": {
    "code": -32002,
    "message": "Resource not found"
  }
}

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{other_policy_read}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# A tool runs on the caller's behalf, so it sees what the session sees
POST {{base}}/self/v1/mcp
MCP-Protocol-Version: 2025-11-25
Content-Type: application/json
```
{
  "jsonrpc": "2.0",
  "id": 7,
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
session_tool: body
[Asserts]
jsonpath "$.error" not exists
jsonpath "$.result.isError" == false
jsonpath "$.result.structuredContent" exists

POST {{base}}/self/v1/api/schemas/evaluate{{mcp_schema}}
```
{{session_tool}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

