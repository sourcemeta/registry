# A schema supplied in the request can name any schema in this catalog, so what
# it may reach has to be what the caller may read and nothing more. Trace makes
# that sharper than evaluate does, because a step message carries the values
# the schema was written with, so a reference that resolves when it should not
# does not leak a bit, it prints the schema.
#
# This sandbox gates one collection with each of two keys and leaves a third
# public, and it puts the trace route itself under the first policy. So the
# holder of one key is admitted to the route, may reach what is public and what
# their own key gates, and must be refused the other collection entirely.

# The route sits under a policy, so nobody reaches the compiler without a
# credential
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "string"
  }
}
HTTP 401
Cache-Control: no-store
Content-Type: application/problem+json
[Asserts]
jsonpath "$.status" == 401
jsonpath "$.type" == "urn:sourcemeta:one:authentication-required"
jsonpath "$.title" == "Unauthorized"
jsonpath "$.detail" == "This resource requires authentication"

# A credential this instance does not know is no credential at all
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer not-a-real-key
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "string"
  }
}
HTTP 401
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:authentication-required"

# Admitted, and a schema that references nothing works as it does anywhere else
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
{
  "instance": "hello",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "string"
  }
}
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/playground/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# A reference to what is public resolves for anybody admitted to the route
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
{
  "instance": "hello",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/open/string"
  }
}
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A reference to the collection this caller's own key gates resolves, and what
# that schema says decides the verdict
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
{
  "instance": { "token": "abc" },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/vault/secret"
  }
}
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# The same reference, with an instance that schema refuses. This proves the
# reference genuinely resolved rather than being quietly ignored
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
{
  "instance": { "token": 42 },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/vault/secret"
  }
}
HTTP 200
[Asserts]
jsonpath "$.valid" == false

# A schema nested deeper under the same policy is reachable too, since a policy
# governs everything beneath it
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
{
  "instance": {},
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/vault/inner/hidden"
  }
}
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# THE ONE THIS FEATURE EXISTS TO PASS. This caller is admitted to the route by
# the first key, but the second collection is gated by a key they do not hold.
# Its schema must not resolve, and nothing of it may appear in the answer
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
{
  "instance": { "anything": 1 },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/ledger/entry"
  }
}
HTTP 400
Cache-Control: no-store
Content-Type: application/problem+json
[Asserts]
jsonpath "$.status" == 400
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"
jsonpath "$.title" == "Bad Request"
jsonpath "$.detail" == "A reference in the supplied schema could not be resolved"
body not contains "ledger/entry"
body not contains "A schema gated by a second policy"
body not contains "steps"

# Being refused and never having been there are one answer, so a path under
# that collection which does not exist reads exactly the same
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
{
  "instance": { "anything": 1 },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/ledger/no-such-schema"
  }
}
HTTP 400
[Asserts]
jsonpath "$.status" == 400
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"
jsonpath "$.detail" == "A reference in the supplied schema could not be resolved"

# The credential is read again from the deferred body rather than captured off
# a request that is gone by then. So the holder of the second key, who is not
# admitted to this route at all, is refused here rather than resolving as
# somebody else
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer ledger-secret-key
{
  "instance": { "anything": 1 },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/vault/secret"
  }
}
HTTP 401
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:authentication-required"
