# A playground schema is one the caller supplies in the request rather than one
# this catalog holds, so a caller can trace against something that was never
# indexed here. What comes back is what tracing a catalog schema gives.
#
# Everything under the playground namespace compiles what a request carries, so
# what it may cost is bounded, and what its references may reach is decided per
# reference against whoever is asking.

# A schema of the caller's own, against an instance it accepts
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "hello world",
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
jsonpath "$.steps[0].instancePositions[3]" == 27
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
jsonpath "$.steps[1].instancePositions[3]" == 27
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

# The same schema against an instance it refuses
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": 42,
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
jsonpath "$.valid" == false
jsonpath "$.steps" count == 2
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "AssertionTypeStrict"
jsonpath "$.steps[0].evaluatePath" == "/type"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 2
jsonpath "$.steps[0].instancePositions[3]" == 16
jsonpath "$.steps[0].keywordLocation" == "#/type"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[1].type" == "fail"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 16
jsonpath "$.steps[1].keywordLocation" == "#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == "The value was expected to be of type string but it was of type integer"
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

# A schema written against an older dialect, resolved from the built-in
# official schemas rather than from the catalog
POST {{base}}/self/v1/api/playground/schemas/trace
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
jsonpath "$.steps[0].instancePositions[3]" == 17
jsonpath "$.steps[0].keywordLocation" == "#/type"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 17
jsonpath "$.steps[1].keywordLocation" == "#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == "The value was expected to be of type string"
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"

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

# A schema that annotates as well as asserts, so the trace carries the
# annotation alongside the verdict
POST {{base}}/self/v1/api/playground/schemas/trace
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
jsonpath "$.steps" count == 3
jsonpath "$.steps[0].type" == "pass"
jsonpath "$.steps[0].name" == "AnnotationEmit"
jsonpath "$.steps[0].evaluatePath" == "/title"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 2
jsonpath "$.steps[0].instancePositions[3]" == 17
jsonpath "$.steps[0].keywordLocation" == "#/title"
jsonpath "$.steps[0].annotation" == "T"
jsonpath "$.steps[0].message" == "The title of the instance was \"T\""
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 17
jsonpath "$.steps[1].keywordLocation" == "#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 2
jsonpath "$.steps[2].instancePositions[3]" == 17
jsonpath "$.steps[2].keywordLocation" == "#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be of type string"
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"

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

# A reference resolved within the supplied schema itself, needing no
# catalog lookup at all
POST {{base}}/self/v1/api/playground/schemas/trace
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
jsonpath "$.steps[0].instancePositions[3]" == 17
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
jsonpath "$.steps[1].instancePositions[3]" == 17
jsonpath "$.steps[1].keywordLocation" == "#/$defs/s/type"
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
jsonpath "$.steps[2].instancePositions[3]" == 17
jsonpath "$.steps[2].keywordLocation" == "#/$defs/s/type"
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
jsonpath "$.steps[3].instancePositions[3]" == 17
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

# A reference into the catalog, which decides the verdict
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "hello",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/test/schemas/string"
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
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/schemas/string#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/$ref/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 2
jsonpath "$.steps[2].instancePositions[3]" == 21
jsonpath "$.steps[2].keywordLocation" == "{{base}}/test/schemas/string#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be of type string"
jsonpath "$.steps[2].vocabulary" == "http://json-schema.org/draft-07/schema#"
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

# The same reference against an instance it refuses
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": 42,
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/test/schemas/string"
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
jsonpath "$.steps" count == 4
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
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/$ref/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 16
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/schemas/string#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[2].type" == "fail"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/$ref/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 2
jsonpath "$.steps[2].instancePositions[3]" == 16
jsonpath "$.steps[2].keywordLocation" == "{{base}}/test/schemas/string#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be of type string but it was of type integer"
jsonpath "$.steps[2].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[3].type" == "fail"
jsonpath "$.steps[3].name" == "ControlJump"
jsonpath "$.steps[3].evaluatePath" == "/$ref"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 2
jsonpath "$.steps[3].instancePositions[3]" == 16
jsonpath "$.steps[3].keywordLocation" == "#/$ref"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The integer value was expected to validate against the referenced schema"
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

# A reference into the catalog that itself references another catalog
# schema, so resolution follows the chain
POST {{base}}/self/v1/api/playground/schemas/trace
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
jsonpath "$.steps[1].name" == "LogicalWhenType"
jsonpath "$.steps[1].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 4
jsonpath "$.steps[1].instancePositions[3]" == 3
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/bundling/single#/properties"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "ControlJump"
jsonpath "$.steps[2].evaluatePath" == "/$ref/properties/foo/$ref"
jsonpath "$.steps[2].instanceLocation" == "/foo"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 3
jsonpath "$.steps[2].instancePositions[1]" == 5
jsonpath "$.steps[2].instancePositions[2]" == 3
jsonpath "$.steps[2].instancePositions[3]" == 12
jsonpath "$.steps[2].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[3].type" == "push"
jsonpath "$.steps[3].name" == "AssertionType"
jsonpath "$.steps[3].evaluatePath" == "/$ref/properties/foo/$ref/type"
jsonpath "$.steps[3].instanceLocation" == "/foo"
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 3
jsonpath "$.steps[3].instancePositions[1]" == 5
jsonpath "$.steps[3].instancePositions[2]" == 3
jsonpath "$.steps[3].instancePositions[3]" == 12
jsonpath "$.steps[3].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == null
jsonpath "$.steps[3].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "AssertionType"
jsonpath "$.steps[4].evaluatePath" == "/$ref/properties/foo/$ref/type"
jsonpath "$.steps[4].instanceLocation" == "/foo"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 3
jsonpath "$.steps[4].instancePositions[1]" == 5
jsonpath "$.steps[4].instancePositions[2]" == 3
jsonpath "$.steps[4].instancePositions[3]" == 12
jsonpath "$.steps[4].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The value was expected to be of type integer"
jsonpath "$.steps[4].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "ControlJump"
jsonpath "$.steps[5].evaluatePath" == "/$ref/properties/foo/$ref"
jsonpath "$.steps[5].instanceLocation" == "/foo"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 3
jsonpath "$.steps[5].instancePositions[1]" == 5
jsonpath "$.steps[5].instancePositions[2]" == 3
jsonpath "$.steps[5].instancePositions[3]" == 12
jsonpath "$.steps[5].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "The integer value was expected to validate against the referenced schema"
jsonpath "$.steps[5].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[6].type" == "pass"
jsonpath "$.steps[6].name" == "LogicalWhenType"
jsonpath "$.steps[6].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].instancePositions[0]" == 2
jsonpath "$.steps[6].instancePositions[1]" == 3
jsonpath "$.steps[6].instancePositions[2]" == 4
jsonpath "$.steps[6].instancePositions[3]" == 3
jsonpath "$.steps[6].keywordLocation" == "{{base}}/test/bundling/single#/properties"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == "The object value was expected to validate against the single defined property subschema"
jsonpath "$.steps[6].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[7].type" == "pass"
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

# A reference into the catalog that points at a subschema rather than a
# whole schema
POST {{base}}/self/v1/api/playground/schemas/trace
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
jsonpath "$.steps" count == 6
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 2
jsonpath "$.steps[0].instancePositions[3]" == 17
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "ControlJump"
jsonpath "$.steps[1].evaluatePath" == "/$ref/$ref"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 2
jsonpath "$.steps[1].instancePositions[3]" == 17
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "AssertionType"
jsonpath "$.steps[2].evaluatePath" == "/$ref/$ref/type"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 2
jsonpath "$.steps[2].instancePositions[3]" == 17
jsonpath "$.steps[2].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[3].type" == "fail"
jsonpath "$.steps[3].name" == "AssertionType"
jsonpath "$.steps[3].evaluatePath" == "/$ref/$ref/type"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 2
jsonpath "$.steps[3].instancePositions[3]" == 17
jsonpath "$.steps[3].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The value was expected to be of type integer but it was of type string"
jsonpath "$.steps[3].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[4].type" == "fail"
jsonpath "$.steps[4].name" == "ControlJump"
jsonpath "$.steps[4].evaluatePath" == "/$ref/$ref"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 2
jsonpath "$.steps[4].instancePositions[1]" == 3
jsonpath "$.steps[4].instancePositions[2]" == 2
jsonpath "$.steps[4].instancePositions[3]" == 17
jsonpath "$.steps[4].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[4].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[5].type" == "fail"
jsonpath "$.steps[5].name" == "ControlJump"
jsonpath "$.steps[5].evaluatePath" == "/$ref"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 2
jsonpath "$.steps[5].instancePositions[1]" == 3
jsonpath "$.steps[5].instancePositions[2]" == 2
jsonpath "$.steps[5].instancePositions[3]" == 17
jsonpath "$.steps[5].keywordLocation" == "#/$ref"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

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

