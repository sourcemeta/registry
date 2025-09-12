GET {{base}}/test/doc/string-1.html
HTTP 404
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.status" == 404
jsonpath "$.title" == "sourcemeta:registry/not-found"
jsonpath "$.detail" == "There is nothing at this URL"
