OPTIONS {{base}}
HTTP 405

GET {{base}}
Accept: text/html
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Sourcemeta Schemas"
header "Access-Control-Allow-Origin" not exists

# This is a Safari Accept header
GET {{base}}/test/doc
Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "A sample schema folder"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/doc
Accept: text/html
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "A sample schema folder"
header "Access-Control-Allow-Origin" not exists

# Without an explicit HTML accept, we don't serve any UI
GET {{base}}
HTTP 404
Content-Type: application/problem+json
GET {{base}}/test/doc
HTTP 404
Content-Type: application/problem+json

GET {{base}}/test/doc.json
Accept: text/html
HTTP 404
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.status" == 404
jsonpath "$.title" == "sourcemeta:registry/not-found"
jsonpath "$.detail" == "There is nothing at this URL"

GET {{base}}/test/doc/string-1
Accept: text/html
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Non-blank string"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/doc/string-1.html
Accept: text/html
HTTP 404
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Not Found"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/v2.0
Accept: text/html
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "/test/v2.0"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/xxxxxxx
Accept: text/html
HTTP 404
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Not Found"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/v2.0?locations=1
Accept: text/html
HTTP 200
[Asserts]
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/v2.0?health=1
Accept: text/html

HTTP 200
[Asserts]
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/v2.0?positions=1
Accept: text/html
HTTP 200
[Asserts]
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/v2.0?positions=1
Accept: text/html
HTTP 200
[Asserts]
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/schemas/%25
Accept: text/html
HTTP 200
[Asserts]
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/schemas/%25/test
Accept: text/html
HTTP 200
[Asserts]
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test
Accept: text/html
HTTP 200
Content-Type: text/html
[Asserts]
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/foobar/sourcemeta:registry/not-found
Accept: text/html
HTTP 404
Content-Type: text/html
[Asserts]
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/no-serve/schema
Accept: text/html
HTTP 200
Content-Type: text/html
[Asserts]
header "Access-Control-Allow-Origin" not exists
