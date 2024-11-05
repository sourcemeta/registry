GET {{base}}/example/schemas/string.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
[Asserts]
header "ETag" exists
header "X-Request-id" exists

GET {{base}}/example/schemas/string.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/string.json",
  "type": "string"
}

# Folder with period
GET {{base}}/example/v2.0/schema.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/v2.0/schema.json",
  "type": "integer"
}
