POST {{base}}/example/schemas/string.json
HTTP 400
Content-Type: application/json
[Asserts]  
jsonpath "$.code" == 400
jsonpath "$.error" == "no-instance"
jsonpath "$.message" == "You must pass an instance to validate against"

POST {{base}}/example/schemas/string.json
Content-Type: application/json
"Hello World"
HTTP 200
[Asserts]
jsonpath "$.valid" == true

POST {{base}}/example/schemas/string.json
Content-Type: application/json
1234
HTTP 200
[Asserts]
jsonpath "$.valid" == false
jsonpath "$.errors" count == 1
jsonpath "$.errors[0].absoluteKeywordLocation" == "{{base}}/example/schemas/string.json#/type"
jsonpath "$.errors[0].error" == "The value was expected to be of type string but it was of type integer"
jsonpath "$.errors[0].instanceLocation" == ""
jsonpath "$.errors[0].keywordLocation" == "/type"