# A reference to one of this instance's own schemas, which are catalog
# content like any other
POST {{base}}/self/v1/api/playground/schemas/trace
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
jsonpath "$.steps" count == 19
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "ControlJump"
jsonpath "$.steps[0].evaluatePath" == "/$ref"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 5
jsonpath "$.steps[0].instancePositions[3]" == 3
jsonpath "$.steps[0].keywordLocation" == "#/$ref"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].name" == "AnnotationEmit"
jsonpath "$.steps[1].evaluatePath" == "/$ref/description"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 5
jsonpath "$.steps[1].instancePositions[3]" == 3
jsonpath "$.steps[1].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/description"
jsonpath "$.steps[1].annotation" == "The response format for the schema trace API endpoint"
jsonpath "$.steps[1].message" == "The description of the instance was \"The response format for the schema trace API endpoint\""
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AnnotationEmit"
jsonpath "$.steps[2].evaluatePath" == "/$ref/examples"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 5
jsonpath "$.steps[2].instancePositions[3]" == 3
jsonpath "$.steps[2].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/examples"
jsonpath "$.steps[2].annotation" count == 1
jsonpath "$.steps[2].annotation[0].valid" == true
jsonpath "$.steps[2].annotation[0].steps" count == 0
jsonpath "$.steps[2].message" == "Examples of the instance were and {\"valid\":true,\"steps\":[]}"
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[3].type" == "push"
jsonpath "$.steps[3].name" == "AssertionDefinesExactly"
jsonpath "$.steps[3].evaluatePath" == "/$ref/required"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 5
jsonpath "$.steps[3].instancePositions[3]" == 3
jsonpath "$.steps[3].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/required"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == null
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "AssertionDefinesExactly"
jsonpath "$.steps[4].evaluatePath" == "/$ref/required"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 2
jsonpath "$.steps[4].instancePositions[1]" == 3
jsonpath "$.steps[4].instancePositions[2]" == 5
jsonpath "$.steps[4].instancePositions[3]" == 3
jsonpath "$.steps[4].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/required"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The object value was expected to only define properties \"steps\", and \"valid\""
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "AnnotationEmit"
jsonpath "$.steps[5].evaluatePath" == "/$ref/title"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 2
jsonpath "$.steps[5].instancePositions[1]" == 3
jsonpath "$.steps[5].instancePositions[2]" == 5
jsonpath "$.steps[5].instancePositions[3]" == 3
jsonpath "$.steps[5].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/title"
jsonpath "$.steps[5].annotation" == "Sourcemeta One Schema Trace API Response"
jsonpath "$.steps[5].message" == "The title of the instance was \"Sourcemeta One Schema Trace API Response\""
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[6].type" == "push"
jsonpath "$.steps[6].name" == "LogicalWhenType"
jsonpath "$.steps[6].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].instancePositions[0]" == 2
jsonpath "$.steps[6].instancePositions[1]" == 3
jsonpath "$.steps[6].instancePositions[2]" == 5
jsonpath "$.steps[6].instancePositions[3]" == 3
jsonpath "$.steps[6].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == null
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[7].type" == "push"
jsonpath "$.steps[7].name" == "AssertionTypeStrict"
jsonpath "$.steps[7].evaluatePath" == "/$ref/properties/valid/type"
jsonpath "$.steps[7].instanceLocation" == "/valid"
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[7].instancePositions[0]" == 3
jsonpath "$.steps[7].instancePositions[1]" == 5
jsonpath "$.steps[7].instancePositions[2]" == 3
jsonpath "$.steps[7].instancePositions[3]" == 17
jsonpath "$.steps[7].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties/valid/type"
jsonpath "$.steps[7].annotation" == null
jsonpath "$.steps[7].message" == null
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[8].type" == "pass"
jsonpath "$.steps[8].name" == "AssertionTypeStrict"
jsonpath "$.steps[8].evaluatePath" == "/$ref/properties/valid/type"
jsonpath "$.steps[8].instanceLocation" == "/valid"
jsonpath "$.steps[8].instancePositions" count == 4
jsonpath "$.steps[8].instancePositions[0]" == 3
jsonpath "$.steps[8].instancePositions[1]" == 5
jsonpath "$.steps[8].instancePositions[2]" == 3
jsonpath "$.steps[8].instancePositions[3]" == 17
jsonpath "$.steps[8].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties/valid/type"
jsonpath "$.steps[8].annotation" == null
jsonpath "$.steps[8].message" == "The value was expected to be of type boolean"
jsonpath "$.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[9].type" == "pass"
jsonpath "$.steps[9].name" == "AnnotationEmitWrapped"
jsonpath "$.steps[9].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[9].instanceLocation" == ""
jsonpath "$.steps[9].instancePositions" count == 4
jsonpath "$.steps[9].instancePositions[0]" == 2
jsonpath "$.steps[9].instancePositions[1]" == 3
jsonpath "$.steps[9].instancePositions[2]" == 5
jsonpath "$.steps[9].instancePositions[3]" == 3
jsonpath "$.steps[9].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties"
jsonpath "$.steps[9].annotation" == "valid"
jsonpath "$.steps[9].message" == "The object property \"valid\" successfully validated against its property subschema"
jsonpath "$.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[10].type" == "push"
jsonpath "$.steps[10].name" == "AssertionTypeStrict"
jsonpath "$.steps[10].evaluatePath" == "/$ref/properties/steps/type"
jsonpath "$.steps[10].instanceLocation" == "/steps"
jsonpath "$.steps[10].instancePositions" count == 4
jsonpath "$.steps[10].instancePositions[0]" == 4
jsonpath "$.steps[10].instancePositions[1]" == 5
jsonpath "$.steps[10].instancePositions[2]" == 4
jsonpath "$.steps[10].instancePositions[3]" == 15
jsonpath "$.steps[10].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties/steps/type"
jsonpath "$.steps[10].annotation" == null
jsonpath "$.steps[10].message" == null
jsonpath "$.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[11].type" == "pass"
jsonpath "$.steps[11].name" == "AssertionTypeStrict"
jsonpath "$.steps[11].evaluatePath" == "/$ref/properties/steps/type"
jsonpath "$.steps[11].instanceLocation" == "/steps"
jsonpath "$.steps[11].instancePositions" count == 4
jsonpath "$.steps[11].instancePositions[0]" == 4
jsonpath "$.steps[11].instancePositions[1]" == 5
jsonpath "$.steps[11].instancePositions[2]" == 4
jsonpath "$.steps[11].instancePositions[3]" == 15
jsonpath "$.steps[11].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties/steps/type"
jsonpath "$.steps[11].annotation" == null
jsonpath "$.steps[11].message" == "The value was expected to be of type array"
jsonpath "$.steps[11].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[12].type" == "pass"
jsonpath "$.steps[12].name" == "AnnotationEmitWrapped"
jsonpath "$.steps[12].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[12].instanceLocation" == ""
jsonpath "$.steps[12].instancePositions" count == 4
jsonpath "$.steps[12].instancePositions[0]" == 2
jsonpath "$.steps[12].instancePositions[1]" == 3
jsonpath "$.steps[12].instancePositions[2]" == 5
jsonpath "$.steps[12].instancePositions[3]" == 3
jsonpath "$.steps[12].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties"
jsonpath "$.steps[12].annotation" == "steps"
jsonpath "$.steps[12].message" == "The object property \"steps\" successfully validated against its property subschema"
jsonpath "$.steps[12].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[13].type" == "pass"
jsonpath "$.steps[13].name" == "LogicalWhenType"
jsonpath "$.steps[13].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[13].instanceLocation" == ""
jsonpath "$.steps[13].instancePositions" count == 4
jsonpath "$.steps[13].instancePositions[0]" == 2
jsonpath "$.steps[13].instancePositions[1]" == 3
jsonpath "$.steps[13].instancePositions[2]" == 5
jsonpath "$.steps[13].instancePositions[3]" == 3
jsonpath "$.steps[13].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/properties"
jsonpath "$.steps[13].annotation" == null
jsonpath "$.steps[13].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[13].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[14].type" == "push"
jsonpath "$.steps[14].name" == "LoopPropertiesExcept"
jsonpath "$.steps[14].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.steps[14].instanceLocation" == ""
jsonpath "$.steps[14].instancePositions" count == 4
jsonpath "$.steps[14].instancePositions[0]" == 2
jsonpath "$.steps[14].instancePositions[1]" == 3
jsonpath "$.steps[14].instancePositions[2]" == 5
jsonpath "$.steps[14].instancePositions[3]" == 3
jsonpath "$.steps[14].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/additionalProperties"
jsonpath "$.steps[14].annotation" == null
jsonpath "$.steps[14].message" == null
jsonpath "$.steps[14].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[15].type" == "pass"
jsonpath "$.steps[15].name" == "LoopPropertiesExcept"
jsonpath "$.steps[15].evaluatePath" == "/$ref/additionalProperties"
jsonpath "$.steps[15].instanceLocation" == ""
jsonpath "$.steps[15].instancePositions" count == 4
jsonpath "$.steps[15].instancePositions[0]" == 2
jsonpath "$.steps[15].instancePositions[1]" == 3
jsonpath "$.steps[15].instancePositions[2]" == 5
jsonpath "$.steps[15].instancePositions[3]" == 3
jsonpath "$.steps[15].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/additionalProperties"
jsonpath "$.steps[15].annotation" == null
jsonpath "$.steps[15].message" == "The object value was not expected to define additional properties"
jsonpath "$.steps[15].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[16].type" == "push"
jsonpath "$.steps[16].name" == "AssertionTypeStrict"
jsonpath "$.steps[16].evaluatePath" == "/$ref/type"
jsonpath "$.steps[16].instanceLocation" == ""
jsonpath "$.steps[16].instancePositions" count == 4
jsonpath "$.steps[16].instancePositions[0]" == 2
jsonpath "$.steps[16].instancePositions[1]" == 3
jsonpath "$.steps[16].instancePositions[2]" == 5
jsonpath "$.steps[16].instancePositions[3]" == 3
jsonpath "$.steps[16].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/type"
jsonpath "$.steps[16].annotation" == null
jsonpath "$.steps[16].message" == null
jsonpath "$.steps[16].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[17].type" == "pass"
jsonpath "$.steps[17].name" == "AssertionTypeStrict"
jsonpath "$.steps[17].evaluatePath" == "/$ref/type"
jsonpath "$.steps[17].instanceLocation" == ""
jsonpath "$.steps[17].instancePositions" count == 4
jsonpath "$.steps[17].instancePositions[0]" == 2
jsonpath "$.steps[17].instancePositions[1]" == 3
jsonpath "$.steps[17].instancePositions[2]" == 5
jsonpath "$.steps[17].instancePositions[3]" == 3
jsonpath "$.steps[17].keywordLocation" == "{{base}}/self/v1/schemas/api/schemas/trace/response#/type"
jsonpath "$.steps[17].annotation" == null
jsonpath "$.steps[17].message" == "The value was expected to be of type object"
jsonpath "$.steps[17].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[18].type" == "pass"
jsonpath "$.steps[18].name" == "ControlJump"
jsonpath "$.steps[18].evaluatePath" == "/$ref"
jsonpath "$.steps[18].instanceLocation" == ""
jsonpath "$.steps[18].instancePositions" count == 4
jsonpath "$.steps[18].instancePositions[0]" == 2
jsonpath "$.steps[18].instancePositions[1]" == 3
jsonpath "$.steps[18].instancePositions[2]" == 5
jsonpath "$.steps[18].instancePositions[3]" == 3
jsonpath "$.steps[18].keywordLocation" == "#/$ref"
jsonpath "$.steps[18].annotation" == null
jsonpath "$.steps[18].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[18].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

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

