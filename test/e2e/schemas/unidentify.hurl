GET {{base}}/test/bundling/single.json?unidentify=1
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists

GET {{base}}/test/bundling/single.json?unidentify=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "#/definitions/http:~1~1localhost:8000~1test~1v2.0~1schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/test/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "integer"
    }
  }
}

GET {{base}}/test/bundling/single.json?unidentify=0
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "#/definitions/http:~1~1localhost:8000~1test~1v2.0~1schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/test/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "integer"
    }
  }
}

GET {{base}}/test/bundling/single.json?unidentify=true
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "#/definitions/http:~1~1localhost:8000~1test~1v2.0~1schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/test/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "integer"
    }
  }
}

GET {{base}}/test/bundling/single.json?bundle=1&unidentify=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "#/definitions/http:~1~1localhost:8000~1test~1v2.0~1schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/test/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "integer"
    }
  }
}

GET {{base}}/test/v2.0/schema.json?unidentify=1
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists

GET {{base}}/test/v2.0/schema.json?unidentify=1
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "type": "integer"
}
