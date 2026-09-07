# The pathless form carries the schema in the body rather than the URL, so a
# caller can trace against something this registry does not hold. What comes
# back is what the path form gives for a schema it does hold.
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": "hello world",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "string"
  }
}
HTTP 200
Cache-Control: no-store
Content-Type: application/json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
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
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].evaluatePath" == "/type"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 2
jsonpath "$.steps[0].instancePositions[3]" == 27
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].keywordLocation" == "#/type"
jsonpath "$.steps[0].name" == "AssertionTypeStrict"
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 27
jsonpath "$.steps[1].keywordLocation" == "#/type"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[1].message" == "The value was expected to be of type string"

# Every answer this endpoint gives is described by a schema this registry
# serves, so the answer validates against it
POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# An instance the schema refuses, so the verdict is false and the failing step
# says why
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": 42,
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "string"
  }
}
HTTP 200
[Asserts]
jsonpath "$.valid" == false
jsonpath "$.steps" count == 2
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[1].type" == "fail"
jsonpath "$.steps[1].message" == "The value was expected to be of type string but it was of type integer"

# A browser reaching this is told the same thing the path form tells it
OPTIONS {{base}}/self/v1/api/schemas/trace
HTTP 204
Cache-Control: no-store
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 3600
Allow: POST, OPTIONS

# A method this route does not serve
GET {{base}}/self/v1/api/schemas/trace
HTTP 405
Cache-Control: no-store
Content-Type: application/problem+json
Allow: POST, OPTIONS
[Asserts]
jsonpath "$.status" == 405
jsonpath "$.type" == "urn:sourcemeta:one:method-not-allowed"
jsonpath "$.title" == "Method Not Allowed"
jsonpath "$.detail" == "This HTTP method is invalid for this URL"

# The path form is untouched by the pathless one sharing its prefix
POST {{base}}/self/v1/api/schemas/trace/test/schemas/string
Content-Type: application/json
"Hello World"
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A body that is not the envelope this route accepts
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{ "instance": "hello world" }
HTTP 400
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Link: </self/v1/schemas/api/error>; rel="describedby"
[Asserts]
jsonpath "$.status" == 400
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.title" == "Bad Request"
jsonpath "$.detail" == "The request body does not match the expected schema"

# A boolean is a schema, but it declares no dialect, so this route does not
# take one
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{ "instance": "x", "schema": true }
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.detail" == "The request body does not match the expected schema"

# A schema that declares no dialect at all
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{ "instance": "x", "schema": { "type": "string" } }
HTTP 400
Cache-Control: no-store
Content-Type: application/problem+json
[Asserts]
jsonpath "$.status" == 400
jsonpath "$.type" == "urn:sourcemeta:one:invalid-schema"
jsonpath "$.title" == "Bad Request"
jsonpath "$.detail" == "The supplied schema could not be compiled"

# A dialect this instance does not know. A dialect is a reference like any
# other here, so naming one that resolves nowhere is answered as such
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{ "instance": "x", "schema": { "$schema": "https://example.com/not-a-dialect" } }
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"
jsonpath "$.detail" == "A reference in the supplied schema could not be resolved"

