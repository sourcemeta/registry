OPTIONS {{base}}/self/api/schemas/evaluate/example/schemas/string
HTTP 204
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 3600

POST {{base}}/self/api/schemas/evaluate/example/schemas/string
HTTP 400
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 400
jsonpath "$.error" == "no-instance"
jsonpath "$.message" == "You must pass an instance to validate against"

POST {{base}}/self/api/schemas/evaluate/example/schemas/string
Content-Type: application/json
"Hello World"
HTTP 200
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.valid" == true

POST {{base}}/self/api/schemas/evaluate/example/schemas/string
Content-Type: application/json
1234
HTTP 200
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.valid" == false
jsonpath "$.errors" count == 1
jsonpath "$.errors[0].absoluteKeywordLocation" == "{{base}}/example/schemas/string.json#/type"
jsonpath "$.errors[0].error" == "The value was expected to be of type string but it was of type integer"
jsonpath "$.errors[0].instanceLocation" == ""
jsonpath "$.errors[0].keywordLocation" == "/type"

POST {{base}}/self/api/schemas/evaluate/no-blaze/string
Content-Type: application/json
"Hello World"
HTTP 405
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 405
jsonpath "$.error" == "no-template"
jsonpath "$.message" == "This schema was not precompiled for schema evaluation"
