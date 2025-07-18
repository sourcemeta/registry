GET {{base}}/api/search
HTTP 400
Content-Type: application/json
[Asserts]  
jsonpath "$.code" == 400
jsonpath "$.error" == "missing-query"
jsonpath "$.message" == "You must provide a query parameter to search for"

GET {{base}}/api/search?q=
HTTP 400
Content-Type: application/json
[Asserts]  
jsonpath "$.code" == 400
jsonpath "$.error" == "missing-query"
jsonpath "$.message" == "You must provide a query parameter to search for"

POST {{base}}/api/search?q=foo
HTTP 405
Content-Type: application/json
[Asserts]  
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"

# A string we know won't give any results
GET {{base}}/api/search?q=xxxxxxxxxxxx
HTTP 200
Content-Type: application/jsonl
[]

# Results with title/description
GET {{base}}/api/search?q=bundling
HTTP 200
Content-Type: application/jsonl
[
  {
    "url": "/example/bundling/single",
    "title": "Bundling",
    "description": "A bundling example"
  }
]

# Test casing
GET {{base}}/api/search?q=bUNdLing
HTTP 200
Content-Type: application/jsonl
[
  {
    "url": "/example/bundling/single",
    "title": "Bundling",
    "description": "A bundling example"
  }
]

# Results without title/description
GET {{base}}/api/search?q=schemas/camelcase
HTTP 200
Content-Type: application/jsonl
[
  {
    "url": "/example/schemas/camelcase",
    "title": "",
    "description": ""
  }
]

# No matter what, we impose a limit on the results
GET {{base}}/api/search?q=e
HTTP 200
Content-Type: application/jsonl
[Asserts]
jsonpath "$" count <= 10