# A body that is not JSON at all
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
not json
```
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:invalid-json"
jsonpath "$.detail" == "The request body is not valid JSON"

# A reference to another origin entirely. This registry is sovereign over its
# own namespace and resolves nothing beyond it
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "https://example.org/elsewhere/schema"
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

# A reference into this instance that names nothing, which is answered exactly
# as the foreign one is
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/test/nothing/here"
  }
}
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"
jsonpath "$.detail" == "A reference in the supplied schema could not be resolved"

# A reference that tries to climb out of the schema tree
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/../../../etc/passwd"
  }
}
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:unresolvable-reference"

# A reference into this catalog resolves, and what it says decides the verdict
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": "hello",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/test/schemas/string"
  }
}
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true

# The same reference, with an instance it refuses
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": 42,
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/test/schemas/string"
  }
}
HTTP 200
[Asserts]
jsonpath "$.valid" == false

# An official metaschema resolves without being in this catalog, which is what
# lets a caller name a dialect at all
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": { "type": "string" },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "https://json-schema.org/draft/2020-12/schema"
  }
}
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# Nesting past the depth compilation may descend to
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
file,inline-too-deep.json;
HTTP 422
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Link: </self/v1/schemas/api/error>; rel="describedby"
[Asserts]
jsonpath "$.status" == 422
jsonpath "$.type" == "urn:sourcemeta:one:schema-too-complex"
jsonpath "$.title" == "Unprocessable Content"
jsonpath "$.detail" == "The supplied schema is too complex to compile"

# More frame locations than framing may register, which a schema reaches in
# far fewer bytes than it takes to reach the body cap
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
file,inline-too-many-locations.json;
HTTP 422
[Asserts]
jsonpath "$.status" == 422
jsonpath "$.type" == "urn:sourcemeta:one:schema-too-complex"
jsonpath "$.detail" == "The supplied schema is too complex to compile"

# A body beyond what this route reads, which is a smaller cap than the one the
# path form applies
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
file,inline-oversized.json;
HTTP 413
Cache-Control: no-store
Content-Type: application/problem+json
[Asserts]
jsonpath "$.status" == 413
jsonpath "$.type" == "urn:sourcemeta:one:payload-too-large"
jsonpath "$.title" == "Content Too Large"
jsonpath "$.detail" == "The request body is too large"

# A schema written against an older dialect, which this resolves from its
# built-in official schemas rather than from the catalog
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "http://json-schema.org/draft-07/schema#",
    "type": "string"
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true
jsonpath "$.steps" count == 2
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "AssertionTypeStrict"
jsonpath "$.steps[0].evaluatePath" == "/type"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].keywordLocation" == "#/type"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].keywordLocation" == "#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == "The value was expected to be of type string"
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].instancePositions" count == 4

# A schema that annotates as well as asserts, so the trace carries the
# annotation alongside the verdict
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "title": "T",
    "type": "string"
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true
jsonpath "$.steps" count == 3
jsonpath "$.steps[0].type" == "pass"
jsonpath "$.steps[0].name" == "AnnotationEmit"
jsonpath "$.steps[0].evaluatePath" == "/title"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].keywordLocation" == "#/title"
jsonpath "$.steps[0].annotation" == "T"
jsonpath "$.steps[0].message" == "The title of the instance was \"T\""
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].keywordLocation" == "#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].keywordLocation" == "#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be of type string"
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[2].instancePositions" count == 4

# A reference resolved within the supplied schema itself, which needs no
# catalog lookup at all
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "#/$defs/s",
    "$defs": {
      "s": {
        "type": "string"
      }
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true
jsonpath "$.steps" count == 4
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/$ref/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].keywordLocation" == "#/$defs/s/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/$ref/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].keywordLocation" == "#/$defs/s/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be of type string"
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "ControlJump"
jsonpath "$.steps[3].evaluatePath" == "/$ref"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].keywordLocation" == "#/$ref"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[3].instancePositions" count == 4

# A reference into the catalog that itself references another catalog schema.
# Resolution follows the chain, and every hop is subject to the same gate
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": {
    "foo": 1
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/test/bundling/single"
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true
jsonpath "$.steps" count == 8
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "LogicalWhenType"
jsonpath "$.steps[1].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/bundling/single#/properties"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "ControlJump"
jsonpath "$.steps[2].evaluatePath" == "/$ref/properties/foo/$ref"
jsonpath "$.steps[2].instanceLocation" == "/foo"
jsonpath "$.steps[2].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[3].type" == "push"
jsonpath "$.steps[3].name" == "AssertionType"
jsonpath "$.steps[3].evaluatePath" == "/$ref/properties/foo/$ref/type"
jsonpath "$.steps[3].instanceLocation" == "/foo"
jsonpath "$.steps[3].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == null
jsonpath "$.steps[3].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "AssertionType"
jsonpath "$.steps[4].evaluatePath" == "/$ref/properties/foo/$ref/type"
jsonpath "$.steps[4].instanceLocation" == "/foo"
jsonpath "$.steps[4].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The value was expected to be of type integer"
jsonpath "$.steps[4].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "ControlJump"
jsonpath "$.steps[5].evaluatePath" == "/$ref/properties/foo/$ref"
jsonpath "$.steps[5].instanceLocation" == "/foo"
jsonpath "$.steps[5].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "The integer value was expected to validate against the referenced schema"
jsonpath "$.steps[5].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[6].type" == "pass"
jsonpath "$.steps[6].name" == "LogicalWhenType"
jsonpath "$.steps[6].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].keywordLocation" == "{{base}}/test/bundling/single#/properties"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == "The object value was expected to validate against the single defined property subschema"
jsonpath "$.steps[6].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[7].type" == "pass"
jsonpath "$.steps[7].name" == "ControlJump"
jsonpath "$.steps[7].evaluatePath" == "/$ref"
jsonpath "$.steps[7].instanceLocation" == ""
jsonpath "$.steps[7].keywordLocation" == "#/$ref"
jsonpath "$.steps[7].annotation" == null
jsonpath "$.steps[7].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[7].instancePositions" count == 4

# A reference into the catalog that points at a subschema rather than a whole
# schema
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/test/bundling/single#/properties/foo"
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == false
jsonpath "$.steps" count == 6
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "ControlJump"
jsonpath "$.steps[1].evaluatePath" == "/$ref/$ref"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "AssertionType"
jsonpath "$.steps[2].evaluatePath" == "/$ref/$ref/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[3].type" == "fail"
jsonpath "$.steps[3].name" == "AssertionType"
jsonpath "$.steps[3].evaluatePath" == "/$ref/$ref/type"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The value was expected to be of type integer but it was of type string"
jsonpath "$.steps[3].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[4].type" == "fail"
jsonpath "$.steps[4].name" == "ControlJump"
jsonpath "$.steps[4].evaluatePath" == "/$ref/$ref"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[4].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[5].type" == "fail"
jsonpath "$.steps[5].name" == "ControlJump"
jsonpath "$.steps[5].evaluatePath" == "/$ref"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].keywordLocation" == "#/$ref"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[5].instancePositions" count == 4

# A reference to one of this instance's own schemas, which are catalog content
# like any other
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": {
    "valid": true,
    "steps": []
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/self/v1/schemas/api/schemas/trace/response"
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true
jsonpath "$.steps" count == 19
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].name" == "AnnotationEmit"
jsonpath "$.steps[1].evaluatePath" == "/$ref/description"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/description"
jsonpath "$.steps[1].annotation" == "The response format for the schema trace API endpoint"
jsonpath "$.steps[1].message" == "The description of the instance was \"The response format for the schema trace API endpoint\""
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AnnotationEmit"
jsonpath "$.steps[2].evaluatePath" == "/$ref/examples"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/examples"
jsonpath "$.steps[2].annotation" exists
jsonpath "$.steps[2].message" == "Examples of the instance were and {\"valid\":true,\"steps\":[]}"
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[3].type" == "push"
jsonpath "$.steps[3].name" == "AssertionDefinesExactly"
jsonpath "$.steps[3].evaluatePath" == "/$ref/required"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/required"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == null
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "AssertionDefinesExactly"
jsonpath "$.steps[4].evaluatePath" == "/$ref/required"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/required"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The object value was expected to only define properties \"steps\", and \"valid\""
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "AnnotationEmit"
jsonpath "$.steps[5].evaluatePath" == "/$ref/title"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/title"
jsonpath "$.steps[5].annotation" == "Sourcemeta One Schema Trace API Response"
jsonpath "$.steps[5].message" == "The title of the instance was \"Sourcemeta One Schema Trace API Response\""
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[6].type" == "push"
jsonpath "$.steps[6].name" == "LogicalWhenType"
jsonpath "$.steps[6].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == null
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[7].type" == "push"
jsonpath "$.steps[7].name" == "AssertionTypeStrict"
jsonpath "$.steps[7].evaluatePath" == "/$ref/properties/valid/type"
jsonpath "$.steps[7].instanceLocation" == "/valid"
jsonpath "$.steps[7].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties/valid/type"
jsonpath "$.steps[7].annotation" == null
jsonpath "$.steps[7].message" == null
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[8].type" == "pass"
jsonpath "$.steps[8].name" == "AssertionTypeStrict"
jsonpath "$.steps[8].evaluatePath" == "/$ref/properties/valid/type"
jsonpath "$.steps[8].instanceLocation" == "/valid"
jsonpath "$.steps[8].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties/valid/type"
jsonpath "$.steps[8].annotation" == null
jsonpath "$.steps[8].message" == "The value was expected to be of type boolean"
jsonpath "$.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[8].instancePositions" count == 4
jsonpath "$.steps[9].type" == "pass"
jsonpath "$.steps[9].name" == "AnnotationEmitWrapped"
jsonpath "$.steps[9].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[9].instanceLocation" == ""
jsonpath "$.steps[9].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties"
jsonpath "$.steps[9].annotation" == "valid"
jsonpath "$.steps[9].message" == "The object property \"valid\" successfully validated against its property subschema"
jsonpath "$.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[9].instancePositions" count == 4
jsonpath "$.steps[10].type" == "push"
jsonpath "$.steps[10].name" == "AssertionTypeStrict"
jsonpath "$.steps[10].evaluatePath" == "/$ref/properties/steps/type"
jsonpath "$.steps[10].instanceLocation" == "/steps"
jsonpath "$.steps[10].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties/steps/type"
jsonpath "$.steps[10].annotation" == null
jsonpath "$.steps[10].message" == null
jsonpath "$.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[10].instancePositions" count == 4
jsonpath "$.steps[11].type" == "pass"
jsonpath "$.steps[11].name" == "AssertionTypeStrict"
jsonpath "$.steps[11].evaluatePath" == "/$ref/properties/steps/type"
jsonpath "$.steps[11].instanceLocation" == "/steps"
jsonpath "$.steps[11].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties/steps/type"
jsonpath "$.steps[11].annotation" == null
jsonpath "$.steps[11].message" == "The value was expected to be of type array"
jsonpath "$.steps[11].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[11].instancePositions" count == 4
jsonpath "$.steps[12].type" == "pass"
jsonpath "$.steps[12].name" == "AnnotationEmitWrapped"
jsonpath "$.steps[12].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[12].instanceLocation" == ""
jsonpath "$.steps[12].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties"
jsonpath "$.steps[12].annotation" == "steps"
jsonpath "$.steps[12].message" == "The object property \"steps\" successfully validated against its property subschema"
jsonpath "$.steps[12].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[12].instancePositions" count == 4
jsonpath "$.steps[13].type" == "pass"
jsonpath "$.steps[13].name" == "LogicalWhenType"
jsonpath "$.steps[13].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[13].instanceLocation" == ""
jsonpath "$.steps[13].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties"
jsonpath "$.steps[13].annotation" == null
jsonpath "$.steps[13].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[13].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[13].instancePositions" count == 4
jsonpath "$.steps[14].type" == "push"
jsonpath "$.steps[14].name" == "LoopPropertiesExcept"
jsonpath "$.steps[14].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.steps[14].instanceLocation" == ""
jsonpath "$.steps[14].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/additionalProperties"
jsonpath "$.steps[14].annotation" == null
jsonpath "$.steps[14].message" == null
jsonpath "$.steps[14].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[14].instancePositions" count == 4
jsonpath "$.steps[15].type" == "pass"
jsonpath "$.steps[15].name" == "LoopPropertiesExcept"
jsonpath "$.steps[15].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.steps[15].instanceLocation" == ""
jsonpath "$.steps[15].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/additionalProperties"
jsonpath "$.steps[15].annotation" == null
jsonpath "$.steps[15].message" == "The object value was not expected to define additional properties"
jsonpath "$.steps[15].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[15].instancePositions" count == 4
jsonpath "$.steps[16].type" == "push"
jsonpath "$.steps[16].name" == "AssertionTypeStrict"
jsonpath "$.steps[16].evaluatePath" == "/$ref/type"
jsonpath "$.steps[16].instanceLocation" == ""
jsonpath "$.steps[16].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/type"
jsonpath "$.steps[16].annotation" == null
jsonpath "$.steps[16].message" == null
jsonpath "$.steps[16].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[16].instancePositions" count == 4
jsonpath "$.steps[17].type" == "pass"
jsonpath "$.steps[17].name" == "AssertionTypeStrict"
jsonpath "$.steps[17].evaluatePath" == "/$ref/type"
jsonpath "$.steps[17].instanceLocation" == ""
jsonpath "$.steps[17].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/type"
jsonpath "$.steps[17].annotation" == null
jsonpath "$.steps[17].message" == "The value was expected to be of type object"
jsonpath "$.steps[17].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[17].instancePositions" count == 4
jsonpath "$.steps[18].type" == "pass"
jsonpath "$.steps[18].name" == "ControlJump"
jsonpath "$.steps[18].evaluatePath" == "/$ref"
jsonpath "$.steps[18].instanceLocation" == ""
jsonpath "$.steps[18].keywordLocation" == "#/$ref"
jsonpath "$.steps[18].annotation" == null
jsonpath "$.steps[18].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[18].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[18].instancePositions" count == 4

# Dynamic references, which resolve against the supplied schema's own scope
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": [
    "x"
  ],
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$id": "https://example.com/d",
    "$defs": {
      "i": {
        "$dynamicAnchor": "T",
        "type": "string"
      }
    },
    "type": "array",
    "items": {
      "$dynamicRef": "#T"
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true
jsonpath "$.steps" count == 11
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "LoopItemsFrom"
jsonpath "$.steps[0].evaluatePath" == "/items"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "ControlJump"
jsonpath "$.steps[1].evaluatePath" == "/items/$dynamicRef"
jsonpath "$.steps[1].instanceLocation" == "/0"
jsonpath "$.steps[1].keywordLocation" == "https://example.com/d#/items/$dynamicRef"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/items/$dynamicRef/type"
jsonpath "$.steps[2].instanceLocation" == "/0"
jsonpath "$.steps[2].keywordLocation" == "https://example.com/d#/$defs/i/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AssertionTypeStrict"
jsonpath "$.steps[3].evaluatePath" == "/items/$dynamicRef/type"
jsonpath "$.steps[3].instanceLocation" == "/0"
jsonpath "$.steps[3].keywordLocation" == "https://example.com/d#/$defs/i/type"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The value was expected to be of type string"
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "ControlJump"
jsonpath "$.steps[4].evaluatePath" == "/items/$dynamicRef"
jsonpath "$.steps[4].instanceLocation" == "/0"
jsonpath "$.steps[4].keywordLocation" == "https://example.com/d#/items/$dynamicRef"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "LoopItemsFrom"
jsonpath "$.steps[5].evaluatePath" == "/items"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "Every item in the array value was expected to validate against the given subschema"
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[6].type" == "push"
jsonpath "$.steps[6].name" == "LogicalWhenArraySizeGreater"
jsonpath "$.steps[6].evaluatePath" == "/items"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == null
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[7].type" == "pass"
jsonpath "$.steps[7].name" == "AnnotationEmit"
jsonpath "$.steps[7].evaluatePath" == "/items"
jsonpath "$.steps[7].instanceLocation" == ""
jsonpath "$.steps[7].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[7].annotation" == true
jsonpath "$.steps[7].message" == "Every item in the array value was successfully validated"
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[8].type" == "pass"
jsonpath "$.steps[8].name" == "LogicalWhenArraySizeGreater"
jsonpath "$.steps[8].evaluatePath" == "/items"
jsonpath "$.steps[8].instanceLocation" == ""
jsonpath "$.steps[8].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[8].annotation" == null
jsonpath "$.steps[8].message" == "The array value contains 1 additional item not described by related keywords"
jsonpath "$.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[8].instancePositions" count == 4
jsonpath "$.steps[9].type" == "push"
jsonpath "$.steps[9].name" == "AssertionTypeStrict"
jsonpath "$.steps[9].evaluatePath" == "/type"
jsonpath "$.steps[9].instanceLocation" == ""
jsonpath "$.steps[9].keywordLocation" == "https://example.com/d#/type"
jsonpath "$.steps[9].annotation" == null
jsonpath "$.steps[9].message" == null
jsonpath "$.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[9].instancePositions" count == 4
jsonpath "$.steps[10].type" == "pass"
jsonpath "$.steps[10].name" == "AssertionTypeStrict"
jsonpath "$.steps[10].evaluatePath" == "/type"
jsonpath "$.steps[10].instanceLocation" == ""
jsonpath "$.steps[10].keywordLocation" == "https://example.com/d#/type"
jsonpath "$.steps[10].annotation" == null
jsonpath "$.steps[10].message" == "The value was expected to be of type array"
jsonpath "$.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[10].instancePositions" count == 4

# An object instance, so the trace locates steps inside it rather than at its
# root
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": {
    "a": 1
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "object",
    "properties": {
      "a": {
        "type": "integer"
      }
    }
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true
jsonpath "$.steps" count == 7
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "LogicalWhenType"
jsonpath "$.steps[0].evaluatePath" == "/properties"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].keywordLocation" == "#/properties"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "AssertionType"
jsonpath "$.steps[1].evaluatePath" == "/properties/a/type"
jsonpath "$.steps[1].instanceLocation" == "/a"
jsonpath "$.steps[1].keywordLocation" == "#/properties/a/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AssertionType"
jsonpath "$.steps[2].evaluatePath" == "/properties/a/type"
jsonpath "$.steps[2].instanceLocation" == "/a"
jsonpath "$.steps[2].keywordLocation" == "#/properties/a/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be of type integer"
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AnnotationEmitWrapped"
jsonpath "$.steps[3].evaluatePath" == "/properties"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].keywordLocation" == "#/properties"
jsonpath "$.steps[3].annotation" == "a"
jsonpath "$.steps[3].message" == "The object property \"a\" successfully validated against its property subschema"
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "LogicalWhenType"
jsonpath "$.steps[4].evaluatePath" == "/properties"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].keywordLocation" == "#/properties"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The object value was expected to validate against the single defined property subschema"
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[5].type" == "push"
jsonpath "$.steps[5].name" == "AssertionTypeStrict"
jsonpath "$.steps[5].evaluatePath" == "/type"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].keywordLocation" == "#/type"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == null
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[6].type" == "pass"
jsonpath "$.steps[6].name" == "AssertionTypeStrict"
jsonpath "$.steps[6].evaluatePath" == "/type"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].keywordLocation" == "#/type"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == "The value was expected to be of type object"
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[6].instancePositions" count == 4

# A null instance, which is a value like any other
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": null,
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": "null"
  }
}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/trace/response>; rel="describedby"
[Asserts]
jsonpath "$.valid" == true
jsonpath "$.steps" count == 2
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "AssertionTypeStrict"
jsonpath "$.steps[0].evaluatePath" == "/type"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].keywordLocation" == "#/type"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].keywordLocation" == "#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == "The value was expected to be of type null"
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[1].instancePositions" count == 4

# The pathless form is the bare path, so a trailing slash is a different URL
# and this instance holds nothing there
POST {{base}}/self/v1/api/schemas/trace/
Content-Type: application/json
{ "instance": "x", "schema": { "$schema": "https://json-schema.org/draft/2020-12/schema" } }
HTTP 404
Cache-Control: no-store
Content-Type: application/problem+json
[Asserts]
jsonpath "$.status" == 404
jsonpath "$.type" == "urn:sourcemeta:one:not-found"
jsonpath "$.title" == "Not Found"
jsonpath "$.detail" == "There is nothing at this URL"

# No body at all
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
HTTP 400
Cache-Control: no-store
Content-Type: application/problem+json
[Asserts]
jsonpath "$.status" == 400
jsonpath "$.type" == "urn:sourcemeta:one:no-instance"
jsonpath "$.title" == "Bad Request"
jsonpath "$.detail" == "You must pass an instance to validate against"

# A body that is JSON but not an object
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
[ 1, 2 ]
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.detail" == "The request body does not match the expected schema"

# An envelope carrying something this route does not accept
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
{
  "instance": "x",
  "schema": { "$schema": "https://json-schema.org/draft/2020-12/schema" },
  "extra": 1
}
HTTP 400
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.detail" == "The request body does not match the expected schema"

# An expectation this instance cannot honour, refused before the body is read
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
Expect: something-else
{ "instance": "x", "schema": { "$schema": "https://json-schema.org/draft/2020-12/schema" } }
HTTP 417
Cache-Control: no-store
Content-Type: application/problem+json
[Asserts]
jsonpath "$.status" == 417
jsonpath "$.type" == "urn:sourcemeta:one:expectation-failed"
jsonpath "$.title" == "Expectation Failed"
jsonpath "$.detail" == "The Expect header carries an unsupported expectation"

# A preflight naming an origin is answered the same way, since this route is
# open to any origin
OPTIONS {{base}}/self/v1/api/schemas/trace
Origin: https://example.com
HTTP 204
Cache-Control: no-store
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 3600
Allow: POST, OPTIONS
[Asserts]
header "Vary" not exists

# Methods this route does not serve, each told so with the same Allow
PUT {{base}}/self/v1/api/schemas/trace
HTTP 405
Allow: POST, OPTIONS
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:method-not-allowed"

DELETE {{base}}/self/v1/api/schemas/trace
HTTP 405
Allow: POST, OPTIONS
[Asserts]
jsonpath "$.type" == "urn:sourcemeta:one:method-not-allowed"
