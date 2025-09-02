GET {{base}}
HTTP 200
Content-Type: text/html
[Asserts]
xpath "string(/html/head/title)" == "Sourcemeta Schemas"
header "Access-Control-Allow-Origin" not exists
