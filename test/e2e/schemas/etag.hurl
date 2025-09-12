GET {{base}}/test/schemas/string.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Captures]
test_schemas_string_json_etag: header "ETag"

# Idempotent ETag
GET {{base}}/test/schemas/string.json
HTTP 200
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" == {{test_schemas_string_json_etag}}

# If-None-Match with match
GET {{base}}/test/schemas/string.json
If-None-Match: {{test_schemas_string_json_etag}}
HTTP 304
Access-Control-Allow-Origin: *
[Asserts]
header "Content-Type" not exists
bytes count == 0

# If-None-Match with weak match
GET {{base}}/test/schemas/string.json
If-None-Match: W/{{test_schemas_string_json_etag}}
HTTP 304
Access-Control-Allow-Origin: *
[Asserts]
header "Content-Type" not exists
bytes count == 0

# If-None-Match without match
GET {{base}}/test/schemas/string.json
If-None-Match: "12345"
HTTP 200
Content-Type: application/schema+json
Access-Control-Allow-Origin: *
[Asserts]
bytes count > 0
