GET {{base}}/schemas/doc/.period.json
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]  
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"
