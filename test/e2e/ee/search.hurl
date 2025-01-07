GET {{base}}/search
HTTP 400
Content-Type: application/json
[Captures]
current_request_id: header "X-Request-id"
[Asserts]  
jsonpath "$.code" == 400
jsonpath "$.error" == "missing-query"
jsonpath "$.message" == "You must provide a query parameter to search for"
jsonpath "$.request" == "{{current_request_id}}"

GET {{base}}/search?q=
HTTP 400
Content-Type: application/json
[Captures]
current_request_id: header "X-Request-id"
[Asserts]  
jsonpath "$.code" == 400
jsonpath "$.error" == "missing-query"
jsonpath "$.message" == "You must provide a query parameter to search for"
jsonpath "$.request" == "{{current_request_id}}"

POST {{base}}/search?q=foo
HTTP 405
Content-Type: application/json
[Captures]
current_request_id: header "X-Request-id"
[Asserts]  
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"
jsonpath "$.request" == "{{current_request_id}}"

# A string we know won't give any results
GET {{base}}/search?q=xxxxxxxxxxxx
HTTP 200
[]

# Results with title/description
GET {{base}}/search?q=bundling
HTTP 200
[
  {
    "url": "/example/bundling/single.json",
    "title": "Bundling",
    "description": "A bundling example"
  }
]

# Test casing
GET {{base}}/search?q=bUNdLing
HTTP 200
[
  {
    "url": "/example/bundling/single.json",
    "title": "Bundling",
    "description": "A bundling example"
  }
]

# Results without title/description
GET {{base}}/search?q=camel
HTTP 200
[
  {
    "url": "/example/schemas/camelcase.json",
    "title": "",
    "description": ""
  }
]

# No matter what, we impose a limit on the results
GET {{base}}/search?q=e
HTTP 200
[Asserts]
jsonpath "$" count <= 10
