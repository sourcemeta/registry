GET {{base}}/self/api/schemas/dependencies/test/bundling/single
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$" count == 1
jsonpath "$[0].from" == "{{base}}/test/bundling/single"
jsonpath "$[0].to" == "{{base}}/test/v2.0/schema"
jsonpath "$[0].at" == "/properties/foo/$ref"
