OPTIONS {{base}}/self/api/schemas/trace/test/schemas/string
HTTP 204
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 3600

POST {{base}}/self/api/schemas/trace/test/schemas/string
HTTP 400
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.status" == 400
jsonpath "$.title" == "sourcemeta:registry/no-instance"
jsonpath "$.detail" == "You must pass an instance to validate against"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

POST {{base}}/self/api/schemas/trace/test/schemas/string
Content-Type: application/json
"Hello World"
HTTP 200
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
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
jsonpath "$.steps[0].keywordLocation" == "http://localhost:8000/test/schemas/string#/type"
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
jsonpath "$.steps[1].keywordLocation" == "http://localhost:8000/test/schemas/string#/type"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].message" == "The value was expected to be of type string"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/trace/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

POST {{base}}/self/api/schemas/trace/test/no-blaze/string
Content-Type: application/problem+json
"Hello World"
HTTP 405
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.status" == 405
jsonpath "$.title" == "sourcemeta:registry/no-template"
jsonpath "$.detail" == "This schema was not precompiled for schema evaluation"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true