# An official metaschema resolves without being in this catalog, which is
# what lets a caller name a dialect at all
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": {
    "type": "string"
  },
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "https://json-schema.org/draft/2020-12/schema"
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
jsonpath "$.steps" count == 67
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
jsonpath "$.steps[1].name" == "LogicalAnd"
jsonpath "$.steps[1].evaluatePath" == "/$ref/allOf"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 2
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 4
jsonpath "$.steps[1].instancePositions[3]" == 3
jsonpath "$.steps[1].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "ControlJump"
jsonpath "$.steps[2].evaluatePath" == "/$ref/allOf/0/$ref"
jsonpath "$.steps[2].instanceLocation" == ""
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 2
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 4
jsonpath "$.steps[2].instancePositions[3]" == 3
jsonpath "$.steps[2].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/0/$ref"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AnnotationEmit"
jsonpath "$.steps[3].evaluatePath" == "/$ref/allOf/0/$ref/title"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 4
jsonpath "$.steps[3].instancePositions[3]" == 3
jsonpath "$.steps[3].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/core#/title"
jsonpath "$.steps[3].annotation" == "Core vocabulary meta-schema"
jsonpath "$.steps[3].message" == "The title of the instance was \"Core vocabulary meta-schema\""
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[4].type" == "push"
jsonpath "$.steps[4].name" == "LoopPropertiesMatch"
jsonpath "$.steps[4].evaluatePath" == "/$ref/allOf/0/$ref/properties"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 2
jsonpath "$.steps[4].instancePositions[1]" == 3
jsonpath "$.steps[4].instancePositions[2]" == 4
jsonpath "$.steps[4].instancePositions[3]" == 3
jsonpath "$.steps[4].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/core#/properties"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == null
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "LoopPropertiesMatch"
jsonpath "$.steps[5].evaluatePath" == "/$ref/allOf/0/$ref/properties"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 2
jsonpath "$.steps[5].instancePositions[1]" == 3
jsonpath "$.steps[5].instancePositions[2]" == 4
jsonpath "$.steps[5].instancePositions[3]" == 3
jsonpath "$.steps[5].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/core#/properties"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "The object value was expected to validate against the 9 defined properties subschemas"
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[6].type" == "push"
jsonpath "$.steps[6].name" == "AssertionTypeAny"
jsonpath "$.steps[6].evaluatePath" == "/$ref/allOf/0/$ref/type"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].instancePositions[0]" == 2
jsonpath "$.steps[6].instancePositions[1]" == 3
jsonpath "$.steps[6].instancePositions[2]" == 4
jsonpath "$.steps[6].instancePositions[3]" == 3
jsonpath "$.steps[6].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/core#/type"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == null
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[7].type" == "pass"
jsonpath "$.steps[7].name" == "AssertionTypeAny"
jsonpath "$.steps[7].evaluatePath" == "/$ref/allOf/0/$ref/type"
jsonpath "$.steps[7].instanceLocation" == ""
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[7].instancePositions[0]" == 2
jsonpath "$.steps[7].instancePositions[1]" == 3
jsonpath "$.steps[7].instancePositions[2]" == 4
jsonpath "$.steps[7].instancePositions[3]" == 3
jsonpath "$.steps[7].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/core#/type"
jsonpath "$.steps[7].annotation" == null
jsonpath "$.steps[7].message" == "The value was expected to be of type boolean, or object and it was of type object"
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[8].type" == "pass"
jsonpath "$.steps[8].name" == "ControlJump"
jsonpath "$.steps[8].evaluatePath" == "/$ref/allOf/0/$ref"
jsonpath "$.steps[8].instanceLocation" == ""
jsonpath "$.steps[8].instancePositions" count == 4
jsonpath "$.steps[8].instancePositions[0]" == 2
jsonpath "$.steps[8].instancePositions[1]" == 3
jsonpath "$.steps[8].instancePositions[2]" == 4
jsonpath "$.steps[8].instancePositions[3]" == 3
jsonpath "$.steps[8].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/0/$ref"
jsonpath "$.steps[8].annotation" == null
jsonpath "$.steps[8].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[9].type" == "push"
jsonpath "$.steps[9].name" == "ControlJump"
jsonpath "$.steps[9].evaluatePath" == "/$ref/allOf/1/$ref"
jsonpath "$.steps[9].instanceLocation" == ""
jsonpath "$.steps[9].instancePositions" count == 4
jsonpath "$.steps[9].instancePositions[0]" == 2
jsonpath "$.steps[9].instancePositions[1]" == 3
jsonpath "$.steps[9].instancePositions[2]" == 4
jsonpath "$.steps[9].instancePositions[3]" == 3
jsonpath "$.steps[9].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/1/$ref"
jsonpath "$.steps[9].annotation" == null
jsonpath "$.steps[9].message" == null
jsonpath "$.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[10].type" == "pass"
jsonpath "$.steps[10].name" == "AnnotationEmit"
jsonpath "$.steps[10].evaluatePath" == "/$ref/allOf/1/$ref/title"
jsonpath "$.steps[10].instanceLocation" == ""
jsonpath "$.steps[10].instancePositions" count == 4
jsonpath "$.steps[10].instancePositions[0]" == 2
jsonpath "$.steps[10].instancePositions[1]" == 3
jsonpath "$.steps[10].instancePositions[2]" == 4
jsonpath "$.steps[10].instancePositions[3]" == 3
jsonpath "$.steps[10].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/applicator#/title"
jsonpath "$.steps[10].annotation" == "Applicator vocabulary meta-schema"
jsonpath "$.steps[10].message" == "The title of the instance was \"Applicator vocabulary meta-schema\""
jsonpath "$.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[11].type" == "push"
jsonpath "$.steps[11].name" == "LoopPropertiesMatch"
jsonpath "$.steps[11].evaluatePath" == "/$ref/allOf/1/$ref/properties"
jsonpath "$.steps[11].instanceLocation" == ""
jsonpath "$.steps[11].instancePositions" count == 4
jsonpath "$.steps[11].instancePositions[0]" == 2
jsonpath "$.steps[11].instancePositions[1]" == 3
jsonpath "$.steps[11].instancePositions[2]" == 4
jsonpath "$.steps[11].instancePositions[3]" == 3
jsonpath "$.steps[11].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/applicator#/properties"
jsonpath "$.steps[11].annotation" == null
jsonpath "$.steps[11].message" == null
jsonpath "$.steps[11].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[12].type" == "pass"
jsonpath "$.steps[12].name" == "LoopPropertiesMatch"
jsonpath "$.steps[12].evaluatePath" == "/$ref/allOf/1/$ref/properties"
jsonpath "$.steps[12].instanceLocation" == ""
jsonpath "$.steps[12].instancePositions" count == 4
jsonpath "$.steps[12].instancePositions[0]" == 2
jsonpath "$.steps[12].instancePositions[1]" == 3
jsonpath "$.steps[12].instancePositions[2]" == 4
jsonpath "$.steps[12].instancePositions[3]" == 3
jsonpath "$.steps[12].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/applicator#/properties"
jsonpath "$.steps[12].annotation" == null
jsonpath "$.steps[12].message" == "The object value was expected to validate against the 15 defined properties subschemas"
jsonpath "$.steps[12].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[13].type" == "push"
jsonpath "$.steps[13].name" == "AssertionTypeAny"
jsonpath "$.steps[13].evaluatePath" == "/$ref/allOf/1/$ref/type"
jsonpath "$.steps[13].instanceLocation" == ""
jsonpath "$.steps[13].instancePositions" count == 4
jsonpath "$.steps[13].instancePositions[0]" == 2
jsonpath "$.steps[13].instancePositions[1]" == 3
jsonpath "$.steps[13].instancePositions[2]" == 4
jsonpath "$.steps[13].instancePositions[3]" == 3
jsonpath "$.steps[13].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/applicator#/type"
jsonpath "$.steps[13].annotation" == null
jsonpath "$.steps[13].message" == null
jsonpath "$.steps[13].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[14].type" == "pass"
jsonpath "$.steps[14].name" == "AssertionTypeAny"
jsonpath "$.steps[14].evaluatePath" == "/$ref/allOf/1/$ref/type"
jsonpath "$.steps[14].instanceLocation" == ""
jsonpath "$.steps[14].instancePositions" count == 4
jsonpath "$.steps[14].instancePositions[0]" == 2
jsonpath "$.steps[14].instancePositions[1]" == 3
jsonpath "$.steps[14].instancePositions[2]" == 4
jsonpath "$.steps[14].instancePositions[3]" == 3
jsonpath "$.steps[14].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/applicator#/type"
jsonpath "$.steps[14].annotation" == null
jsonpath "$.steps[14].message" == "The value was expected to be of type boolean, or object and it was of type object"
jsonpath "$.steps[14].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[15].type" == "pass"
jsonpath "$.steps[15].name" == "ControlJump"
jsonpath "$.steps[15].evaluatePath" == "/$ref/allOf/1/$ref"
jsonpath "$.steps[15].instanceLocation" == ""
jsonpath "$.steps[15].instancePositions" count == 4
jsonpath "$.steps[15].instancePositions[0]" == 2
jsonpath "$.steps[15].instancePositions[1]" == 3
jsonpath "$.steps[15].instancePositions[2]" == 4
jsonpath "$.steps[15].instancePositions[3]" == 3
jsonpath "$.steps[15].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/1/$ref"
jsonpath "$.steps[15].annotation" == null
jsonpath "$.steps[15].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[15].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[16].type" == "push"
jsonpath "$.steps[16].name" == "ControlJump"
jsonpath "$.steps[16].evaluatePath" == "/$ref/allOf/2/$ref"
jsonpath "$.steps[16].instanceLocation" == ""
jsonpath "$.steps[16].instancePositions" count == 4
jsonpath "$.steps[16].instancePositions[0]" == 2
jsonpath "$.steps[16].instancePositions[1]" == 3
jsonpath "$.steps[16].instancePositions[2]" == 4
jsonpath "$.steps[16].instancePositions[3]" == 3
jsonpath "$.steps[16].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/2/$ref"
jsonpath "$.steps[16].annotation" == null
jsonpath "$.steps[16].message" == null
jsonpath "$.steps[16].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[17].type" == "pass"
jsonpath "$.steps[17].name" == "AnnotationEmit"
jsonpath "$.steps[17].evaluatePath" == "/$ref/allOf/2/$ref/title"
jsonpath "$.steps[17].instanceLocation" == ""
jsonpath "$.steps[17].instancePositions" count == 4
jsonpath "$.steps[17].instancePositions[0]" == 2
jsonpath "$.steps[17].instancePositions[1]" == 3
jsonpath "$.steps[17].instancePositions[2]" == 4
jsonpath "$.steps[17].instancePositions[3]" == 3
jsonpath "$.steps[17].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/unevaluated#/title"
jsonpath "$.steps[17].annotation" == "Unevaluated applicator vocabulary meta-schema"
jsonpath "$.steps[17].message" == "The title of the instance was \"Unevaluated applicator vocabulary meta-schema\""
jsonpath "$.steps[17].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[18].type" == "push"
jsonpath "$.steps[18].name" == "LogicalWhenType"
jsonpath "$.steps[18].evaluatePath" == "/$ref/allOf/2/$ref/properties"
jsonpath "$.steps[18].instanceLocation" == ""
jsonpath "$.steps[18].instancePositions" count == 4
jsonpath "$.steps[18].instancePositions[0]" == 2
jsonpath "$.steps[18].instancePositions[1]" == 3
jsonpath "$.steps[18].instancePositions[2]" == 4
jsonpath "$.steps[18].instancePositions[3]" == 3
jsonpath "$.steps[18].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/unevaluated#/properties"
jsonpath "$.steps[18].annotation" == null
jsonpath "$.steps[18].message" == null
jsonpath "$.steps[18].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[19].type" == "pass"
jsonpath "$.steps[19].name" == "LogicalWhenType"
jsonpath "$.steps[19].evaluatePath" == "/$ref/allOf/2/$ref/properties"
jsonpath "$.steps[19].instanceLocation" == ""
jsonpath "$.steps[19].instancePositions" count == 4
jsonpath "$.steps[19].instancePositions[0]" == 2
jsonpath "$.steps[19].instancePositions[1]" == 3
jsonpath "$.steps[19].instancePositions[2]" == 4
jsonpath "$.steps[19].instancePositions[3]" == 3
jsonpath "$.steps[19].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/unevaluated#/properties"
jsonpath "$.steps[19].annotation" == null
jsonpath "$.steps[19].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[19].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[20].type" == "push"
jsonpath "$.steps[20].name" == "AssertionTypeAny"
jsonpath "$.steps[20].evaluatePath" == "/$ref/allOf/2/$ref/type"
jsonpath "$.steps[20].instanceLocation" == ""
jsonpath "$.steps[20].instancePositions" count == 4
jsonpath "$.steps[20].instancePositions[0]" == 2
jsonpath "$.steps[20].instancePositions[1]" == 3
jsonpath "$.steps[20].instancePositions[2]" == 4
jsonpath "$.steps[20].instancePositions[3]" == 3
jsonpath "$.steps[20].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/unevaluated#/type"
jsonpath "$.steps[20].annotation" == null
jsonpath "$.steps[20].message" == null
jsonpath "$.steps[20].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[21].type" == "pass"
jsonpath "$.steps[21].name" == "AssertionTypeAny"
jsonpath "$.steps[21].evaluatePath" == "/$ref/allOf/2/$ref/type"
jsonpath "$.steps[21].instanceLocation" == ""
jsonpath "$.steps[21].instancePositions" count == 4
jsonpath "$.steps[21].instancePositions[0]" == 2
jsonpath "$.steps[21].instancePositions[1]" == 3
jsonpath "$.steps[21].instancePositions[2]" == 4
jsonpath "$.steps[21].instancePositions[3]" == 3
jsonpath "$.steps[21].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/unevaluated#/type"
jsonpath "$.steps[21].annotation" == null
jsonpath "$.steps[21].message" == "The value was expected to be of type boolean, or object and it was of type object"
jsonpath "$.steps[21].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[22].type" == "pass"
jsonpath "$.steps[22].name" == "ControlJump"
jsonpath "$.steps[22].evaluatePath" == "/$ref/allOf/2/$ref"
jsonpath "$.steps[22].instanceLocation" == ""
jsonpath "$.steps[22].instancePositions" count == 4
jsonpath "$.steps[22].instancePositions[0]" == 2
jsonpath "$.steps[22].instancePositions[1]" == 3
jsonpath "$.steps[22].instancePositions[2]" == 4
jsonpath "$.steps[22].instancePositions[3]" == 3
jsonpath "$.steps[22].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/2/$ref"
jsonpath "$.steps[22].annotation" == null
jsonpath "$.steps[22].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[22].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[23].type" == "push"
jsonpath "$.steps[23].name" == "ControlJump"
jsonpath "$.steps[23].evaluatePath" == "/$ref/allOf/3/$ref"
jsonpath "$.steps[23].instanceLocation" == ""
jsonpath "$.steps[23].instancePositions" count == 4
jsonpath "$.steps[23].instancePositions[0]" == 2
jsonpath "$.steps[23].instancePositions[1]" == 3
jsonpath "$.steps[23].instancePositions[2]" == 4
jsonpath "$.steps[23].instancePositions[3]" == 3
jsonpath "$.steps[23].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/3/$ref"
jsonpath "$.steps[23].annotation" == null
jsonpath "$.steps[23].message" == null
jsonpath "$.steps[23].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[24].type" == "pass"
jsonpath "$.steps[24].name" == "AnnotationEmit"
jsonpath "$.steps[24].evaluatePath" == "/$ref/allOf/3/$ref/title"
jsonpath "$.steps[24].instanceLocation" == ""
jsonpath "$.steps[24].instancePositions" count == 4
jsonpath "$.steps[24].instancePositions[0]" == 2
jsonpath "$.steps[24].instancePositions[1]" == 3
jsonpath "$.steps[24].instancePositions[2]" == 4
jsonpath "$.steps[24].instancePositions[3]" == 3
jsonpath "$.steps[24].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/title"
jsonpath "$.steps[24].annotation" == "Validation vocabulary meta-schema"
jsonpath "$.steps[24].message" == "The title of the instance was \"Validation vocabulary meta-schema\""
jsonpath "$.steps[24].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[25].type" == "push"
jsonpath "$.steps[25].name" == "LoopPropertiesMatch"
jsonpath "$.steps[25].evaluatePath" == "/$ref/allOf/3/$ref/properties"
jsonpath "$.steps[25].instanceLocation" == ""
jsonpath "$.steps[25].instancePositions" count == 4
jsonpath "$.steps[25].instancePositions[0]" == 2
jsonpath "$.steps[25].instancePositions[1]" == 3
jsonpath "$.steps[25].instancePositions[2]" == 4
jsonpath "$.steps[25].instancePositions[3]" == 3
jsonpath "$.steps[25].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/properties"
jsonpath "$.steps[25].annotation" == null
jsonpath "$.steps[25].message" == null
jsonpath "$.steps[25].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[26].type" == "push"
jsonpath "$.steps[26].name" == "LogicalOr"
jsonpath "$.steps[26].evaluatePath" == "/$ref/allOf/3/$ref/properties/type/anyOf"
jsonpath "$.steps[26].instanceLocation" == "/type"
jsonpath "$.steps[26].instancePositions" count == 4
jsonpath "$.steps[26].instancePositions[0]" == 3
jsonpath "$.steps[26].instancePositions[1]" == 5
jsonpath "$.steps[26].instancePositions[2]" == 3
jsonpath "$.steps[26].instancePositions[3]" == 20
jsonpath "$.steps[26].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/properties/type/anyOf"
jsonpath "$.steps[26].annotation" == null
jsonpath "$.steps[26].message" == null
jsonpath "$.steps[26].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[27].type" == "push"
jsonpath "$.steps[27].name" == "ControlJump"
jsonpath "$.steps[27].evaluatePath" == "/$ref/allOf/3/$ref/properties/type/anyOf/0/$ref"
jsonpath "$.steps[27].instanceLocation" == "/type"
jsonpath "$.steps[27].instancePositions" count == 4
jsonpath "$.steps[27].instancePositions[0]" == 3
jsonpath "$.steps[27].instancePositions[1]" == 5
jsonpath "$.steps[27].instancePositions[2]" == 3
jsonpath "$.steps[27].instancePositions[3]" == 20
jsonpath "$.steps[27].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/properties/type/anyOf/0/$ref"
jsonpath "$.steps[27].annotation" == null
jsonpath "$.steps[27].message" == null
jsonpath "$.steps[27].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[28].type" == "push"
jsonpath "$.steps[28].name" == "AssertionEqualsAny"
jsonpath "$.steps[28].evaluatePath" == "/$ref/allOf/3/$ref/properties/type/anyOf/0/$ref/enum"
jsonpath "$.steps[28].instanceLocation" == "/type"
jsonpath "$.steps[28].instancePositions" count == 4
jsonpath "$.steps[28].instancePositions[0]" == 3
jsonpath "$.steps[28].instancePositions[1]" == 5
jsonpath "$.steps[28].instancePositions[2]" == 3
jsonpath "$.steps[28].instancePositions[3]" == 20
jsonpath "$.steps[28].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/$defs/simpleTypes/enum"
jsonpath "$.steps[28].annotation" == null
jsonpath "$.steps[28].message" == null
jsonpath "$.steps[28].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[29].type" == "pass"
jsonpath "$.steps[29].name" == "AssertionEqualsAny"
jsonpath "$.steps[29].evaluatePath" == "/$ref/allOf/3/$ref/properties/type/anyOf/0/$ref/enum"
jsonpath "$.steps[29].instanceLocation" == "/type"
jsonpath "$.steps[29].instancePositions" count == 4
jsonpath "$.steps[29].instancePositions[0]" == 3
jsonpath "$.steps[29].instancePositions[1]" == 5
jsonpath "$.steps[29].instancePositions[2]" == 3
jsonpath "$.steps[29].instancePositions[3]" == 20
jsonpath "$.steps[29].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/$defs/simpleTypes/enum"
jsonpath "$.steps[29].annotation" == null
jsonpath "$.steps[29].message" == "The string value \"string\" was expected to equal one of the 7 declared values"
jsonpath "$.steps[29].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[30].type" == "pass"
jsonpath "$.steps[30].name" == "ControlJump"
jsonpath "$.steps[30].evaluatePath" == "/$ref/allOf/3/$ref/properties/type/anyOf/0/$ref"
jsonpath "$.steps[30].instanceLocation" == "/type"
jsonpath "$.steps[30].instancePositions" count == 4
jsonpath "$.steps[30].instancePositions[0]" == 3
jsonpath "$.steps[30].instancePositions[1]" == 5
jsonpath "$.steps[30].instancePositions[2]" == 3
jsonpath "$.steps[30].instancePositions[3]" == 20
jsonpath "$.steps[30].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/properties/type/anyOf/0/$ref"
jsonpath "$.steps[30].annotation" == null
jsonpath "$.steps[30].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[30].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[31].type" == "push"
jsonpath "$.steps[31].name" == "AssertionTypeStrict"
jsonpath "$.steps[31].evaluatePath" == "/$ref/allOf/3/$ref/properties/type/anyOf/1/type"
jsonpath "$.steps[31].instanceLocation" == "/type"
jsonpath "$.steps[31].instancePositions" count == 4
jsonpath "$.steps[31].instancePositions[0]" == 3
jsonpath "$.steps[31].instancePositions[1]" == 5
jsonpath "$.steps[31].instancePositions[2]" == 3
jsonpath "$.steps[31].instancePositions[3]" == 20
jsonpath "$.steps[31].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/properties/type/anyOf/1/type"
jsonpath "$.steps[31].annotation" == null
jsonpath "$.steps[31].message" == null
jsonpath "$.steps[31].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[32].type" == "fail"
jsonpath "$.steps[32].name" == "AssertionTypeStrict"
jsonpath "$.steps[32].evaluatePath" == "/$ref/allOf/3/$ref/properties/type/anyOf/1/type"
jsonpath "$.steps[32].instanceLocation" == "/type"
jsonpath "$.steps[32].instancePositions" count == 4
jsonpath "$.steps[32].instancePositions[0]" == 3
jsonpath "$.steps[32].instancePositions[1]" == 5
jsonpath "$.steps[32].instancePositions[2]" == 3
jsonpath "$.steps[32].instancePositions[3]" == 20
jsonpath "$.steps[32].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/properties/type/anyOf/1/type"
jsonpath "$.steps[32].annotation" == null
jsonpath "$.steps[32].message" == "The value was expected to be of type array but it was of type string"
jsonpath "$.steps[32].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[33].type" == "pass"
jsonpath "$.steps[33].name" == "LogicalOr"
jsonpath "$.steps[33].evaluatePath" == "/$ref/allOf/3/$ref/properties/type/anyOf"
jsonpath "$.steps[33].instanceLocation" == "/type"
jsonpath "$.steps[33].instancePositions" count == 4
jsonpath "$.steps[33].instancePositions[0]" == 3
jsonpath "$.steps[33].instancePositions[1]" == 5
jsonpath "$.steps[33].instancePositions[2]" == 3
jsonpath "$.steps[33].instancePositions[3]" == 20
jsonpath "$.steps[33].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/properties/type/anyOf"
jsonpath "$.steps[33].annotation" == null
jsonpath "$.steps[33].message" == "The string value was expected to validate against at least one of the 2 given subschemas"
jsonpath "$.steps[33].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[34].type" == "pass"
jsonpath "$.steps[34].name" == "AnnotationEmitWrapped"
jsonpath "$.steps[34].evaluatePath" == "/$ref/allOf/3/$ref/properties"
jsonpath "$.steps[34].instanceLocation" == ""
jsonpath "$.steps[34].instancePositions" count == 4
jsonpath "$.steps[34].instancePositions[0]" == 2
jsonpath "$.steps[34].instancePositions[1]" == 3
jsonpath "$.steps[34].instancePositions[2]" == 4
jsonpath "$.steps[34].instancePositions[3]" == 3
jsonpath "$.steps[34].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/properties"
jsonpath "$.steps[34].annotation" == "type"
jsonpath "$.steps[34].message" == "The object property \"type\" successfully validated against its property subschema"
jsonpath "$.steps[34].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[35].type" == "pass"
jsonpath "$.steps[35].name" == "LoopPropertiesMatch"
jsonpath "$.steps[35].evaluatePath" == "/$ref/allOf/3/$ref/properties"
jsonpath "$.steps[35].instanceLocation" == ""
jsonpath "$.steps[35].instancePositions" count == 4
jsonpath "$.steps[35].instancePositions[0]" == 2
jsonpath "$.steps[35].instancePositions[1]" == 3
jsonpath "$.steps[35].instancePositions[2]" == 4
jsonpath "$.steps[35].instancePositions[3]" == 3
jsonpath "$.steps[35].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/properties"
jsonpath "$.steps[35].annotation" == null
jsonpath "$.steps[35].message" == "The object value was expected to validate against the 20 defined properties subschemas"
jsonpath "$.steps[35].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[36].type" == "push"
jsonpath "$.steps[36].name" == "AssertionTypeAny"
jsonpath "$.steps[36].evaluatePath" == "/$ref/allOf/3/$ref/type"
jsonpath "$.steps[36].instanceLocation" == ""
jsonpath "$.steps[36].instancePositions" count == 4
jsonpath "$.steps[36].instancePositions[0]" == 2
jsonpath "$.steps[36].instancePositions[1]" == 3
jsonpath "$.steps[36].instancePositions[2]" == 4
jsonpath "$.steps[36].instancePositions[3]" == 3
jsonpath "$.steps[36].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/type"
jsonpath "$.steps[36].annotation" == null
jsonpath "$.steps[36].message" == null
jsonpath "$.steps[36].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[37].type" == "pass"
jsonpath "$.steps[37].name" == "AssertionTypeAny"
jsonpath "$.steps[37].evaluatePath" == "/$ref/allOf/3/$ref/type"
jsonpath "$.steps[37].instanceLocation" == ""
jsonpath "$.steps[37].instancePositions" count == 4
jsonpath "$.steps[37].instancePositions[0]" == 2
jsonpath "$.steps[37].instancePositions[1]" == 3
jsonpath "$.steps[37].instancePositions[2]" == 4
jsonpath "$.steps[37].instancePositions[3]" == 3
jsonpath "$.steps[37].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/validation#/type"
jsonpath "$.steps[37].annotation" == null
jsonpath "$.steps[37].message" == "The value was expected to be of type boolean, or object and it was of type object"
jsonpath "$.steps[37].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[38].type" == "pass"
jsonpath "$.steps[38].name" == "ControlJump"
jsonpath "$.steps[38].evaluatePath" == "/$ref/allOf/3/$ref"
jsonpath "$.steps[38].instanceLocation" == ""
jsonpath "$.steps[38].instancePositions" count == 4
jsonpath "$.steps[38].instancePositions[0]" == 2
jsonpath "$.steps[38].instancePositions[1]" == 3
jsonpath "$.steps[38].instancePositions[2]" == 4
jsonpath "$.steps[38].instancePositions[3]" == 3
jsonpath "$.steps[38].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/3/$ref"
jsonpath "$.steps[38].annotation" == null
jsonpath "$.steps[38].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[38].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[39].type" == "push"
jsonpath "$.steps[39].name" == "ControlJump"
jsonpath "$.steps[39].evaluatePath" == "/$ref/allOf/4/$ref"
jsonpath "$.steps[39].instanceLocation" == ""
jsonpath "$.steps[39].instancePositions" count == 4
jsonpath "$.steps[39].instancePositions[0]" == 2
jsonpath "$.steps[39].instancePositions[1]" == 3
jsonpath "$.steps[39].instancePositions[2]" == 4
jsonpath "$.steps[39].instancePositions[3]" == 3
jsonpath "$.steps[39].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/4/$ref"
jsonpath "$.steps[39].annotation" == null
jsonpath "$.steps[39].message" == null
jsonpath "$.steps[39].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[40].type" == "pass"
jsonpath "$.steps[40].name" == "AnnotationEmit"
jsonpath "$.steps[40].evaluatePath" == "/$ref/allOf/4/$ref/title"
jsonpath "$.steps[40].instanceLocation" == ""
jsonpath "$.steps[40].instancePositions" count == 4
jsonpath "$.steps[40].instancePositions[0]" == 2
jsonpath "$.steps[40].instancePositions[1]" == 3
jsonpath "$.steps[40].instancePositions[2]" == 4
jsonpath "$.steps[40].instancePositions[3]" == 3
jsonpath "$.steps[40].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/meta-data#/title"
jsonpath "$.steps[40].annotation" == "Meta-data vocabulary meta-schema"
jsonpath "$.steps[40].message" == "The title of the instance was \"Meta-data vocabulary meta-schema\""
jsonpath "$.steps[40].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[41].type" == "push"
jsonpath "$.steps[41].name" == "LoopPropertiesMatch"
jsonpath "$.steps[41].evaluatePath" == "/$ref/allOf/4/$ref/properties"
jsonpath "$.steps[41].instanceLocation" == ""
jsonpath "$.steps[41].instancePositions" count == 4
jsonpath "$.steps[41].instancePositions[0]" == 2
jsonpath "$.steps[41].instancePositions[1]" == 3
jsonpath "$.steps[41].instancePositions[2]" == 4
jsonpath "$.steps[41].instancePositions[3]" == 3
jsonpath "$.steps[41].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/meta-data#/properties"
jsonpath "$.steps[41].annotation" == null
jsonpath "$.steps[41].message" == null
jsonpath "$.steps[41].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[42].type" == "pass"
jsonpath "$.steps[42].name" == "LoopPropertiesMatch"
jsonpath "$.steps[42].evaluatePath" == "/$ref/allOf/4/$ref/properties"
jsonpath "$.steps[42].instanceLocation" == ""
jsonpath "$.steps[42].instancePositions" count == 4
jsonpath "$.steps[42].instancePositions[0]" == 2
jsonpath "$.steps[42].instancePositions[1]" == 3
jsonpath "$.steps[42].instancePositions[2]" == 4
jsonpath "$.steps[42].instancePositions[3]" == 3
jsonpath "$.steps[42].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/meta-data#/properties"
jsonpath "$.steps[42].annotation" == null
jsonpath "$.steps[42].message" == "The object value was expected to validate against the 7 defined properties subschemas"
jsonpath "$.steps[42].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[43].type" == "push"
jsonpath "$.steps[43].name" == "AssertionTypeAny"
jsonpath "$.steps[43].evaluatePath" == "/$ref/allOf/4/$ref/type"
jsonpath "$.steps[43].instanceLocation" == ""
jsonpath "$.steps[43].instancePositions" count == 4
jsonpath "$.steps[43].instancePositions[0]" == 2
jsonpath "$.steps[43].instancePositions[1]" == 3
jsonpath "$.steps[43].instancePositions[2]" == 4
jsonpath "$.steps[43].instancePositions[3]" == 3
jsonpath "$.steps[43].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/meta-data#/type"
jsonpath "$.steps[43].annotation" == null
jsonpath "$.steps[43].message" == null
jsonpath "$.steps[43].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[44].type" == "pass"
jsonpath "$.steps[44].name" == "AssertionTypeAny"
jsonpath "$.steps[44].evaluatePath" == "/$ref/allOf/4/$ref/type"
jsonpath "$.steps[44].instanceLocation" == ""
jsonpath "$.steps[44].instancePositions" count == 4
jsonpath "$.steps[44].instancePositions[0]" == 2
jsonpath "$.steps[44].instancePositions[1]" == 3
jsonpath "$.steps[44].instancePositions[2]" == 4
jsonpath "$.steps[44].instancePositions[3]" == 3
jsonpath "$.steps[44].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/meta-data#/type"
jsonpath "$.steps[44].annotation" == null
jsonpath "$.steps[44].message" == "The value was expected to be of type boolean, or object and it was of type object"
jsonpath "$.steps[44].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[45].type" == "pass"
jsonpath "$.steps[45].name" == "ControlJump"
jsonpath "$.steps[45].evaluatePath" == "/$ref/allOf/4/$ref"
jsonpath "$.steps[45].instanceLocation" == ""
jsonpath "$.steps[45].instancePositions" count == 4
jsonpath "$.steps[45].instancePositions[0]" == 2
jsonpath "$.steps[45].instancePositions[1]" == 3
jsonpath "$.steps[45].instancePositions[2]" == 4
jsonpath "$.steps[45].instancePositions[3]" == 3
jsonpath "$.steps[45].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/4/$ref"
jsonpath "$.steps[45].annotation" == null
jsonpath "$.steps[45].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[45].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[46].type" == "push"
jsonpath "$.steps[46].name" == "ControlJump"
jsonpath "$.steps[46].evaluatePath" == "/$ref/allOf/5/$ref"
jsonpath "$.steps[46].instanceLocation" == ""
jsonpath "$.steps[46].instancePositions" count == 4
jsonpath "$.steps[46].instancePositions[0]" == 2
jsonpath "$.steps[46].instancePositions[1]" == 3
jsonpath "$.steps[46].instancePositions[2]" == 4
jsonpath "$.steps[46].instancePositions[3]" == 3
jsonpath "$.steps[46].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/5/$ref"
jsonpath "$.steps[46].annotation" == null
jsonpath "$.steps[46].message" == null
jsonpath "$.steps[46].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[47].type" == "pass"
jsonpath "$.steps[47].name" == "AnnotationEmit"
jsonpath "$.steps[47].evaluatePath" == "/$ref/allOf/5/$ref/title"
jsonpath "$.steps[47].instanceLocation" == ""
jsonpath "$.steps[47].instancePositions" count == 4
jsonpath "$.steps[47].instancePositions[0]" == 2
jsonpath "$.steps[47].instancePositions[1]" == 3
jsonpath "$.steps[47].instancePositions[2]" == 4
jsonpath "$.steps[47].instancePositions[3]" == 3
jsonpath "$.steps[47].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/format-annotation#/title"
jsonpath "$.steps[47].annotation" == "Format vocabulary meta-schema for annotation results"
jsonpath "$.steps[47].message" == "The title of the instance was \"Format vocabulary meta-schema for annotation results\""
jsonpath "$.steps[47].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[48].type" == "push"
jsonpath "$.steps[48].name" == "LogicalWhenType"
jsonpath "$.steps[48].evaluatePath" == "/$ref/allOf/5/$ref/properties"
jsonpath "$.steps[48].instanceLocation" == ""
jsonpath "$.steps[48].instancePositions" count == 4
jsonpath "$.steps[48].instancePositions[0]" == 2
jsonpath "$.steps[48].instancePositions[1]" == 3
jsonpath "$.steps[48].instancePositions[2]" == 4
jsonpath "$.steps[48].instancePositions[3]" == 3
jsonpath "$.steps[48].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/format-annotation#/properties"
jsonpath "$.steps[48].annotation" == null
jsonpath "$.steps[48].message" == null
jsonpath "$.steps[48].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[49].type" == "pass"
jsonpath "$.steps[49].name" == "LogicalWhenType"
jsonpath "$.steps[49].evaluatePath" == "/$ref/allOf/5/$ref/properties"
jsonpath "$.steps[49].instanceLocation" == ""
jsonpath "$.steps[49].instancePositions" count == 4
jsonpath "$.steps[49].instancePositions[0]" == 2
jsonpath "$.steps[49].instancePositions[1]" == 3
jsonpath "$.steps[49].instancePositions[2]" == 4
jsonpath "$.steps[49].instancePositions[3]" == 3
jsonpath "$.steps[49].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/format-annotation#/properties"
jsonpath "$.steps[49].annotation" == null
jsonpath "$.steps[49].message" == "The object value was expected to validate against the single defined property subschema"
jsonpath "$.steps[49].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[50].type" == "push"
jsonpath "$.steps[50].name" == "AssertionTypeAny"
jsonpath "$.steps[50].evaluatePath" == "/$ref/allOf/5/$ref/type"
jsonpath "$.steps[50].instanceLocation" == ""
jsonpath "$.steps[50].instancePositions" count == 4
jsonpath "$.steps[50].instancePositions[0]" == 2
jsonpath "$.steps[50].instancePositions[1]" == 3
jsonpath "$.steps[50].instancePositions[2]" == 4
jsonpath "$.steps[50].instancePositions[3]" == 3
jsonpath "$.steps[50].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/format-annotation#/type"
jsonpath "$.steps[50].annotation" == null
jsonpath "$.steps[50].message" == null
jsonpath "$.steps[50].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[51].type" == "pass"
jsonpath "$.steps[51].name" == "AssertionTypeAny"
jsonpath "$.steps[51].evaluatePath" == "/$ref/allOf/5/$ref/type"
jsonpath "$.steps[51].instanceLocation" == ""
jsonpath "$.steps[51].instancePositions" count == 4
jsonpath "$.steps[51].instancePositions[0]" == 2
jsonpath "$.steps[51].instancePositions[1]" == 3
jsonpath "$.steps[51].instancePositions[2]" == 4
jsonpath "$.steps[51].instancePositions[3]" == 3
jsonpath "$.steps[51].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/format-annotation#/type"
jsonpath "$.steps[51].annotation" == null
jsonpath "$.steps[51].message" == "The value was expected to be of type boolean, or object and it was of type object"
jsonpath "$.steps[51].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[52].type" == "pass"
jsonpath "$.steps[52].name" == "ControlJump"
jsonpath "$.steps[52].evaluatePath" == "/$ref/allOf/5/$ref"
jsonpath "$.steps[52].instanceLocation" == ""
jsonpath "$.steps[52].instancePositions" count == 4
jsonpath "$.steps[52].instancePositions[0]" == 2
jsonpath "$.steps[52].instancePositions[1]" == 3
jsonpath "$.steps[52].instancePositions[2]" == 4
jsonpath "$.steps[52].instancePositions[3]" == 3
jsonpath "$.steps[52].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/5/$ref"
jsonpath "$.steps[52].annotation" == null
jsonpath "$.steps[52].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[52].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[53].type" == "push"
jsonpath "$.steps[53].name" == "ControlJump"
jsonpath "$.steps[53].evaluatePath" == "/$ref/allOf/6/$ref"
jsonpath "$.steps[53].instanceLocation" == ""
jsonpath "$.steps[53].instancePositions" count == 4
jsonpath "$.steps[53].instancePositions[0]" == 2
jsonpath "$.steps[53].instancePositions[1]" == 3
jsonpath "$.steps[53].instancePositions[2]" == 4
jsonpath "$.steps[53].instancePositions[3]" == 3
jsonpath "$.steps[53].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/6/$ref"
jsonpath "$.steps[53].annotation" == null
jsonpath "$.steps[53].message" == null
jsonpath "$.steps[53].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[54].type" == "pass"
jsonpath "$.steps[54].name" == "AnnotationEmit"
jsonpath "$.steps[54].evaluatePath" == "/$ref/allOf/6/$ref/title"
jsonpath "$.steps[54].instanceLocation" == ""
jsonpath "$.steps[54].instancePositions" count == 4
jsonpath "$.steps[54].instancePositions[0]" == 2
jsonpath "$.steps[54].instancePositions[1]" == 3
jsonpath "$.steps[54].instancePositions[2]" == 4
jsonpath "$.steps[54].instancePositions[3]" == 3
jsonpath "$.steps[54].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/content#/title"
jsonpath "$.steps[54].annotation" == "Content vocabulary meta-schema"
jsonpath "$.steps[54].message" == "The title of the instance was \"Content vocabulary meta-schema\""
jsonpath "$.steps[54].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[55].type" == "push"
jsonpath "$.steps[55].name" == "LogicalWhenType"
jsonpath "$.steps[55].evaluatePath" == "/$ref/allOf/6/$ref/properties"
jsonpath "$.steps[55].instanceLocation" == ""
jsonpath "$.steps[55].instancePositions" count == 4
jsonpath "$.steps[55].instancePositions[0]" == 2
jsonpath "$.steps[55].instancePositions[1]" == 3
jsonpath "$.steps[55].instancePositions[2]" == 4
jsonpath "$.steps[55].instancePositions[3]" == 3
jsonpath "$.steps[55].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/content#/properties"
jsonpath "$.steps[55].annotation" == null
jsonpath "$.steps[55].message" == null
jsonpath "$.steps[55].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[56].type" == "pass"
jsonpath "$.steps[56].name" == "LogicalWhenType"
jsonpath "$.steps[56].evaluatePath" == "/$ref/allOf/6/$ref/properties"
jsonpath "$.steps[56].instanceLocation" == ""
jsonpath "$.steps[56].instancePositions" count == 4
jsonpath "$.steps[56].instancePositions[0]" == 2
jsonpath "$.steps[56].instancePositions[1]" == 3
jsonpath "$.steps[56].instancePositions[2]" == 4
jsonpath "$.steps[56].instancePositions[3]" == 3
jsonpath "$.steps[56].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/content#/properties"
jsonpath "$.steps[56].annotation" == null
jsonpath "$.steps[56].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[56].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[57].type" == "push"
jsonpath "$.steps[57].name" == "AssertionTypeAny"
jsonpath "$.steps[57].evaluatePath" == "/$ref/allOf/6/$ref/type"
jsonpath "$.steps[57].instanceLocation" == ""
jsonpath "$.steps[57].instancePositions" count == 4
jsonpath "$.steps[57].instancePositions[0]" == 2
jsonpath "$.steps[57].instancePositions[1]" == 3
jsonpath "$.steps[57].instancePositions[2]" == 4
jsonpath "$.steps[57].instancePositions[3]" == 3
jsonpath "$.steps[57].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/content#/type"
jsonpath "$.steps[57].annotation" == null
jsonpath "$.steps[57].message" == null
jsonpath "$.steps[57].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[58].type" == "pass"
jsonpath "$.steps[58].name" == "AssertionTypeAny"
jsonpath "$.steps[58].evaluatePath" == "/$ref/allOf/6/$ref/type"
jsonpath "$.steps[58].instanceLocation" == ""
jsonpath "$.steps[58].instancePositions" count == 4
jsonpath "$.steps[58].instancePositions[0]" == 2
jsonpath "$.steps[58].instancePositions[1]" == 3
jsonpath "$.steps[58].instancePositions[2]" == 4
jsonpath "$.steps[58].instancePositions[3]" == 3
jsonpath "$.steps[58].keywordLocation" == "https://json-schema.org/draft/2020-12/meta/content#/type"
jsonpath "$.steps[58].annotation" == null
jsonpath "$.steps[58].message" == "The value was expected to be of type boolean, or object and it was of type object"
jsonpath "$.steps[58].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[59].type" == "pass"
jsonpath "$.steps[59].name" == "ControlJump"
jsonpath "$.steps[59].evaluatePath" == "/$ref/allOf/6/$ref"
jsonpath "$.steps[59].instanceLocation" == ""
jsonpath "$.steps[59].instancePositions" count == 4
jsonpath "$.steps[59].instancePositions[0]" == 2
jsonpath "$.steps[59].instancePositions[1]" == 3
jsonpath "$.steps[59].instancePositions[2]" == 4
jsonpath "$.steps[59].instancePositions[3]" == 3
jsonpath "$.steps[59].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf/6/$ref"
jsonpath "$.steps[59].annotation" == null
jsonpath "$.steps[59].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[59].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[60].type" == "pass"
jsonpath "$.steps[60].name" == "LogicalAnd"
jsonpath "$.steps[60].evaluatePath" == "/$ref/allOf"
jsonpath "$.steps[60].instanceLocation" == ""
jsonpath "$.steps[60].instancePositions" count == 4
jsonpath "$.steps[60].instancePositions[0]" == 2
jsonpath "$.steps[60].instancePositions[1]" == 3
jsonpath "$.steps[60].instancePositions[2]" == 4
jsonpath "$.steps[60].instancePositions[3]" == 3
jsonpath "$.steps[60].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/allOf"
jsonpath "$.steps[60].annotation" == null
jsonpath "$.steps[60].message" == "The object value was expected to validate against the 7 given subschemas"
jsonpath "$.steps[60].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[61].type" == "pass"
jsonpath "$.steps[61].name" == "AnnotationEmit"
jsonpath "$.steps[61].evaluatePath" == "/$ref/title"
jsonpath "$.steps[61].instanceLocation" == ""
jsonpath "$.steps[61].instancePositions" count == 4
jsonpath "$.steps[61].instancePositions[0]" == 2
jsonpath "$.steps[61].instancePositions[1]" == 3
jsonpath "$.steps[61].instancePositions[2]" == 4
jsonpath "$.steps[61].instancePositions[3]" == 3
jsonpath "$.steps[61].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/title"
jsonpath "$.steps[61].annotation" == "Core and Validation specifications meta-schema"
jsonpath "$.steps[61].message" == "The title of the instance was \"Core and Validation specifications meta-schema\""
jsonpath "$.steps[61].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"
jsonpath "$.steps[62].type" == "push"
jsonpath "$.steps[62].name" == "LogicalWhenType"
jsonpath "$.steps[62].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[62].instanceLocation" == ""
jsonpath "$.steps[62].instancePositions" count == 4
jsonpath "$.steps[62].instancePositions[0]" == 2
jsonpath "$.steps[62].instancePositions[1]" == 3
jsonpath "$.steps[62].instancePositions[2]" == 4
jsonpath "$.steps[62].instancePositions[3]" == 3
jsonpath "$.steps[62].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/properties"
jsonpath "$.steps[62].annotation" == null
jsonpath "$.steps[62].message" == null
jsonpath "$.steps[62].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[63].type" == "pass"
jsonpath "$.steps[63].name" == "LogicalWhenType"
jsonpath "$.steps[63].evaluatePath" == "/$ref/properties"
jsonpath "$.steps[63].instanceLocation" == ""
jsonpath "$.steps[63].instancePositions" count == 4
jsonpath "$.steps[63].instancePositions[0]" == 2
jsonpath "$.steps[63].instancePositions[1]" == 3
jsonpath "$.steps[63].instancePositions[2]" == 4
jsonpath "$.steps[63].instancePositions[3]" == 3
jsonpath "$.steps[63].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/properties"
jsonpath "$.steps[63].annotation" == null
jsonpath "$.steps[63].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[63].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[64].type" == "push"
jsonpath "$.steps[64].name" == "AssertionTypeAny"
jsonpath "$.steps[64].evaluatePath" == "/$ref/type"
jsonpath "$.steps[64].instanceLocation" == ""
jsonpath "$.steps[64].instancePositions" count == 4
jsonpath "$.steps[64].instancePositions[0]" == 2
jsonpath "$.steps[64].instancePositions[1]" == 3
jsonpath "$.steps[64].instancePositions[2]" == 4
jsonpath "$.steps[64].instancePositions[3]" == 3
jsonpath "$.steps[64].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/type"
jsonpath "$.steps[64].annotation" == null
jsonpath "$.steps[64].message" == null
jsonpath "$.steps[64].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[65].type" == "pass"
jsonpath "$.steps[65].name" == "AssertionTypeAny"
jsonpath "$.steps[65].evaluatePath" == "/$ref/type"
jsonpath "$.steps[65].instanceLocation" == ""
jsonpath "$.steps[65].instancePositions" count == 4
jsonpath "$.steps[65].instancePositions[0]" == 2
jsonpath "$.steps[65].instancePositions[1]" == 3
jsonpath "$.steps[65].instancePositions[2]" == 4
jsonpath "$.steps[65].instancePositions[3]" == 3
jsonpath "$.steps[65].keywordLocation" == "https://json-schema.org/draft/2020-12/schema#/type"
jsonpath "$.steps[65].annotation" == null
jsonpath "$.steps[65].message" == "The value was expected to be of type boolean, or object and it was of type object"
jsonpath "$.steps[65].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[66].type" == "pass"
jsonpath "$.steps[66].name" == "ControlJump"
jsonpath "$.steps[66].evaluatePath" == "/$ref"
jsonpath "$.steps[66].instanceLocation" == ""
jsonpath "$.steps[66].instancePositions" count == 4
jsonpath "$.steps[66].instancePositions[0]" == 2
jsonpath "$.steps[66].instancePositions[1]" == 3
jsonpath "$.steps[66].instancePositions[2]" == 4
jsonpath "$.steps[66].instancePositions[3]" == 3
jsonpath "$.steps[66].keywordLocation" == "#/$ref"
jsonpath "$.steps[66].annotation" == null
jsonpath "$.steps[66].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[66].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"

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

