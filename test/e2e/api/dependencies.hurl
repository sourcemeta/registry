GET {{base}}/example/bundling/single.json?dependencies=1
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$" count == 1
jsonpath "$[0].from" == "{{base}}/example/bundling/single.json"
jsonpath "$[0].to" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[0].at" == "/properties/foo/$ref"

GET {{base}}/example/v2.0/schema.json?dependencies=1
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$" count == 0
