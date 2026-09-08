# Here the playground namespace itself is ungated, so anybody reaches the
# compiler. That makes this the sharper test of the two: what a supplied schema
# may reference is decided per reference, against whoever is asking, rather than
# by whether they got through the door.
#
# It matters most for trace specifically. A trace step carries the values the
# schema was written with, so a reference that resolves when it should not does
# not leak one bit, it prints the schema back to whoever asked.

# An anonymous caller reaches the route and compiles a schema of their own
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
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

# And may reference what is public
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "hello",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/public/string"
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
jsonpath "$.steps" count == 4
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
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/$ref/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 21
jsonpath "$.steps[1].keywordLocation" == "{{base}}/public/string#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/$ref/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 2
jsonpath "$.steps[2].instancePositions[3]" == 21
jsonpath "$.steps[2].keywordLocation" == "{{base}}/public/string#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be of type string"
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "ControlJump"
jsonpath "$.steps[3].evaluatePath" == "/$ref"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 2
jsonpath "$.steps[3].instancePositions[3]" == 21
jsonpath "$.steps[3].keywordLocation" == "#/$ref"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

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

# THE ONE THAT MATTERS. The same anonymous caller, admitted to this route,
# names a schema they may not read. It must not resolve, and none of what it
# says may come back
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": {
    "token": "abc"
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
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
body not contains "token"
body not contains "additionalProperties"
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

