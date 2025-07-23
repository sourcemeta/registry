GET {{base}}/example/foobar/not-found
HTTP 404
Content-Type: text/html
[Asserts]
header "Access-Control-Allow-Origin" not exists
