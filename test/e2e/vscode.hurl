GET {{base}}/example/bundling/single.json
User-Agent: Visual Studio Code (desktop)
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "#/definitions/http%3A~1~1localhost%3A8000~1example~1v2.0~1schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/example/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "integer"
    }
  }
}

GET {{base}}/example/bundling/single.json
User-Agent: VSCodium (desktop)
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "#/definitions/http%3A~1~1localhost%3A8000~1example~1v2.0~1schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/example/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "integer"
    }
  }
}

GET {{base}}/example/bundling/single.json?bundle=0
User-Agent: VSCodium (desktop)
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "#/definitions/http%3A~1~1localhost%3A8000~1example~1v2.0~1schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/example/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "integer"
    }
  }
}

GET {{base}}/example/bundling/single.json?unidentify=0
User-Agent: VSCodium (desktop)
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Bundling",
  "description": "A bundling example",
  "properties": {
    "foo": {
      "$ref": "#/definitions/http%3A~1~1localhost%3A8000~1example~1v2.0~1schema.json"
    }
  },
  "definitions": {
    "http://localhost:8000/example/v2.0/schema.json": {
      "$schema": "http://json-schema.org/draft-07/schema#",
      "type": "integer"
    }
  }
}
