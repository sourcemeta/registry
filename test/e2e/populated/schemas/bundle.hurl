GET {{base}}/test/bundling/single.json?bundle=1
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists

GET {{base}}/test/bundling/single.json?bundle=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/bundling/single",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "http://localhost:8000/test/v2.0/schema"
    }
  },
  "definitions": {
    "http://localhost:8000/test/v2.0/schema": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/test/v2.0/schema",
      "type": "integer"
    }
  }
}

GET {{base}}/test/bundling/single.json?bundle=0
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/bundling/single",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "http://localhost:8000/test/v2.0/schema"
    }
  },
  "definitions": {
    "http://localhost:8000/test/v2.0/schema": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/test/v2.0/schema",
      "type": "integer"
    }
  }
}

GET {{base}}/test/bundling/single.json?bundle=foo
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/bundling/single",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "http://localhost:8000/test/v2.0/schema"
    }
  },
  "definitions": {
    "http://localhost:8000/test/v2.0/schema": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/test/v2.0/schema",
      "type": "integer"
    }
  }
}

GET {{base}}/test/v2.0/schema.json?bundle=1
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists

GET {{base}}/test/v2.0/schema.json?bundle=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/v2.0/schema",
  "type": "integer"
}

GET {{base}}/test/bundling/single.json?foo=2&bundle=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/bundling/single",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "http://localhost:8000/test/v2.0/schema"
    }
  },
  "definitions": {
    "http://localhost:8000/test/v2.0/schema": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/test/v2.0/schema",
      "type": "integer"
    }
  }
}

GET {{base}}/test/extension/to-without.json?bundle=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/extension/to-without",
  "allOf": [
    {
      "$ref": "without"
    }
  ],
  "definitions": {
    "http://localhost:8000/test/extension/without": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "$id": "http://localhost:8000/test/extension/without",
      "type": "string"
    }
  }
}
