OPTIONS {{base}}
HTTP 405

GET {{base}}
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Sourcemeta Schemas"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/doc
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "A sample schema folder"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/doc.json
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"

GET {{base}}/test/doc/string-1
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Non-blank string"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/doc/string-1.html
HTTP 404
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Not Found"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/v2.0
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "/test/v2.0"
header "Access-Control-Allow-Origin" not exists

GET {{base}}/xxxxxxx
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
HTTP 200
Content-Type: text/html
[Asserts]
header "Access-Control-Allow-Origin" not exists

GET {{base}}/test/foobar/not-found
HTTP 404
Content-Type: text/html
[Asserts]
header "Access-Control-Allow-Origin" not exists