# Present the credential that governs it and the very same request
# resolves, which is what proves the refusal above was authorization rather
# than an accident
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer primary-secret-key
```
{
  "instance": {
    "token": "abc"
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
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
jsonpath "$.steps" count == 13
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
jsonpath "$.steps[1].keywordLocation" == "{{base}}/private/secret#/required"
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
jsonpath "$.steps[2].keywordLocation" == "{{base}}/private/secret#/required"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be an object that defines the property \"token\""
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].type" == "push"
jsonpath "$.steps[3].name" == "LogicalWhenType"
jsonpath "$.steps[3].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 4
jsonpath "$.steps[3].instancePositions[3]" == 3
jsonpath "$.steps[3].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == null
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[4].type" == "push"
jsonpath "$.steps[4].name" == "AssertionTypeStrict"
jsonpath "$.steps[4].evaluatePath" == "/$ref/properties/token/type"
jsonpath "$.steps[4].instanceLocation" == "/token"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 3
jsonpath "$.steps[4].instancePositions[1]" == 5
jsonpath "$.steps[4].instancePositions[2]" == 3
jsonpath "$.steps[4].instancePositions[3]" == 18
jsonpath "$.steps[4].keywordLocation" == "{{base}}/private/secret#/properties/token/type"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == null
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "AssertionTypeStrict"
jsonpath "$.steps[5].evaluatePath" == "/$ref/properties/token/type"
jsonpath "$.steps[5].instanceLocation" == "/token"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 3
jsonpath "$.steps[5].instancePositions[1]" == 5
jsonpath "$.steps[5].instancePositions[2]" == 3
jsonpath "$.steps[5].instancePositions[3]" == 18
jsonpath "$.steps[5].keywordLocation" == "{{base}}/private/secret#/properties/token/type"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "The value was expected to be of type string"
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[6].type" == "pass"
jsonpath "$.steps[6].name" == "AnnotationEmitWrapped"
jsonpath "$.steps[6].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].instancePositions[0]" == 2
jsonpath "$.steps[6].instancePositions[1]" == 3
jsonpath "$.steps[6].instancePositions[2]" == 4
jsonpath "$.steps[6].instancePositions[3]" == 3
jsonpath "$.steps[6].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.steps[6].annotation" == "token"
jsonpath "$.steps[6].message" == "The object property \"token\" successfully validated against its property subschema"
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[7].type" == "pass"
jsonpath "$.steps[7].name" == "LogicalWhenType"
jsonpath "$.steps[7].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[7].instanceLocation" == ""
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[7].instancePositions[0]" == 2
jsonpath "$.steps[7].instancePositions[1]" == 3
jsonpath "$.steps[7].instancePositions[2]" == 4
jsonpath "$.steps[7].instancePositions[3]" == 3
jsonpath "$.steps[7].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.steps[7].annotation" == null
jsonpath "$.steps[7].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[8].type" == "push"
jsonpath "$.steps[8].name" == "LoopPropertiesExcept"
jsonpath "$.steps[8].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.steps[8].instanceLocation" == ""
jsonpath "$.steps[8].instancePositions" count == 4
jsonpath "$.steps[8].instancePositions[0]" == 2
jsonpath "$.steps[8].instancePositions[1]" == 3
jsonpath "$.steps[8].instancePositions[2]" == 4
jsonpath "$.steps[8].instancePositions[3]" == 3
jsonpath "$.steps[8].keywordLocation" == "{{base}}/private/secret#/additionalProperties"
jsonpath "$.steps[8].annotation" == null
jsonpath "$.steps[8].message" == null
jsonpath "$.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[9].type" == "pass"
jsonpath "$.steps[9].name" == "LoopPropertiesExcept"
jsonpath "$.steps[9].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.steps[9].instanceLocation" == ""
jsonpath "$.steps[9].instancePositions" count == 4
jsonpath "$.steps[9].instancePositions[0]" == 2
jsonpath "$.steps[9].instancePositions[1]" == 3
jsonpath "$.steps[9].instancePositions[2]" == 4
jsonpath "$.steps[9].instancePositions[3]" == 3
jsonpath "$.steps[9].keywordLocation" == "{{base}}/private/secret#/additionalProperties"
jsonpath "$.steps[9].annotation" == null
jsonpath "$.steps[9].message" == "The object value was not expected to define additional properties"
jsonpath "$.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[10].type" == "push"
jsonpath "$.steps[10].name" == "AssertionTypeStrict"
jsonpath "$.steps[10].evaluatePath" == "/$ref/type"
jsonpath "$.steps[10].instanceLocation" == ""
jsonpath "$.steps[10].instancePositions" count == 4
jsonpath "$.steps[10].instancePositions[0]" == 2
jsonpath "$.steps[10].instancePositions[1]" == 3
jsonpath "$.steps[10].instancePositions[2]" == 4
jsonpath "$.steps[10].instancePositions[3]" == 3
jsonpath "$.steps[10].keywordLocation" == "{{base}}/private/secret#/type"
jsonpath "$.steps[10].annotation" == null
jsonpath "$.steps[10].message" == null
jsonpath "$.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[11].type" == "pass"
jsonpath "$.steps[11].name" == "AssertionTypeStrict"
jsonpath "$.steps[11].evaluatePath" == "/$ref/type"
jsonpath "$.steps[11].instanceLocation" == ""
jsonpath "$.steps[11].instancePositions" count == 4
jsonpath "$.steps[11].instancePositions[0]" == 2
jsonpath "$.steps[11].instancePositions[1]" == 3
jsonpath "$.steps[11].instancePositions[2]" == 4
jsonpath "$.steps[11].instancePositions[3]" == 3
jsonpath "$.steps[11].keywordLocation" == "{{base}}/private/secret#/type"
jsonpath "$.steps[11].annotation" == null
jsonpath "$.steps[11].message" == "The value was expected to be of type object"
jsonpath "$.steps[11].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[12].type" == "pass"
jsonpath "$.steps[12].name" == "ControlJump"
jsonpath "$.steps[12].evaluatePath" == "/$ref"
jsonpath "$.steps[12].instanceLocation" == ""
jsonpath "$.steps[12].instancePositions" count == 4
jsonpath "$.steps[12].instancePositions[0]" == 2
jsonpath "$.steps[12].instancePositions[1]" == 3
jsonpath "$.steps[12].instancePositions[2]" == 4
jsonpath "$.steps[12].instancePositions[3]" == 3
jsonpath "$.steps[12].keywordLocation" == "#/$ref"
jsonpath "$.steps[12].annotation" == null
jsonpath "$.steps[12].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[12].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

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

# With an instance that schema refuses, so the reference is demonstrably
# being evaluated rather than skipped
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer primary-secret-key
```
{
  "instance": {
    "token": 42
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
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
jsonpath "$.steps" count == 8
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
jsonpath "$.steps[1].keywordLocation" == "{{base}}/private/secret#/required"
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
jsonpath "$.steps[2].keywordLocation" == "{{base}}/private/secret#/required"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be an object that defines the property \"token\""
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].type" == "push"
jsonpath "$.steps[3].name" == "LogicalWhenType"
jsonpath "$.steps[3].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 4
jsonpath "$.steps[3].instancePositions[3]" == 3
jsonpath "$.steps[3].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == null
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[4].type" == "push"
jsonpath "$.steps[4].name" == "AssertionTypeStrict"
jsonpath "$.steps[4].evaluatePath" == "/$ref/properties/token/type"
jsonpath "$.steps[4].instanceLocation" == "/token"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 3
jsonpath "$.steps[4].instancePositions[1]" == 5
jsonpath "$.steps[4].instancePositions[2]" == 3
jsonpath "$.steps[4].instancePositions[3]" == 15
jsonpath "$.steps[4].keywordLocation" == "{{base}}/private/secret#/properties/token/type"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == null
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[5].type" == "fail"
jsonpath "$.steps[5].name" == "AssertionTypeStrict"
jsonpath "$.steps[5].evaluatePath" == "/$ref/properties/token/type"
jsonpath "$.steps[5].instanceLocation" == "/token"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 3
jsonpath "$.steps[5].instancePositions[1]" == 5
jsonpath "$.steps[5].instancePositions[2]" == 3
jsonpath "$.steps[5].instancePositions[3]" == 15
jsonpath "$.steps[5].keywordLocation" == "{{base}}/private/secret#/properties/token/type"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "The value was expected to be of type string but it was of type integer"
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[6].type" == "fail"
jsonpath "$.steps[6].name" == "LogicalWhenType"
jsonpath "$.steps[6].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].instancePositions[0]" == 2
jsonpath "$.steps[6].instancePositions[1]" == 3
jsonpath "$.steps[6].instancePositions[2]" == 4
jsonpath "$.steps[6].instancePositions[3]" == 3
jsonpath "$.steps[6].keywordLocation" == "{{base}}/private/secret#/properties"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[7].type" == "fail"
jsonpath "$.steps[7].name" == "ControlJump"
jsonpath "$.steps[7].evaluatePath" == "/$ref"
jsonpath "$.steps[7].instanceLocation" == ""
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[7].instancePositions[0]" == 2
jsonpath "$.steps[7].instancePositions[1]" == 3
jsonpath "$.steps[7].instancePositions[2]" == 4
jsonpath "$.steps[7].instancePositions[3]" == 3
jsonpath "$.steps[7].keywordLocation" == "#/$ref"
jsonpath "$.steps[7].annotation" == null
jsonpath "$.steps[7].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

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

# A credential for a different collection does not open this one
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer internal-secret-key
```
{
  "instance": {
    "token": "abc"
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
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
body not contains "token"
body not contains "additionalProperties"
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

# And the reverse, so neither key stands in for the other
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer primary-secret-key
```
{
  "instance": {},
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/internal/secret"
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

# A credential this instance does not know leaves the caller anonymous for
# the purposes of what a reference may reach, rather than refusing the request
# outright
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Authorization: Bearer not-a-real-key
```
{
  "instance": {
    "token": "abc"
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/private/secret"
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
body not contains "token"
body not contains "additionalProperties"
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

# A gated schema reached through a chain rather than named directly is
# refused at the hop that needs the credential
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": {
    "token": "abc"
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$defs": {
      "hop": {
        "$ref": "{{base}}/private/secret"
      }
    },
    "$ref": "#/$defs/hop"
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
body not contains "token"
body not contains "additionalProperties"
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
