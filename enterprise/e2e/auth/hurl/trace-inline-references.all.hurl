# Here the trace route itself is ungated, so anybody reaches the compiler. That
# makes this the sharper test of the two: what a supplied schema may reference
# is decided per reference, against whoever is asking, rather than by whether
# they got through the door.
#
# It matters most for trace specifically. A trace step carries the values the
# schema was written with, so a reference that resolves when it should not does
# not leak one bit, it prints the schema back to whoever asked.

# An anonymous caller reaches the route and compiles a schema of their own
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": "hello",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "string"
  }
}
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true
jsonpath "$.steps" count == 2

# And may reference what is public
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": "hello",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/public/string"
  }
}
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# THE ONE THAT MATTERS. The same anonymous caller, admitted to this route,
# names a schema they may not read. It must not resolve, and none of what it
# says may come back
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": { "token": "abc" },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
  }
}
HTTP 400
Cache-Control: no-store
Content-Type: application/problem+json
Link: </self/v1/schemas/api/error>; rel="describedby"
[Asserts]
jsonpath "$.status" == 400
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"
jsonpath "$.title" == "Bad Request"
jsonpath "$.detail" == "A reference in the supplied schema could not be resolved"
body not contains "token"
body not contains "additionalProperties"
body not contains "steps"
body not contains "valid"

# Present the credential that governs it and the very same request resolves.
# This is what proves the refusal above was authorization and not an accident
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
Authorization: Bearer primary-secret-key
{
  "instance": { "token": "abc" },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
  }
}
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# With an instance that schema refuses, so the reference is demonstrably being
# evaluated rather than skipped
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
Authorization: Bearer primary-secret-key
{
  "instance": { "token": 42 },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
  }
}
HTTP 200
[Asserts]
jsonpath "$.valid" == false

# A credential for a different collection does not open this one
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
Authorization: Bearer internal-secret-key
{
  "instance": { "token": "abc" },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
  }
}
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"
body not contains "token"

# And the reverse, so neither key stands in for the other
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
Authorization: Bearer primary-secret-key
{
  "instance": {},
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/internal/secret"
  }
}
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"

# A credential this instance does not know leaves the caller anonymous for the
# purposes of what a reference may reach, rather than refusing the request
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
Authorization: Bearer not-a-real-key
{
  "instance": { "token": "abc" },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
  }
}
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"

# A gated schema reached through a chain rather than named directly is refused
# at the hop that needs the credential
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": { "token": "abc" },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$defs": { "hop": { "$ref": "{{base}}/private/secret" } },
    "$ref": "#/$defs/hop"
  }
}
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"
body not contains "token"
