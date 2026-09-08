# A schema supplied in the request can name any schema in this catalog, so what
# it may reach has to be what the caller may read and nothing more. Trace makes
# that sharper than evaluate does, because a step message carries the values the
# schema was written with, so a reference that resolves when it should not does
# not leak a bit, it prints the schema.
#
# This sandbox gates one collection with each of two keys and leaves a third
# public, and it puts the whole playground namespace under the first policy. So
# the holder of one key is admitted to the route, may reach what is public and
# what their own key gates, and must be refused the other collection entirely.

# The playground namespace sits under a policy, so nobody reaches the
# compiler without a credential
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "string"
  }
}
```
HTTP 401
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag, WWW-Authenticate
Link: </self/v1/schemas/api/error>; rel="describedby"
WWW-Authenticate: Bearer realm="registry"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.type" == "urn:sourcemeta:one:authentication-required"
jsonpath "$.title" == "Unauthorized"
jsonpath "$.status" == 401
jsonpath "$.detail" == "This resource requires authentication"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# A credential this instance does not know is no credential at all
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer not-a-real-key
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "string"
  }
}
```
HTTP 401
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag, WWW-Authenticate
Link: </self/v1/schemas/api/error>; rel="describedby"
WWW-Authenticate: Bearer realm="registry"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.type" == "urn:sourcemeta:one:authentication-required"
jsonpath "$.title" == "Unauthorized"
jsonpath "$.status" == 401
jsonpath "$.detail" == "This resource requires authentication"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# Admitted, and a schema that references nothing works as it does
# anywhere else
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "instance": "hello",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "string"
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/api/playground/schemas/trace/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true
jsonpath "$.steps" count == 2
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "AssertionTypeStrict"
jsonpath "$.steps[0].evaluatePath" == "/type"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 2
jsonpath "$.steps[0].instancePositions[3]" == 21
jsonpath "$.steps[0].keywordLocation" == "#/type"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 21
jsonpath "$.steps[1].keywordLocation" == "#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == "The value was expected to be of type string"
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# A reference to what is public resolves for anybody admitted to the route
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "instance": "hello",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/open/string"
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/api/playground/schemas/trace/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true
jsonpath "$.steps" count == 5
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 2
jsonpath "$.steps[0].instancePositions[3]" == 21
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].name" == "AnnotationEmit"
jsonpath "$.steps[1].evaluatePath" == "/$ref/title"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 21
jsonpath "$.steps[1].keywordLocation" == "{{base}}/open/string#/title"
jsonpath "$.steps[1].annotation" == "An open string"
jsonpath "$.steps[1].message" == "The title of the instance was \"An open string\""
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/$ref/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 2
jsonpath "$.steps[2].instancePositions[3]" == 21
jsonpath "$.steps[2].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AssertionTypeStrict"
jsonpath "$.steps[3].evaluatePath" == "/$ref/type"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 2
jsonpath "$.steps[3].instancePositions[3]" == 21
jsonpath "$.steps[3].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The value was expected to be of type string"
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "ControlJump"
jsonpath "$.steps[4].evaluatePath" == "/$ref"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 2
jsonpath "$.steps[4].instancePositions[1]" == 3
jsonpath "$.steps[4].instancePositions[2]" == 2
jsonpath "$.steps[4].instancePositions[3]" == 21
jsonpath "$.steps[4].keywordLocation" == "#/$ref"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# A reference to the collection this caller's own key gates resolves, and
# what that schema says decides the verdict
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "instance": {
    "token": "abc"
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/vault/secret"
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/api/playground/schemas/trace/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true
jsonpath "$.steps" count == 17
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 4
jsonpath "$.steps[0].instancePositions[3]" == 3
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "AssertionDefinesStrict"
jsonpath "$.steps[1].evaluatePath" == "/$ref/required"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 4
jsonpath "$.steps[1].instancePositions[3]" == 3
jsonpath "$.steps[1].keywordLocation" == "{{base}}/vault/secret#/required"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AssertionDefinesStrict"
jsonpath "$.steps[2].evaluatePath" == "/$ref/required"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 4
jsonpath "$.steps[2].instancePositions[3]" == 3
jsonpath "$.steps[2].keywordLocation" == "{{base}}/vault/secret#/required"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be an object that defines the property \"token\""
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AnnotationEmit"
jsonpath "$.steps[3].evaluatePath" == "/$ref/title"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 4
jsonpath "$.steps[3].instancePositions[3]" == 3
jsonpath "$.steps[3].keywordLocation" == "{{base}}/vault/secret#/title"
jsonpath "$.steps[3].annotation" == "A gated object"
jsonpath "$.steps[3].message" == "The title of the instance was \"A gated object\""
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[4].type" == "push"
jsonpath "$.steps[4].name" == "LogicalWhenType"
jsonpath "$.steps[4].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 2
jsonpath "$.steps[4].instancePositions[1]" == 3
jsonpath "$.steps[4].instancePositions[2]" == 4
jsonpath "$.steps[4].instancePositions[3]" == 3
jsonpath "$.steps[4].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == null
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[5].type" == "push"
jsonpath "$.steps[5].name" == "ControlJump"
jsonpath "$.steps[5].evaluatePath" == "/$ref/properties/token/$ref"
jsonpath "$.steps[5].instanceLocation" == "/token"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 3
jsonpath "$.steps[5].instancePositions[1]" == 5
jsonpath "$.steps[5].instancePositions[2]" == 3
jsonpath "$.steps[5].instancePositions[3]" == 18
jsonpath "$.steps[5].keywordLocation" == "{{base}}/vault/secret#/properties/token/$ref"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == null
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[6].type" == "pass"
jsonpath "$.steps[6].name" == "AnnotationEmit"
jsonpath "$.steps[6].evaluatePath" == "/$ref/properties/token/$ref/title"
jsonpath "$.steps[6].instanceLocation" == "/token"
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].instancePositions[0]" == 3
jsonpath "$.steps[6].instancePositions[1]" == 5
jsonpath "$.steps[6].instancePositions[2]" == 3
jsonpath "$.steps[6].instancePositions[3]" == 18
jsonpath "$.steps[6].keywordLocation" == "{{base}}/open/string#/title"
jsonpath "$.steps[6].annotation" == "An open string"
jsonpath "$.steps[6].message" == "The title of the instance location \"/token\" was \"An open string\""
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[7].type" == "push"
jsonpath "$.steps[7].name" == "AssertionTypeStrict"
jsonpath "$.steps[7].evaluatePath" == "/$ref/properties/token/$ref/type"
jsonpath "$.steps[7].instanceLocation" == "/token"
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[7].instancePositions[0]" == 3
jsonpath "$.steps[7].instancePositions[1]" == 5
jsonpath "$.steps[7].instancePositions[2]" == 3
jsonpath "$.steps[7].instancePositions[3]" == 18
jsonpath "$.steps[7].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.steps[7].annotation" == null
jsonpath "$.steps[7].message" == null
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[8].type" == "pass"
jsonpath "$.steps[8].name" == "AssertionTypeStrict"
jsonpath "$.steps[8].evaluatePath" == "/$ref/properties/token/$ref/type"
jsonpath "$.steps[8].instanceLocation" == "/token"
jsonpath "$.steps[8].instancePositions" count == 4
jsonpath "$.steps[8].instancePositions[0]" == 3
jsonpath "$.steps[8].instancePositions[1]" == 5
jsonpath "$.steps[8].instancePositions[2]" == 3
jsonpath "$.steps[8].instancePositions[3]" == 18
jsonpath "$.steps[8].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.steps[8].annotation" == null
jsonpath "$.steps[8].message" == "The value was expected to be of type string"
jsonpath "$.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[9].type" == "pass"
jsonpath "$.steps[9].name" == "ControlJump"
jsonpath "$.steps[9].evaluatePath" == "/$ref/properties/token/$ref"
jsonpath "$.steps[9].instanceLocation" == "/token"
jsonpath "$.steps[9].instancePositions" count == 4
jsonpath "$.steps[9].instancePositions[0]" == 3
jsonpath "$.steps[9].instancePositions[1]" == 5
jsonpath "$.steps[9].instancePositions[2]" == 3
jsonpath "$.steps[9].instancePositions[3]" == 18
jsonpath "$.steps[9].keywordLocation" == "{{base}}/vault/secret#/properties/token/$ref"
jsonpath "$.steps[9].annotation" == null
jsonpath "$.steps[9].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[10].type" == "pass"
jsonpath "$.steps[10].name" == "AnnotationEmitWrapped"
jsonpath "$.steps[10].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[10].instanceLocation" == ""
jsonpath "$.steps[10].instancePositions" count == 4
jsonpath "$.steps[10].instancePositions[0]" == 2
jsonpath "$.steps[10].instancePositions[1]" == 3
jsonpath "$.steps[10].instancePositions[2]" == 4
jsonpath "$.steps[10].instancePositions[3]" == 3
jsonpath "$.steps[10].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.steps[10].annotation" == "token"
jsonpath "$.steps[10].message" == "The object property \"token\" successfully validated against its property subschema"
jsonpath "$.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[11].type" == "pass"
jsonpath "$.steps[11].name" == "LogicalWhenType"
jsonpath "$.steps[11].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[11].instanceLocation" == ""
jsonpath "$.steps[11].instancePositions" count == 4
jsonpath "$.steps[11].instancePositions[0]" == 2
jsonpath "$.steps[11].instancePositions[1]" == 3
jsonpath "$.steps[11].instancePositions[2]" == 4
jsonpath "$.steps[11].instancePositions[3]" == 3
jsonpath "$.steps[11].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.steps[11].annotation" == null
jsonpath "$.steps[11].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[11].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[12].type" == "push"
jsonpath "$.steps[12].name" == "LoopPropertiesExcept"
jsonpath "$.steps[12].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.steps[12].instanceLocation" == ""
jsonpath "$.steps[12].instancePositions" count == 4
jsonpath "$.steps[12].instancePositions[0]" == 2
jsonpath "$.steps[12].instancePositions[1]" == 3
jsonpath "$.steps[12].instancePositions[2]" == 4
jsonpath "$.steps[12].instancePositions[3]" == 3
jsonpath "$.steps[12].keywordLocation" == "{{base}}/vault/secret#/additionalProperties"
jsonpath "$.steps[12].annotation" == null
jsonpath "$.steps[12].message" == null
jsonpath "$.steps[12].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[13].type" == "pass"
jsonpath "$.steps[13].name" == "LoopPropertiesExcept"
jsonpath "$.steps[13].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.steps[13].instanceLocation" == ""
jsonpath "$.steps[13].instancePositions" count == 4
jsonpath "$.steps[13].instancePositions[0]" == 2
jsonpath "$.steps[13].instancePositions[1]" == 3
jsonpath "$.steps[13].instancePositions[2]" == 4
jsonpath "$.steps[13].instancePositions[3]" == 3
jsonpath "$.steps[13].keywordLocation" == "{{base}}/vault/secret#/additionalProperties"
jsonpath "$.steps[13].annotation" == null
jsonpath "$.steps[13].message" == "The object value was not expected to define additional properties"
jsonpath "$.steps[13].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[14].type" == "push"
jsonpath "$.steps[14].name" == "AssertionTypeStrict"
jsonpath "$.steps[14].evaluatePath" == "/$ref/type"
jsonpath "$.steps[14].instanceLocation" == ""
jsonpath "$.steps[14].instancePositions" count == 4
jsonpath "$.steps[14].instancePositions[0]" == 2
jsonpath "$.steps[14].instancePositions[1]" == 3
jsonpath "$.steps[14].instancePositions[2]" == 4
jsonpath "$.steps[14].instancePositions[3]" == 3
jsonpath "$.steps[14].keywordLocation" == "{{base}}/vault/secret#/type"
jsonpath "$.steps[14].annotation" == null
jsonpath "$.steps[14].message" == null
jsonpath "$.steps[14].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[15].type" == "pass"
jsonpath "$.steps[15].name" == "AssertionTypeStrict"
jsonpath "$.steps[15].evaluatePath" == "/$ref/type"
jsonpath "$.steps[15].instanceLocation" == ""
jsonpath "$.steps[15].instancePositions" count == 4
jsonpath "$.steps[15].instancePositions[0]" == 2
jsonpath "$.steps[15].instancePositions[1]" == 3
jsonpath "$.steps[15].instancePositions[2]" == 4
jsonpath "$.steps[15].instancePositions[3]" == 3
jsonpath "$.steps[15].keywordLocation" == "{{base}}/vault/secret#/type"
jsonpath "$.steps[15].annotation" == null
jsonpath "$.steps[15].message" == "The value was expected to be of type object"
jsonpath "$.steps[15].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[16].type" == "pass"
jsonpath "$.steps[16].name" == "ControlJump"
jsonpath "$.steps[16].evaluatePath" == "/$ref"
jsonpath "$.steps[16].instanceLocation" == ""
jsonpath "$.steps[16].instancePositions" count == 4
jsonpath "$.steps[16].instancePositions[0]" == 2
jsonpath "$.steps[16].instancePositions[1]" == 3
jsonpath "$.steps[16].instancePositions[2]" == 4
jsonpath "$.steps[16].instancePositions[3]" == 3
jsonpath "$.steps[16].keywordLocation" == "#/$ref"
jsonpath "$.steps[16].annotation" == null
jsonpath "$.steps[16].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[16].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# The same reference with an instance that schema refuses, which proves
# the reference genuinely resolved rather than being quietly ignored
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "instance": {
    "token": 42
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/vault/secret"
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/api/playground/schemas/trace/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == false
jsonpath "$.steps" count == 12
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 4
jsonpath "$.steps[0].instancePositions[3]" == 3
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "AssertionDefinesStrict"
jsonpath "$.steps[1].evaluatePath" == "/$ref/required"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 4
jsonpath "$.steps[1].instancePositions[3]" == 3
jsonpath "$.steps[1].keywordLocation" == "{{base}}/vault/secret#/required"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AssertionDefinesStrict"
jsonpath "$.steps[2].evaluatePath" == "/$ref/required"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 4
jsonpath "$.steps[2].instancePositions[3]" == 3
jsonpath "$.steps[2].keywordLocation" == "{{base}}/vault/secret#/required"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be an object that defines the property \"token\""
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AnnotationEmit"
jsonpath "$.steps[3].evaluatePath" == "/$ref/title"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 4
jsonpath "$.steps[3].instancePositions[3]" == 3
jsonpath "$.steps[3].keywordLocation" == "{{base}}/vault/secret#/title"
jsonpath "$.steps[3].annotation" == "A gated object"
jsonpath "$.steps[3].message" == "The title of the instance was \"A gated object\""
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[4].type" == "push"
jsonpath "$.steps[4].name" == "LogicalWhenType"
jsonpath "$.steps[4].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 2
jsonpath "$.steps[4].instancePositions[1]" == 3
jsonpath "$.steps[4].instancePositions[2]" == 4
jsonpath "$.steps[4].instancePositions[3]" == 3
jsonpath "$.steps[4].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == null
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[5].type" == "push"
jsonpath "$.steps[5].name" == "ControlJump"
jsonpath "$.steps[5].evaluatePath" == "/$ref/properties/token/$ref"
jsonpath "$.steps[5].instanceLocation" == "/token"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 3
jsonpath "$.steps[5].instancePositions[1]" == 5
jsonpath "$.steps[5].instancePositions[2]" == 3
jsonpath "$.steps[5].instancePositions[3]" == 15
jsonpath "$.steps[5].keywordLocation" == "{{base}}/vault/secret#/properties/token/$ref"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == null
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[6].type" == "pass"
jsonpath "$.steps[6].name" == "AnnotationEmit"
jsonpath "$.steps[6].evaluatePath" == "/$ref/properties/token/$ref/title"
jsonpath "$.steps[6].instanceLocation" == "/token"
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].instancePositions[0]" == 3
jsonpath "$.steps[6].instancePositions[1]" == 5
jsonpath "$.steps[6].instancePositions[2]" == 3
jsonpath "$.steps[6].instancePositions[3]" == 15
jsonpath "$.steps[6].keywordLocation" == "{{base}}/open/string#/title"
jsonpath "$.steps[6].annotation" == "An open string"
jsonpath "$.steps[6].message" == "The title of the instance location \"/token\" was \"An open string\""
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[7].type" == "push"
jsonpath "$.steps[7].name" == "AssertionTypeStrict"
jsonpath "$.steps[7].evaluatePath" == "/$ref/properties/token/$ref/type"
jsonpath "$.steps[7].instanceLocation" == "/token"
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[7].instancePositions[0]" == 3
jsonpath "$.steps[7].instancePositions[1]" == 5
jsonpath "$.steps[7].instancePositions[2]" == 3
jsonpath "$.steps[7].instancePositions[3]" == 15
jsonpath "$.steps[7].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.steps[7].annotation" == null
jsonpath "$.steps[7].message" == null
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[8].type" == "fail"
jsonpath "$.steps[8].name" == "AssertionTypeStrict"
jsonpath "$.steps[8].evaluatePath" == "/$ref/properties/token/$ref/type"
jsonpath "$.steps[8].instanceLocation" == "/token"
jsonpath "$.steps[8].instancePositions" count == 4
jsonpath "$.steps[8].instancePositions[0]" == 3
jsonpath "$.steps[8].instancePositions[1]" == 5
jsonpath "$.steps[8].instancePositions[2]" == 3
jsonpath "$.steps[8].instancePositions[3]" == 15
jsonpath "$.steps[8].keywordLocation" == "{{base}}/open/string#/type"
jsonpath "$.steps[8].annotation" == null
jsonpath "$.steps[8].message" == "The value was expected to be of type string but it was of type integer"
jsonpath "$.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[9].type" == "fail"
jsonpath "$.steps[9].name" == "ControlJump"
jsonpath "$.steps[9].evaluatePath" == "/$ref/properties/token/$ref"
jsonpath "$.steps[9].instanceLocation" == "/token"
jsonpath "$.steps[9].instancePositions" count == 4
jsonpath "$.steps[9].instancePositions[0]" == 3
jsonpath "$.steps[9].instancePositions[1]" == 5
jsonpath "$.steps[9].instancePositions[2]" == 3
jsonpath "$.steps[9].instancePositions[3]" == 15
jsonpath "$.steps[9].keywordLocation" == "{{base}}/vault/secret#/properties/token/$ref"
jsonpath "$.steps[9].annotation" == null
jsonpath "$.steps[9].message" == "The integer value was expected to validate against the referenced schema"
jsonpath "$.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[10].type" == "fail"
jsonpath "$.steps[10].name" == "LogicalWhenType"
jsonpath "$.steps[10].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[10].instanceLocation" == ""
jsonpath "$.steps[10].instancePositions" count == 4
jsonpath "$.steps[10].instancePositions[0]" == 2
jsonpath "$.steps[10].instancePositions[1]" == 3
jsonpath "$.steps[10].instancePositions[2]" == 4
jsonpath "$.steps[10].instancePositions[3]" == 3
jsonpath "$.steps[10].keywordLocation" == "{{base}}/vault/secret#/properties"
jsonpath "$.steps[10].annotation" == null
jsonpath "$.steps[10].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[11].type" == "fail"
jsonpath "$.steps[11].name" == "ControlJump"
jsonpath "$.steps[11].evaluatePath" == "/$ref"
jsonpath "$.steps[11].instanceLocation" == ""
jsonpath "$.steps[11].instancePositions" count == 4
jsonpath "$.steps[11].instancePositions[0]" == 2
jsonpath "$.steps[11].instancePositions[1]" == 3
jsonpath "$.steps[11].instancePositions[2]" == 4
jsonpath "$.steps[11].instancePositions[3]" == 3
jsonpath "$.steps[11].keywordLocation" == "#/$ref"
jsonpath "$.steps[11].annotation" == null
jsonpath "$.steps[11].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[11].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# A schema nested deeper under the same policy is reachable too, since a
# policy governs everything beneath it
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "instance": {},
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/vault/inner/hidden"
  }
}
```
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/api/playground/schemas/trace/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true
jsonpath "$.steps" count == 5
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 2
jsonpath "$.steps[0].instancePositions[3]" == 16
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].name" == "AnnotationEmit"
jsonpath "$.steps[1].evaluatePath" == "/$ref/title"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 16
jsonpath "$.steps[1].keywordLocation" == "{{base}}/vault/inner/hidden#/title"
jsonpath "$.steps[1].annotation" == "A gated schema one level under the policy"
jsonpath "$.steps[1].message" == "The title of the instance was \"A gated schema one level under the policy\""
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/$ref/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 2
jsonpath "$.steps[2].instancePositions[3]" == 16
jsonpath "$.steps[2].keywordLocation" == "{{base}}/vault/inner/hidden#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AssertionTypeStrict"
jsonpath "$.steps[3].evaluatePath" == "/$ref/type"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 2
jsonpath "$.steps[3].instancePositions[3]" == 16
jsonpath "$.steps[3].keywordLocation" == "{{base}}/vault/inner/hidden#/type"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The value was expected to be of type object"
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "ControlJump"
jsonpath "$.steps[4].evaluatePath" == "/$ref"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 2
jsonpath "$.steps[4].instancePositions[1]" == 3
jsonpath "$.steps[4].instancePositions[2]" == 2
jsonpath "$.steps[4].instancePositions[3]" == 16
jsonpath "$.steps[4].keywordLocation" == "#/$ref"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# THE ONE THIS FEATURE EXISTS TO PASS. This caller is admitted to the
# route by the first key, but the second collection is gated by a key they do
# not hold. Its schema must not resolve, and nothing of it may appear in the
# answer. The reference itself comes back because the caller wrote it, which
# tells them nothing they did not already know
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "instance": {
    "anything": 1
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/ledger/entry"
  }
}
```
HTTP 400
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/api/error>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "A reference in the supplied schema could not be resolved"
jsonpath "$.reference" == "{{base}}/ledger/entry"
jsonpath "$.schemaLocation" == "/$ref"
body not contains "A schema gated by a second policy"
body not contains "steps"
body not contains "valid"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# Being refused and never having been there are one answer, so a path
# under that collection which does not exist reads exactly the same
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer vault-secret-key
```
{
  "instance": {
    "anything": 1
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/ledger/no-such-schema"
  }
}
```
HTTP 400
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/api/error>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "A reference in the supplied schema could not be resolved"
jsonpath "$.reference" == "{{base}}/ledger/no-such-schema"
jsonpath "$.schemaLocation" == "/$ref"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

# The credential is read again from the deferred body rather than captured
# off a request that is gone by then. So the holder of the second key, who is
# not admitted to this route at all, is refused here rather than resolving as
# somebody else
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer ledger-secret-key
```
{
  "instance": {
    "anything": 1
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/vault/secret"
  }
}
```
HTTP 401
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag, WWW-Authenticate
Link: </self/v1/schemas/api/error>; rel="describedby"
WWW-Authenticate: Bearer realm="registry"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.type" == "urn:sourcemeta:one:authentication-required"
jsonpath "$.title" == "Unauthorized"
jsonpath "$.status" == 401
jsonpath "$.detail" == "This resource requires authentication"

# The answer above is described by a schema this instance serves, so it
# validates against the very schema its Link header names
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true
