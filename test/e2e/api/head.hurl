GET {{base}}/example/schemas/string.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Captures]
example_schemas_string_json_etag: header "ETag"
example_schemas_string_json_content_length: header "Content-Length"

HEAD {{base}}/example/schemas/string.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
bytes count == 0
header "ETag" == {{example_schemas_string_json_etag}}
header "Content-Length" == {{example_schemas_string_json_content_length}}
