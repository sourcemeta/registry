OPTIONS {{base}}/self/v1/api/schemas/trace/test/schemas/string
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

POST {{base}}/self/v1/api/schemas/trace/test/schemas/string
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
jsonpath "$.status" == 400
jsonpath "$.type" == "urn:sourcemeta:one:no-instance"
jsonpath "$.title" == "Bad Request"
jsonpath "$.detail" == "You must pass an instance to validate against"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/api/schemas/trace/test/schemas/string
Content-Type: application/json
"Hello World"
HTTP 200
Cache-Control: no-store
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
jsonpath "$.steps[0].instancePositions[0]" == 1
jsonpath "$.steps[0].instancePositions[1]" == 1
jsonpath "$.steps[0].instancePositions[2]" == 1
jsonpath "$.steps[0].instancePositions[3]" == 13
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].keywordLocation" == "{{base}}/test/schemas/string#/type"
jsonpath "$.steps[0].name" == "AssertionTypeStrict"
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].evaluatePath" == "/type"
jsonpath "$.steps[1].instanceLocation" == ""
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 1
jsonpath "$.steps[1].instancePositions[1]" == 1
jsonpath "$.steps[1].instancePositions[2]" == 1
jsonpath "$.steps[1].instancePositions[3]" == 13
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/schemas/string#/type"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].message" == "The value was expected to be of type string"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/api/schemas/trace/test/schemas/annotation
Content-Type: application/json
"Hello World"
HTTP 200
Cache-Control: no-store
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
jsonpath "$.steps" count == 1
jsonpath "$.steps[0].type" == "pass"
jsonpath "$.steps[0].name" == "AnnotationEmit"
jsonpath "$.steps[0].evaluatePath" == "/title"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 1
jsonpath "$.steps[0].instancePositions[1]" == 1
jsonpath "$.steps[0].instancePositions[2]" == 1
jsonpath "$.steps[0].instancePositions[3]" == 13
jsonpath "$.steps[0].keywordLocation" == "{{base}}/test/schemas/annotation#/title"
jsonpath "$.steps[0].annotation" == "Annotation value"
jsonpath "$.steps[0].message" == "The title of the instance was \"Annotation value\""
jsonpath "$.steps[0].vocabulary" == "https://json-schema.org/draft/2020-12/vocab/meta-data"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/api/schemas/trace/test/bundling/single
Content-Type: application/json
{ "foo": 42 }
HTTP 200
Cache-Control: no-store
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
jsonpath "$.steps" count == 6
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "LogicalWhenType"
jsonpath "$.steps[0].evaluatePath" == "/properties"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 1
jsonpath "$.steps[0].instancePositions[1]" == 1
jsonpath "$.steps[0].instancePositions[2]" == 1
jsonpath "$.steps[0].instancePositions[3]" == 13
jsonpath "$.steps[0].keywordLocation" == "{{base}}/test/bundling/single#/properties"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "ControlJump"
jsonpath "$.steps[1].evaluatePath" == "/properties/foo/$ref"
jsonpath "$.steps[1].instanceLocation" == "/foo"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 1
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 1
jsonpath "$.steps[1].instancePositions[3]" == 11
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "AssertionType"
jsonpath "$.steps[2].evaluatePath" == "/properties/foo/$ref/type"
jsonpath "$.steps[2].instanceLocation" == "/foo"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 1
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 1
jsonpath "$.steps[2].instancePositions[3]" == 11
jsonpath "$.steps[2].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "AssertionType"
jsonpath "$.steps[3].evaluatePath" == "/properties/foo/$ref/type"
jsonpath "$.steps[3].instanceLocation" == "/foo"
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 1
jsonpath "$.steps[3].instancePositions[1]" == 3
jsonpath "$.steps[3].instancePositions[2]" == 1
jsonpath "$.steps[3].instancePositions[3]" == 11
jsonpath "$.steps[3].keywordLocation" == "{{base}}/test/v2.0/schema#/type"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The value was expected to be of type integer"
jsonpath "$.steps[3].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[4].type" == "pass"
jsonpath "$.steps[4].name" == "ControlJump"
jsonpath "$.steps[4].evaluatePath" == "/properties/foo/$ref"
jsonpath "$.steps[4].instanceLocation" == "/foo"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].instancePositions[0]" == 1
jsonpath "$.steps[4].instancePositions[1]" == 3
jsonpath "$.steps[4].instancePositions[2]" == 1
jsonpath "$.steps[4].instancePositions[3]" == 11
jsonpath "$.steps[4].keywordLocation" == "{{base}}/test/bundling/single#/properties/foo/$ref"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == "The integer value was expected to validate against the referenced schema"
jsonpath "$.steps[4].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "LogicalWhenType"
jsonpath "$.steps[5].evaluatePath" == "/properties"
jsonpath "$.steps[5].instanceLocation" == ""
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].instancePositions[0]" == 1
jsonpath "$.steps[5].instancePositions[1]" == 1
jsonpath "$.steps[5].instancePositions[2]" == 1
jsonpath "$.steps[5].instancePositions[3]" == 13
jsonpath "$.steps[5].keywordLocation" == "{{base}}/test/bundling/single#/properties"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "The object value was expected to validate against the single defined property subschema"
jsonpath "$.steps[5].vocabulary" == "http://json-schema.org/draft-07/schema#"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/api/schemas/trace/test/bundling/double
Content-Type: application/json
{ "foo": 42 }
HTTP 200
Cache-Control: no-store
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
jsonpath "$.steps" count == 4
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "LogicalWhenType"
jsonpath "$.steps[0].evaluatePath" == "/properties"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 1
jsonpath "$.steps[0].instancePositions[1]" == 1
jsonpath "$.steps[0].instancePositions[2]" == 1
jsonpath "$.steps[0].instancePositions[3]" == 13
jsonpath "$.steps[0].keywordLocation" == "{{base}}/test/bundling/double#/properties"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "ControlJump"
jsonpath "$.steps[1].evaluatePath" == "/properties/foo/$ref"
jsonpath "$.steps[1].instanceLocation" == "/foo"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 1
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 1
jsonpath "$.steps[1].instancePositions[3]" == 11
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/bundling/double#/properties/foo/$ref"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[2].type" == "pass"
jsonpath "$.steps[2].name" == "ControlJump"
jsonpath "$.steps[2].evaluatePath" == "/properties/foo/$ref"
jsonpath "$.steps[2].instanceLocation" == "/foo"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].instancePositions[0]" == 1
jsonpath "$.steps[2].instancePositions[1]" == 3
jsonpath "$.steps[2].instancePositions[2]" == 1
jsonpath "$.steps[2].instancePositions[3]" == 11
jsonpath "$.steps[2].keywordLocation" == "{{base}}/test/bundling/double#/properties/foo/$ref"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == "The integer value was expected to validate against the referenced schema"
jsonpath "$.steps[2].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "LogicalWhenType"
jsonpath "$.steps[3].evaluatePath" == "/properties"
jsonpath "$.steps[3].instanceLocation" == ""
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].instancePositions[0]" == 1
jsonpath "$.steps[3].instancePositions[1]" == 1
jsonpath "$.steps[3].instancePositions[2]" == 1
jsonpath "$.steps[3].instancePositions[3]" == 13
jsonpath "$.steps[3].keywordLocation" == "{{base}}/test/bundling/double#/properties"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[3].vocabulary" == "http://json-schema.org/draft-07/schema#"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/api/schemas/trace/test/bundling/double
Content-Type: application/json
{ "bar": {} }
HTTP 200
Cache-Control: no-store
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
jsonpath "$.steps" count == 8
jsonpath "$.steps[0].type" == "push"
jsonpath "$.steps[0].name" == "LogicalWhenType"
jsonpath "$.steps[0].evaluatePath" == "/properties"
jsonpath "$.steps[0].instanceLocation" == ""
jsonpath "$.steps[0].instancePositions" count == 4
jsonpath "$.steps[0].instancePositions[0]" == 1
jsonpath "$.steps[0].instancePositions[1]" == 1
jsonpath "$.steps[0].instancePositions[2]" == 1
jsonpath "$.steps[0].instancePositions[3]" == 13
jsonpath "$.steps[0].keywordLocation" == "{{base}}/test/bundling/double#/properties"
jsonpath "$.steps[0].annotation" == null
jsonpath "$.steps[0].message" == null
jsonpath "$.steps[0].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].type" == "push"
jsonpath "$.steps[1].name" == "ControlJump"
jsonpath "$.steps[1].evaluatePath" == "/properties/bar/$ref"
jsonpath "$.steps[1].instanceLocation" == "/bar"
jsonpath "$.steps[1].instancePositions" count == 4
jsonpath "$.steps[1].instancePositions[0]" == 1
jsonpath "$.steps[1].instancePositions[1]" == 3
jsonpath "$.steps[1].instancePositions[2]" == 1
jsonpath "$.steps[1].instancePositions[3]" == 11
jsonpath "$.steps[1].keywordLocation" == "{{base}}/test/bundling/double#/properties/bar/$ref"
jsonpath "$.steps[1].annotation" == null
jsonpath "$.steps[1].message" == null
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[2].type" == "push"
jsonpath "$.steps[2].name" == "LoopPropertiesMatch"
jsonpath "$.steps[2].evaluatePath" == "/properties/bar/$ref/properties"
jsonpath "$.steps[2].instanceLocation" == "/bar"
jsonpath "$.steps[2].instancePositions" count == 4
jsonpath "$.steps[2].keywordLocation" == "http://json-schema.org/draft-07/schema#/properties"
jsonpath "$.steps[2].annotation" == null
jsonpath "$.steps[2].message" == null
jsonpath "$.steps[2].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[3].type" == "pass"
jsonpath "$.steps[3].name" == "LoopPropertiesMatch"
jsonpath "$.steps[3].evaluatePath" == "/properties/bar/$ref/properties"
jsonpath "$.steps[3].instanceLocation" == "/bar"
jsonpath "$.steps[3].instancePositions" count == 4
jsonpath "$.steps[3].keywordLocation" == "http://json-schema.org/draft-07/schema#/properties"
jsonpath "$.steps[3].annotation" == null
jsonpath "$.steps[3].message" == "The object value was expected to validate against the 46 defined properties subschemas"
jsonpath "$.steps[3].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[4].type" == "push"
jsonpath "$.steps[4].name" == "AssertionTypeAny"
jsonpath "$.steps[4].evaluatePath" == "/properties/bar/$ref/type"
jsonpath "$.steps[4].instanceLocation" == "/bar"
jsonpath "$.steps[4].instancePositions" count == 4
jsonpath "$.steps[4].keywordLocation" == "http://json-schema.org/draft-07/schema#/type"
jsonpath "$.steps[4].annotation" == null
jsonpath "$.steps[4].message" == null
jsonpath "$.steps[4].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[5].type" == "pass"
jsonpath "$.steps[5].name" == "AssertionTypeAny"
jsonpath "$.steps[5].evaluatePath" == "/properties/bar/$ref/type"
jsonpath "$.steps[5].instanceLocation" == "/bar"
jsonpath "$.steps[5].instancePositions" count == 4
jsonpath "$.steps[5].keywordLocation" == "http://json-schema.org/draft-07/schema#/type"
jsonpath "$.steps[5].annotation" == null
jsonpath "$.steps[5].message" == "The value was expected to be of type boolean, or object and it was of type object"
jsonpath "$.steps[5].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[6].type" == "pass"
jsonpath "$.steps[6].name" == "ControlJump"
jsonpath "$.steps[6].evaluatePath" == "/properties/bar/$ref"
jsonpath "$.steps[6].instanceLocation" == "/bar"
jsonpath "$.steps[6].instancePositions" count == 4
jsonpath "$.steps[6].keywordLocation" == "{{base}}/test/bundling/double#/properties/bar/$ref"
jsonpath "$.steps[6].annotation" == null
jsonpath "$.steps[6].message" == "The object value was expected to validate against the referenced schema"
jsonpath "$.steps[6].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[7].type" == "pass"
jsonpath "$.steps[7].name" == "LogicalWhenType"
jsonpath "$.steps[7].evaluatePath" == "/properties"
jsonpath "$.steps[7].instanceLocation" == ""
jsonpath "$.steps[7].instancePositions" count == 4
jsonpath "$.steps[7].instancePositions[0]" == 1
jsonpath "$.steps[7].instancePositions[1]" == 1
jsonpath "$.steps[7].instancePositions[2]" == 1
jsonpath "$.steps[7].instancePositions[3]" == 13
jsonpath "$.steps[7].keywordLocation" == "{{base}}/test/bundling/double#/properties"
jsonpath "$.steps[7].annotation" == null
jsonpath "$.steps[7].message" == "The object value was expected to validate against the defined properties subschemas"
jsonpath "$.steps[7].vocabulary" == "http://json-schema.org/draft-07/schema#"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true

POST {{base}}/self/v1/api/schemas/trace/test/no-blaze/string
Content-Type: application/problem+json
"Hello World"
HTTP 405
Cache-Control: no-store
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Allow: OPTIONS
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
jsonpath "$.status" == 405
jsonpath "$.type" == "urn:sourcemeta:one:no-schema-template"
jsonpath "$.title" == "Method Not Allowed"
jsonpath "$.detail" == "This schema was not precompiled for schema evaluation"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true
