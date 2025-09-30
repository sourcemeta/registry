GET {{base}}/test/schemas/string.json
HTTP 200
Content-Type: application/schema+json
Access-Control-Allow-Origin: *
[Asserts]
bytes count > 0

GET {{base}}/test/schemas/string.json
Accept-Encoding: gzip
HTTP 200
Content-Type: application/schema+json
Content-Encoding: gzip
Access-Control-Allow-Origin: *
[Asserts]
bytes count > 0
