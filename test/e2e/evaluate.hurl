OPTIONS {{base}}/example/schemas/string.json
HTTP 204
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: POST, OPTIONS
Access-Control-Allow-Headers: Content-Type
Access-Control-Max-Age: 3600

POST {{base}}/example/schemas/string.json
HTTP 400
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]  
jsonpath "$.code" == 400
jsonpath "$.error" == "no-instance"
jsonpath "$.message" == "You must pass an instance to validate against"

POST {{base}}/example/schemas/string.json
Content-Type: application/json
"Hello World"
HTTP 200
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.valid" == true

POST {{base}}/example/schemas/string.json
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

POST {{base}}/example/schemas/string.json?trace=1
Content-Type: application/json
"Hello World"
HTTP 200
Access-Control-Allow-Origin: *
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
jsonpath "$.steps[0].keywordLocation" == "http://localhost:8000/example/schemas/string.json#/type"
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
jsonpath "$.steps[1].keywordLocation" == "http://localhost:8000/example/schemas/string.json#/type"
jsonpath "$.steps[1].name" == "AssertionTypeStrict"
jsonpath "$.steps[1].type" == "pass"
jsonpath "$.steps[1].vocabulary" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.steps[1].message" == "The value was expected to be of type string"

POST {{base}}/no-blaze/string.json
Content-Type: application/json
"Hello World"
HTTP 405
Access-Control-Allow-Origin: *
[Asserts]  
jsonpath "$.code" == 405
jsonpath "$.error" == "no-template"
jsonpath "$.message" == "This schema was not precompiled for schema evaluation"
