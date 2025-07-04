GET {{base}}/schemas/doc/.period.json
HTTP 404
Content-Type: application/json
[Captures]
current_request_id: header "X-Request-id"
[Asserts]  
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"
jsonpath "$.request" == "{{current_request_id}}"
