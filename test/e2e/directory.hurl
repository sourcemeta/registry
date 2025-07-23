GET {{base}}/example
HTTP 200
Content-Type: text/html
[Asserts]
header "Access-Control-Allow-Origin" not exists