# Dynamic references, which resolve against the supplied schema's own scope
POST {{base}}/self/v1/api/playground/schemas/trace
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
jsonpath "$.steps" count == 11
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "LoopItemsFrom"
jsonpath "$.steps[0].evaluatePath" == "/items"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 4
jsonpath "$.steps[0].instancePositions[3]" == 3
jsonpath "$.steps[0].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "ControlJump"
jsonpath "$.steps[1].evaluatePath" == "/items/$dynamicRef"
jsonpath "$.steps[1].instanceLocation" == "/0"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 3
jsonpath "$.steps[1].instancePositions[1]" == 5
jsonpath "$.steps[1].instancePositions[2]" == 3
jsonpath "$.steps[1].instancePositions[3]" == 7
jsonpath "$.steps[1].keywordLocation" == "https://example.com/d#/items/$dynamicRef"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "AssertionTypeStrict"
jsonpath "$.steps[2].evaluatePath" == "/items/$dynamicRef/type"
jsonpath "$.steps[2].instanceLocation" == "/0"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 3
jsonpath "$.steps[2].instancePositions[1]" == 5
jsonpath "$.steps[2].instancePositions[2]" == 3
jsonpath "$.steps[2].instancePositions[3]" == 7
jsonpath "$.steps[2].keywordLocation" == "https://example.com/d#/$defs/i/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AssertionTypeStrict"
jsonpath "$.steps[3].evaluatePath" == "/items/$dynamicRef/type"
jsonpath "$.steps[3].instanceLocation" == "/0"
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 3
jsonpath "$.steps[3].instancePositions[1]" == 5
jsonpath "$.steps[3].instancePositions[2]" == 3
jsonpath "$.steps[3].instancePositions[3]" == 7
jsonpath "$.steps[3].keywordLocation" == "https://example.com/d#/$defs/i/type"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The value was expected to be of type string"
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "ControlJump"
jsonpath "$.steps[4].evaluatePath" == "/items/$dynamicRef"
jsonpath "$.steps[4].instanceLocation" == "/0"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 3
jsonpath "$.steps[4].instancePositions[1]" == 5
jsonpath "$.steps[4].instancePositions[2]" == 3
jsonpath "$.steps[4].instancePositions[3]" == 7
jsonpath "$.steps[4].keywordLocation" == "https://example.com/d#/items/$dynamicRef"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The string value was expected to validate against the referenced schema"
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/core"
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "LoopItemsFrom"
jsonpath "$.steps[5].evaluatePath" == "/items"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 2
jsonpath "$.steps[5].instancePositions[1]" == 3
jsonpath "$.steps[5].instancePositions[2]" == 4
jsonpath "$.steps[5].instancePositions[3]" == 3
jsonpath "$.steps[5].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "Every item in the array value was expected to validate against the given subschema"
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[6].type" == "push"
jsonpath "$.steps[6].name" == "LogicalWhenArraySizeGreater"
jsonpath "$.steps[6].evaluatePath" == "/items"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].instancePositions[0]" == 2
jsonpath "$.steps[6].instancePositions[1]" == 3
jsonpath "$.steps[6].instancePositions[2]" == 4
jsonpath "$.steps[6].instancePositions[3]" == 3
jsonpath "$.steps[6].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == null
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[7].type" == "pass"
jsonpath "$.steps[7].name" == "AnnotationEmit"
jsonpath "$.steps[7].evaluatePath" == "/items"
jsonpath "$.steps[7].instanceLocation" == ""
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[7].instancePositions[0]" == 2
jsonpath "$.steps[7].instancePositions[1]" == 3
jsonpath "$.steps[7].instancePositions[2]" == 4
jsonpath "$.steps[7].instancePositions[3]" == 3
jsonpath "$.steps[7].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[7].annotation" == true
jsonpath "$.steps[7].message" == "Every item in the array value was successfully validated"
jsonpath "$.steps[7].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[8].type" == "pass"
jsonpath "$.steps[8].name" == "LogicalWhenArraySizeGreater"
jsonpath "$.steps[8].evaluatePath" == "/items"
jsonpath "$.steps[8].instanceLocation" == ""
jsonpath "$.steps[8].instancePositions" count == 4
jsonpath "$.steps[8].instancePositions[0]" == 2
jsonpath "$.steps[8].instancePositions[1]" == 3
jsonpath "$.steps[8].instancePositions[2]" == 4
jsonpath "$.steps[8].instancePositions[3]" == 3
jsonpath "$.steps[8].keywordLocation" == "https://example.com/d#/items"
jsonpath "$.steps[8].annotation" == null
jsonpath "$.steps[8].message" == "The array value contains 1 additional item not described by related keywords"
jsonpath "$.steps[8].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[9].type" == "push"
jsonpath "$.steps[9].name" == "AssertionTypeStrict"
jsonpath "$.steps[9].evaluatePath" == "/type"
jsonpath "$.steps[9].instanceLocation" == ""
jsonpath "$.steps[9].instancePositions" count == 4
jsonpath "$.steps[9].instancePositions[0]" == 2
jsonpath "$.steps[9].instancePositions[1]" == 3
jsonpath "$.steps[9].instancePositions[2]" == 4
jsonpath "$.steps[9].instancePositions[3]" == 3
jsonpath "$.steps[9].keywordLocation" == "https://example.com/d#/type"
jsonpath "$.steps[9].annotation" == null
jsonpath "$.steps[9].message" == null
jsonpath "$.steps[9].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[10].type" == "pass"
jsonpath "$.steps[10].name" == "AssertionTypeStrict"
jsonpath "$.steps[10].evaluatePath" == "/type"
jsonpath "$.steps[10].instanceLocation" == ""
jsonpath "$.steps[10].instancePositions" count == 4
jsonpath "$.steps[10].instancePositions[0]" == 2
jsonpath "$.steps[10].instancePositions[1]" == 3
jsonpath "$.steps[10].instancePositions[2]" == 4
jsonpath "$.steps[10].instancePositions[3]" == 3
jsonpath "$.steps[10].keywordLocation" == "https://example.com/d#/type"
jsonpath "$.steps[10].annotation" == null
jsonpath "$.steps[10].message" == "The value was expected to be of type array"
jsonpath "$.steps[10].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"

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

