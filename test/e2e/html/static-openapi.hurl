GET {{base}}/self/static/openapi.html
Accept-Encoding: gzip
HTTP 200
Content-Type: text/html
Content-Encoding: gzip
[Asserts]
bytes count > 0
header "ETag" exists
header "Last-Modified" exists
header "Access-Control-Allow-Origin" not exists

GET {{base}}/self/static/openapi.yaml
Accept-Encoding: gzip
HTTP 200
Content-Type: application/yaml
Content-Encoding: gzip
[Asserts]
bytes count > 0
header "ETag" exists
header "Last-Modified" exists
header "Access-Control-Allow-Origin" not exists
