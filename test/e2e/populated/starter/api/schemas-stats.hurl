GET {{base}}/self/api/schemas/stats/test/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$['http://json-schema.org/draft-07/schema#']['$id']" == 1
jsonpath "$['http://json-schema.org/draft-07/schema#']['$schema']" == 1
jsonpath "$['http://json-schema.org/draft-07/schema#']['type']" == 1
