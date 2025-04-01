GET {{base}}/example/bundling/single.json?bundle=1
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
[Asserts]
header "ETag" exists
header "X-Request-id" exists

GET {{base}}/example/bundling/single.json?bundle=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/bundling/single.json",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "http://localhost:8000/example/v2.0/schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/example/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/example/v2.0/schema.json",
      "type": "integer"
    }
  }
}

GET {{base}}/example/bundling/single.json?bundle=0
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/bundling/single.json",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "http://localhost:8000/example/v2.0/schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/example/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/example/v2.0/schema.json",
      "type": "integer"
    }
  }
}

GET {{base}}/example/bundling/single.json?bundle=foo
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/bundling/single.json",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "http://localhost:8000/example/v2.0/schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/example/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/example/v2.0/schema.json",
      "type": "integer"
    }
  }
}

GET {{base}}/example/v2.0/schema.json?bundle=1
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
[Asserts]
header "ETag" exists
header "X-Request-id" exists

GET {{base}}/example/v2.0/schema.json?bundle=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/v2.0/schema.json",
  "type": "integer"
}

GET {{base}}/example/bundling/single.json?foo=2&bundle=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/bundling/single.json",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "http://localhost:8000/example/v2.0/schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/example/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/example/v2.0/schema.json",
      "type": "integer"
    }
  }
}

GET {{base}}/example/extension/to-without.json?bundle=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/extension/to-without.json",
  "allOf": [
    {
      "$ref": "without"
    }
  ],
  "definitions": {
    "http://localhost:8000/example/extension/without": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/example/extension/without",
      "type": "string"
    }
  }
}
