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

# Identifier derived from file path
GET {{base}}/example/schemas/no-id.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/no-id.json",
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

# .schema.json extension
GET {{base}}/example/extension/with.schema.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/extension/with.schema.json",
  "type": "string"
}

# With correct casing
GET {{base}}/example/schemas/CamelCase.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/camelcase.json",
  "type": "string"
}

# With lower casing
GET {{base}}/example/schemas/camelcase.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/camelcase.json",
  "type": "string"
}
