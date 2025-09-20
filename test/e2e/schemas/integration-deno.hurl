GET {{base}}/test/bundling/single.json
User-Agent: Deno/2.4.5
HTTP 200
Content-Type: application/json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/bundling/single.json",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "{{base}}/test/v2.0/schema.json"
    }
  },
  "definitions": {
    "{{base}}/test/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "{{base}}/test/v2.0/schema.json",
      "type": "integer"
    }
  }
}