# An object instance, so the trace locates steps inside it rather than at
# its root
POST {{base}}/self/v1/api/playground/schemas/trace
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
jsonpath "$.steps" count == 7
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "LogicalWhenType"
jsonpath "$.steps[0].evaluatePath" == "/properties"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 2
jsonpath "$.steps[0].instancePositions[1]" == 3
jsonpath "$.steps[0].instancePositions[2]" == 4
jsonpath "$.steps[0].instancePositions[3]" == 3
jsonpath "$.steps[0].keywordLocation" == "#/properties"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "AssertionType"
jsonpath "$.steps[1].evaluatePath" == "/properties/a/type"
jsonpath "$.steps[1].instanceLocation" == "/a"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 3
jsonpath "$.steps[1].instancePositions[1]" == 5
jsonpath "$.steps[1].instancePositions[2]" == 3
jsonpath "$.steps[1].instancePositions[3]" == 10
jsonpath "$.steps[1].keywordLocation" == "#/properties/a/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "AssertionType"
jsonpath "$.steps[2].evaluatePath" == "/properties/a/type"
jsonpath "$.steps[2].instanceLocation" == "/a"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 3
jsonpath "$.steps[2].instancePositions[1]" == 5
jsonpath "$.steps[2].instancePositions[2]" == 3
jsonpath "$.steps[2].instancePositions[3]" == 10
jsonpath "$.steps[2].keywordLocation" == "#/properties/a/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The value was expected to be of type integer"
jsonpath "$.steps[2].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AnnotationEmitWrapped"
jsonpath "$.steps[3].evaluatePath" == "/properties"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 2
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 4
jsonpath "$.steps[3].instancePositions[3]" == 3
jsonpath "$.steps[3].keywordLocation" == "#/properties"
jsonpath "$.steps[3].annotation" == "a"
jsonpath "$.steps[3].message" == "The object property \"a\" successfully validated against its property subschema"
jsonpath "$.steps[3].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "LogicalWhenType"
jsonpath "$.steps[4].evaluatePath" == "/properties"
jsonpath "$.steps[4].instanceLocation" == ""
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 2
jsonpath "$.steps[4].instancePositions[1]" == 3
jsonpath "$.steps[4].instancePositions[2]" == 4
jsonpath "$.steps[4].instancePositions[3]" == 3
jsonpath "$.steps[4].keywordLocation" == "#/properties"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The object value was expected to validate against the single defined property subschema"
jsonpath "$.steps[4].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/applicator"
jsonpath "$.steps[5].type" == "push"
jsonpath "$.steps[5].name" == "AssertionTypeStrict"
jsonpath "$.steps[5].evaluatePath" == "/type"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 2
jsonpath "$.steps[5].instancePositions[1]" == 3
jsonpath "$.steps[5].instancePositions[2]" == 4
jsonpath "$.steps[5].instancePositions[3]" == 3
jsonpath "$.steps[5].keywordLocation" == "#/type"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == null
jsonpath "$.steps[5].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"
jsonpath "$.steps[6].type" == "pass"
jsonpath "$.steps[6].name" == "AssertionTypeStrict"
jsonpath "$.steps[6].evaluatePath" == "/type"
jsonpath "$.steps[6].instanceLocation" == ""
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].instancePositions[0]" == 2
jsonpath "$.steps[6].instancePositions[1]" == 3
jsonpath "$.steps[6].instancePositions[2]" == 4
jsonpath "$.steps[6].instancePositions[3]" == 3
jsonpath "$.steps[6].keywordLocation" == "#/type"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == "The value was expected to be of type object"
jsonpath "$.steps[6].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/validation"

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

