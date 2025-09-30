GET {{base}}/self/api/schemas/search
HTTP 400
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.status" == 400
jsonpath "$.title" == "sourcemeta:registry/missing-query"
jsonpath "$.detail" == "You must provide a query parameter to search for"

GET {{base}}/self/api/schemas/search?q=bundling
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$" count == 2
jsonpath "$[0].path" == "/test/bundling/single"
jsonpath "$[0].title" == "Bundling"
jsonpath "$[0].description" == "A bundling example"
jsonpath "$[1].path" == "/test/bundling/double"
jsonpath "$[1].title" == ""
jsonpath "$[1].description" == ""
