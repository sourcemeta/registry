OPTIONS {{base}}/self/api/schemas/evaluate/test/schemas/string
HTTP 204
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 3600

POST {{base}}/self/api/schemas/evaluate/test/schemas/string
HTTP 400
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.status" == 400
jsonpath "$.title" == "sourcemeta:registry/no-instance"
jsonpath "$.detail" == "You must pass an instance to validate against"

POST {{base}}/self/api/schemas/evaluate/test/schemas/string
Content-Type: application/json
1234
HTTP 200
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.valid" == false
jsonpath "$.errors" count == 1
jsonpath "$.errors[0].absoluteKeywordLocation" == "{{base}}/test/schemas/string#/type"
jsonpath "$.errors[0].error" == "The value was expected to be of type string but it was of type integer"
jsonpath "$.errors[0].instanceLocation" == ""
jsonpath "$.errors[0].keywordLocation" == "/type"
