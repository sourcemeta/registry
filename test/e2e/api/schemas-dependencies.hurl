GET {{base}}/self/api/schemas/dependencies/test/bundling/single
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$" count == 1
jsonpath "$[0].from" == "{{base}}/test/bundling/single.json"
jsonpath "$[0].to" == "{{base}}/test/v2.0/schema.json"
jsonpath "$[0].at" == "/properties/foo/$ref"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/dependencies/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/schemas/dependencies/test/v2.0/schema
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$" count == 0

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/dependencies/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

HEAD {{base}}/self/api/schemas/dependencies/test/v2.0/schema
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
bytes count == 0

POST {{base}}/self/api/schemas/dependencies/test/v2.0/schema
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

GET {{base}}/self/api/schemas/dependencies/xyz/
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/schemas/dependencies
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true
