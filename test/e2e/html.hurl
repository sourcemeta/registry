GET {{base}}
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Sourcemeta Schemas"

GET {{base}}/doc
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "A sample schema folder"

GET {{base}}/example/v2.0
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "/example/v2.0"

GET {{base}}/xxxxxxx
HTTP 404
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Not Found"