# A null instance, which is a value like any other
POST {{base}}/self/v1/api/playground/schemas/trace
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
jsonpath "$.steps[0].instancePositions[3]" == 18
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
jsonpath "$.steps[1].instancePositions[3]" == 18
jsonpath "$.steps[1].keywordLocation" == "#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == "The value was expected to be of type null"
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

# A body that is not the envelope this route accepts
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "hello world"
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
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "The request body does not match the expected schema"

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

# A body that is JSON but not an object
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
[
  1,
  2
]
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
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "The request body does not match the expected schema"

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

# An envelope carrying something this route does not accept
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema"
  },
  "extra": 1
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
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "The request body does not match the expected schema"

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

# A boolean is a schema, but it declares no dialect, so this route does
# not take one
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": true
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
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "The request body does not match the expected schema"

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

# A schema that declares no dialect at all, which the request schema
# refuses before anything is compiled
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "type": "string"
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
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "The request body does not match the expected schema"

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

# A dialect that is not even a URI, refused the same way
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "not a uri",
    "type": "string"
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
jsonpath "$.type" == "urn:sourcemeta:one:invalid-request"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "The request body does not match the expected schema"

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

# A schema carrying a regular expression that cannot be compiled
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "pattern": "["
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
jsonpath "$.type" == "urn:sourcemeta:one:invalid-schema"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "The supplied schema could not be compiled"

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

