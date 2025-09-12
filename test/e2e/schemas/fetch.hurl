GET {{base}}/test/schemas/string.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists

GET {{base}}/test/schemas/string.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/string.json",
  "type": "string"
}

GET {{base}}/test/schemas/draft4-top-level-ref.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "id": "{{base}}/test/schemas/draft4-top-level-ref.json",
  "allOf": [
    {
      "$ref": "#/definitions/foo"
    }
  ],
  "definitions": {
    "foo": {
      "type": "string"
    }
  }
}

GET {{base}}/test/schemas/with-rebase-same-host.json
HTTP 200
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "{{base}}/test/schemas/with-rebase-same-host.json",
  "$ref": "../bundling/single.json"
}

GET {{base}}/test/schemas/with-rebase.json
HTTP 200
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "{{base}}/test/schemas/with-rebase.json",
  "$ref": "/test/bundling/single.json"
}

GET {{base}}/test/schemas/id-same-as-base.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/id-same-as-base.json",
  "type": "string"
}

# With random unknown query parameters
GET {{base}}/test/schemas/string.json?foo=bar&baz=qux
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/string.json",
  "type": "string"
}

# Identifier derived from file path
GET {{base}}/test/schemas/no-id.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/no-id.json",
  "type": "string"
}

# Applied default dialect
GET {{base}}/test/schemas/no-schema.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/no-schema.json",
  "type": "string"
}

# Applied default dialect and file identifier
GET {{base}}/test/schemas/no-schema-nor-id.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/no-schema-nor-id.json",
  "type": "string"
}

# Adding `$id` when there is a top-level `$ref`
GET {{base}}/test/schemas/no-id-draft7-ref.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/no-id-draft7-ref.json",
  "allOf": [
    {
      "$ref": "string.json"
    }
  ]
}

# With absolute references
GET {{base}}/test/schemas/absolute-refs.json
HTTP 200
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "{{base}}/test/schemas/absolute-refs.json",
  "$ref": "string.json"
}

# Folder with period
GET {{base}}/test/v2.0/schema.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/v2.0/schema.json",
  "type": "integer"
}

# .schema.json extension
GET {{base}}/test/extension/with.schema.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/extension/with.schema.json",
  "type": "string"
}

# No extension
GET {{base}}/test/extension/without.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/extension/without.json",
  "type": "string"
}

# With correct casing
GET {{base}}/test/schemas/CamelCase.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/camelcase.json",
  "type": "string"
}

# With lower casing
GET {{base}}/test/schemas/camelcase.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/camelcase.json",
  "type": "string"
}

GET {{base}}/test/schemas/html.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/html.json"
}

GET {{base}}/test/schemas/index.html.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/index.html.json"
}

GET {{base}}/test/doc/.period.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/doc/.period.json",
  "type": "string"
}

GET {{base}}/test/schemas/%25/test.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/%25/test.json"
}

GET {{base}}/test/schemas/string.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Captures]
test_schemas_string_json_etag: header "ETag"
test_schemas_string_json_content_length: header "Content-Length"

HEAD {{base}}/test/schemas/string.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
bytes count == 0
header "ETag" == {{test_schemas_string_json_etag}}
header "Content-Length" == {{test_schemas_string_json_content_length}}

POST {{base}}/test/schemas/string.json
HTTP 405
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"

GET {{base}}/schemas/doc/.period.json
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"

# Invalid method on found
DELETE {{base}}/test/schemas/string.json
HTTP 405
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"

# Invalid method on not found
PUT {{base}}/test/schemas/xxx.json
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"

GET {{base}}/.json
HTTP 404
