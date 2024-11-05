GET {{base}}/example/schemas/string.json
HTTP 200
Content-Type: application/schema+json
[Asserts]
bytes count > 0

GET {{base}}/example/schemas/string.json
Accept-Encoding: gzip
HTTP 200
Content-Type: application/schema+json
Content-Encoding: gzip
[Asserts]
bytes count > 0