# A schema whose keyword carries the wrong kind of value entirely
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "type": 123
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
jsonpath "$.type" == "urn:sourcemeta:one:invalid-schema"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "The supplied schema could not be compiled"

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

# A dialect this instance does not know. A dialect is a reference like any
# other here, so naming one that resolves nowhere is answered as such
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://example.com/not-a-dialect"
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
jsonpath "$.reference" == "https://example.com/not-a-dialect"
jsonpath "$.schemaLocation" == "/$schema"

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

# A reference to another origin entirely. This registry is sovereign over
# its own namespace and resolves nothing beyond it
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "https://example.org/elsewhere/schema"
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
jsonpath "$.reference" == "https://example.org/elsewhere/schema"
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

# A reference into this instance that names nothing, answered exactly as
# the foreign one is
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/test/nothing/here"
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
jsonpath "$.reference" == "{{base}}/test/nothing/here"
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

# A reference that tries to climb out of the schema tree
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$ref": "{{base}}/../../../etc/passwd"
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
jsonpath "$.reference" == "{{base}}/etc/passwd"
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

# A reference carrying a fragment, which resolves by its base but is
# named back as the caller wrote it
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "properties": {
      "a": {
        "$ref": "https://example.org/z#/$defs/x"
      }
    }
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
jsonpath "$.reference" == "https://example.org/z#/$defs/x"
jsonpath "$.schemaLocation" == "/properties/a/$ref"

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

