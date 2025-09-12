GET {{base}}/self/api/schemas/search
HTTP 400
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.code" == 400
jsonpath "$.error" == "missing-query"
jsonpath "$.message" == "You must provide a query parameter to search for"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/schemas/search?q=
HTTP 400
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.code" == 400
jsonpath "$.error" == "missing-query"
jsonpath "$.message" == "You must provide a query parameter to search for"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

POST {{base}}/self/api/schemas/search?q=foo
HTTP 405
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A string we know won't give any results
GET {{base}}/self/api/schemas/search?q=xxxxxxxxxxxx
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$" count == 0

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/search/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# Results with title/description
GET {{base}}/self/api/schemas/search?q=bundling
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$" count == 2
jsonpath "$[0].url" == "/test/bundling/single"
jsonpath "$[0].title" == "Bundling"
jsonpath "$[0].description" == "A bundling example"
jsonpath "$[1].url" == "/test/bundling/double"
jsonpath "$[1].title" == ""
jsonpath "$[1].description" == ""

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/search/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# Test casing
GET {{base}}/self/api/schemas/search?q=bUNdLing
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$" count == 2
jsonpath "$[0].url" == "/test/bundling/single"
jsonpath "$[0].title" == "Bundling"
jsonpath "$[0].description" == "A bundling example"
jsonpath "$[1].url" == "/test/bundling/double"
jsonpath "$[1].title" == ""
jsonpath "$[1].description" == ""

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/search/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# Results without title/description
GET {{base}}/self/api/schemas/search?q=schemas/camelcase
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$" count == 1
jsonpath "$[0].url" == "/test/schemas/camelcase"
jsonpath "$[0].title" == ""
jsonpath "$[0].description" == ""

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/search/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# No matter what, we impose a limit on the results
GET {{base}}/self/api/schemas/search?q=e
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$" count <= 10

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/search/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true
