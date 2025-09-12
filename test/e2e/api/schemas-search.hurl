GET {{base}}/self/api/schemas/search
HTTP 400
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 400
jsonpath "$.error" == "missing-query"
jsonpath "$.message" == "You must provide a query parameter to search for"

GET {{base}}/self/api/schemas/search?q=
HTTP 400
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 400
jsonpath "$.error" == "missing-query"
jsonpath "$.message" == "You must provide a query parameter to search for"

POST {{base}}/self/api/schemas/search?q=foo
HTTP 405
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"

# A string we know won't give any results
GET {{base}}/self/api/schemas/search?q=xxxxxxxxxxxx
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[]

# Results with title/description
GET {{base}}/self/api/schemas/search?q=bundling
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[
  {
    "url": "/test/bundling/single",
    "title": "Bundling",
    "description": "A bundling example"
  },
  {
    "url": "/test/bundling/double",
    "title": "",
    "description": ""
  }
]

# Test casing
GET {{base}}/self/api/schemas/search?q=bUNdLing
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[
  {
    "url": "/test/bundling/single",
    "title": "Bundling",
    "description": "A bundling example"
  },
  {
    "url": "/test/bundling/double",
    "title": "",
    "description": ""
  }
]

# Results without title/description
GET {{base}}/self/api/schemas/search?q=schemas/camelcase
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[
  {
    "url": "/test/schemas/camelcase",
    "title": "",
    "description": ""
  }
]

# No matter what, we impose a limit on the results
GET {{base}}/self/api/schemas/search?q=e
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$" count <= 10