# A resource embedded in the supplied schema declaring a dialect that
# resolves nowhere, located where it sits rather than at the root
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema",
    "$defs": {
      "r": {
        "$id": "https://example.com/r",
        "$schema": "https://example.com/unknown-dialect"
      }
    }
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
jsonpath "$.reference" == "https://example.com/unknown-dialect"
jsonpath "$.schemaLocation" == "/$defs/r/$schema"

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

# Nesting past the depth compilation may descend to
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
file,playground-too-deep.json;
HTTP 422
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
jsonpath "$.type" == "urn:sourcemeta:one:schema-too-complex"
jsonpath "$.title" == "Unprocessable Content"
jsonpath "$.status" == 422
jsonpath "$.detail" == "The supplied schema is too complex to compile on demand, so try a simpler one or add it to the catalog, where no such limit applies"

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

# Nesting far past what the document may carry at all. Framing walks the
# schema before any compiler budget applies, so this is refused ahead of the
# walk rather than by it, and the instance survives to say so
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
file,playground-unwalkable.json;
HTTP 422
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
jsonpath "$.type" == "urn:sourcemeta:one:schema-too-complex"
jsonpath "$.title" == "Unprocessable Content"
jsonpath "$.status" == 422
jsonpath "$.detail" == "The supplied schema is too complex to compile on demand, so try a simpler one or add it to the catalog, where no such limit applies"

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

# And the instance is still answering afterwards
GET {{base}}/self/v1/health
HTTP 200
Cache-Control: no-store
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/

# More frame locations than framing may register, which a schema reaches
# in far fewer bytes than it takes to reach the body cap
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
file,playground-too-many-locations.json;
HTTP 422
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
jsonpath "$.type" == "urn:sourcemeta:one:schema-too-complex"
jsonpath "$.title" == "Unprocessable Content"
jsonpath "$.status" == 422
jsonpath "$.detail" == "The supplied schema is too complex to compile on demand, so try a simpler one or add it to the catalog, where no such limit applies"

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

# A body beyond what this route reads, which is a smaller cap than the one
# the catalog form applies
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
file,playground-oversized.json;
HTTP 413
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
jsonpath "$.type" == "urn:sourcemeta:one:payload-too-large"
jsonpath "$.title" == "Content Too Large"
jsonpath "$.status" == 413
jsonpath "$.detail" == "The request body is too large"

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

# No body at all
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
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
jsonpath "$.type" == "urn:sourcemeta:one:no-instance"
jsonpath "$.title" == "Bad Request"
jsonpath "$.status" == 400
jsonpath "$.detail" == "You must pass an instance to validate against"

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

# An expectation this instance cannot honour, refused before the body is read
POST {{base}}/self/v1/api/playground/schemas/trace
Content-Type: application/json
Expect: something-else
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema"
  }
}
```
HTTP 417
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
jsonpath "$.type" == "urn:sourcemeta:one:expectation-failed"
jsonpath "$.title" == "Expectation Failed"
jsonpath "$.status" == 417
jsonpath "$.detail" == "The Expect header carries an unsupported expectation"

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

# A browser reaching this is told what it may send
OPTIONS {{base}}/self/v1/api/playground/schemas/trace
HTTP 204
Cache-Control: no-store
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 3600
Allow: POST, OPTIONS
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/

# A preflight naming an origin is answered the same way, since this route
# is open to any origin
OPTIONS {{base}}/self/v1/api/playground/schemas/trace
Origin: https://example.com
HTTP 204
Cache-Control: no-store
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
Access-Control-Max-Age: 3600
Allow: POST, OPTIONS
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/

# Methods this route does not serve, each told so with the same Allow
GET {{base}}/self/v1/api/playground/schemas/trace
HTTP 405
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Allow: POST, OPTIONS
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
jsonpath "$.type" == "urn:sourcemeta:one:method-not-allowed"
jsonpath "$.title" == "Method Not Allowed"
jsonpath "$.status" == 405
jsonpath "$.detail" == "This HTTP method is invalid for this URL"

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

#
PUT {{base}}/self/v1/api/playground/schemas/trace
HTTP 405
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Allow: POST, OPTIONS
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
jsonpath "$.type" == "urn:sourcemeta:one:method-not-allowed"
jsonpath "$.title" == "Method Not Allowed"
jsonpath "$.status" == 405
jsonpath "$.detail" == "This HTTP method is invalid for this URL"

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

#
DELETE {{base}}/self/v1/api/playground/schemas/trace
HTTP 405
Cache-Control: no-store
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Allow: POST, OPTIONS
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
jsonpath "$.type" == "urn:sourcemeta:one:method-not-allowed"
jsonpath "$.title" == "Method Not Allowed"
jsonpath "$.status" == 405
jsonpath "$.detail" == "This HTTP method is invalid for this URL"

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

# Tracing against a schema this catalog holds is a separate operation
# under a separate namespace, and is untouched by this one
POST {{base}}/self/v1/api/schemas/trace/test/schemas/string
Content-Type: application/json
```
"Hello World"
```
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
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "AssertionTypeStrict"
jsonpath "$.steps[0].evaluatePath" == "/type"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 1
jsonpath "$.steps[0].instancePositions[1]" == 1
jsonpath "$.steps[0].instancePositions[2]" == 1
jsonpath "$.steps[0].instancePositions[3]" == 13
jsonpath "$.steps[0].keywordLocation" == "{{base}}/test/schemas/string#/type"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 1
jsonpath "$.steps[1].instancePositions[1]" == 1
jsonpath "$.steps[1].instancePositions[2]" == 1
jsonpath "$.steps[1].instancePositions[3]" == 13
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/schemas/string#/type"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == "The value was expected to be of type string"
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"

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

# Naming that operation without a schema stays what it always was, rather
# than quietly becoming this one with a different body contract
POST {{base}}/self/v1/api/schemas/trace
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema"
  }
}
```
HTTP 404
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
jsonpath "$.type" == "urn:sourcemeta:one:not-found"
jsonpath "$.title" == "Not Found"
jsonpath "$.status" == 404
jsonpath "$.detail" == "There is nothing at this URL"

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

# The playground operation is the bare path, so a trailing slash is a
# different URL and this instance holds nothing there
POST {{base}}/self/v1/api/playground/schemas/trace/
Content-Type: application/json
```
{
  "instance": "x",
  "schema": {
    "$schema": "https://json-schema.org/draft/2020-12/schema"
  }
}
```
HTTP 404
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
jsonpath "$.type" == "urn:sourcemeta:one:not-found"
jsonpath "$.title" == "Not Found"
jsonpath "$.status" == 404
jsonpath "$.detail" == "There is nothing at this URL"

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
