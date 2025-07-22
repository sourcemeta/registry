GET {{base}}/example/bundling/single.json?dependencies=1
Accept: application/json
HTTP 200
Content-Type: application/json
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
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$" count == 0

GET {{base}}/example/v2.0?positions=1
Accept: text/html
HTTP 200
