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
  "$id": "{{base}}/test/schemas/string",
  "examples": [
    "example_01",
    "example_02",
    "example_03",
    "example_04",
    5,
    "example_06",
    "example_07",
    "example_08",
    "example_09",
    "example_10",
    "example_11",
    "example_12"
  ],
  "type": "string"
}

# Without extension
GET {{base}}/test/schemas/string
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists

GET {{base}}/test/schemas/string
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/string",
  "examples": [
    "example_01",
    "example_02",
    "example_03",
    "example_04",
    5,
    "example_06",
    "example_07",
    "example_08",
    "example_09",
    "example_10",
    "example_11",
    "example_12"
  ],
  "type": "string"
}

GET {{base}}/test/schemas/draft4-top-level-ref.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-04/schema#",
  "id": "{{base}}/test/schemas/draft4-top-level-ref",
  "examples": [ "draft4 does not define `examples`!" ],
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
  "$id": "{{base}}/test/schemas/with-rebase-same-host",
  "$ref": "../bundling/single"
}

GET {{base}}/test/schemas/with-rebase.json
HTTP 200
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "{{base}}/test/schemas/with-rebase",
  "$ref": "/test/bundling/single.json"
}

GET {{base}}/test/schemas/id-same-as-base.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/id-same-as-base",
  "type": "string"
}

# With random unknown query parameters
GET {{base}}/test/schemas/string.json?foo=bar&baz=qux
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/string",
  "examples": [
    "example_01",
    "example_02",
    "example_03",
    "example_04",
    5,
    "example_06",
    "example_07",
    "example_08",
    "example_09",
    "example_10",
    "example_11",
    "example_12"
  ],
  "type": "string"
}

# Identifier derived from file path
GET {{base}}/test/schemas/no-id.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/no-id",
  "type": "string"
}

# Applied default dialect
GET {{base}}/test/schemas/no-schema.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/no-schema",
  "type": "string"
}

# Applied default dialect and file identifier
GET {{base}}/test/schemas/no-schema-nor-id.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/no-schema-nor-id",
  "type": "string"
}

# Adding `$id` when there is a top-level `$ref`
GET {{base}}/test/schemas/no-id-draft7-ref.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/no-id-draft7-ref",
  "allOf": [
    {
      "$ref": "string"
    }
  ]
}

# With absolute references
GET {{base}}/test/schemas/absolute-refs.json
HTTP 200
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "{{base}}/test/schemas/absolute-refs",
  "$ref": "string"
}

# Folder with period
GET {{base}}/test/v2.0/schema.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/v2.0/schema",
  "type": "integer"
}

# .schema.json extension
GET {{base}}/test/extension/with.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/extension/with",
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
  "$id": "{{base}}/test/extension/without",
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
  "$id": "{{base}}/test/schemas/camelcase",
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
  "$id": "{{base}}/test/schemas/camelcase",
  "type": "string"
}

GET {{base}}/test/schemas/html.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/html"
}

GET {{base}}/test/schemas/index.html.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/index.html"
}

GET {{base}}/test/doc/.period.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/doc/.period",
  "type": "string"
}

GET {{base}}/test/schemas/%25/test.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/%25/test"
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
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.status" == 405
jsonpath "$.title" == "sourcemeta:registry/method-not-allowed"
jsonpath "$.detail" == "This HTTP method is invalid for this URL"

GET {{base}}/schemas/doc/.period.json
HTTP 404
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.status" == 404
jsonpath "$.title" == "sourcemeta:registry/not-found"
jsonpath "$.detail" == "There is nothing at this URL"

# Invalid method on found
DELETE {{base}}/test/schemas/string.json
HTTP 405
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.status" == 405
jsonpath "$.title" == "sourcemeta:registry/method-not-allowed"
jsonpath "$.detail" == "This HTTP method is invalid for this URL"

# Invalid method on not found
PUT {{base}}/test/schemas/xxx.json
HTTP 404
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.status" == 404
jsonpath "$.title" == "sourcemeta:registry/not-found"
jsonpath "$.detail" == "There is nothing at this URL"

GET {{base}}/.json
HTTP 404
