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

GET {{base}}/example/schemas/id-same-as-base.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/id-same-as-base.json",
  "type": "string"
}

# With random unknown query parameters
GET {{base}}/example/schemas/string.json?foo=bar&baz=qux
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

# Applied default dialect
GET {{base}}/example/schemas/no-schema.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/no-schema.json",
  "type": "string"
}

# Applied default dialect and file identifier
GET {{base}}/example/schemas/no-schema-nor-id.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/no-schema-nor-id.json",
  "type": "string"
}

# Adding `$id` when there is a top-level `$ref`
GET {{base}}/example/schemas/no-id-draft7-ref.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/no-id-draft7-ref.json",
  "allOf": [
    {
      "$ref": "string.json"
    }
  ]
}

# With absolute references
GET {{base}}/example/schemas/absolute-refs.json
HTTP 200
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "{{base}}/example/schemas/absolute-refs.json",
  "$ref": "string.json"
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

# No extension
GET {{base}}/example/extension/without.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/extension/without.json",
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
