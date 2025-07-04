# Invalid method on found
POST {{base}}/example/schemas/string.json
HTTP 405
Content-Type: application/json
[Captures]
current_request_id: header "X-Request-id"
[Asserts]  
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"
jsonpath "$.request" == "{{current_request_id}}"

# Invalid method on not found
POST {{base}}/example/schemas/xxx.json
HTTP 404
Content-Type: application/json
[Captures]
current_request_id: header "X-Request-id"
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"
jsonpath "$.request" == "{{current_request_id}}"
