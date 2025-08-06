GET {{base}}/example/schemas/string.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Captures]
example_schemas_string_json_etag: header "ETag"

# Idempotent ETag
GET {{base}}/example/schemas/string.json
HTTP 200
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" == {{example_schemas_string_json_etag}}

# If-None-Match with match
GET {{base}}/example/schemas/string.json
If-None-Match: {{example_schemas_string_json_etag}}
HTTP 304
Access-Control-Allow-Origin: *
[Asserts]
header "Content-Type" not exists
bytes count == 0

# If-None-Match with weak match
GET {{base}}/example/schemas/string.json
If-None-Match: W/{{example_schemas_string_json_etag}}
HTTP 304
Access-Control-Allow-Origin: *
[Asserts]
header "Content-Type" not exists
bytes count == 0

# If-None-Match without match
GET {{base}}/example/schemas/string.json
If-None-Match: "12345"
HTTP 200
Content-Type: application/schema+json
Access-Control-Allow-Origin: *
[Asserts]
bytes count > 0
