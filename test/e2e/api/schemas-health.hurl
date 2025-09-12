GET {{base}}/self/api/schemas/health/test/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.score" == 100
jsonpath "$.errors" count == 0

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/health/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/schemas/health/geojson/v1.0.5/polygon
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.score" == 88
jsonpath "$.errors" count == 2
jsonpath "$.errors[0].pointers" count == 1
jsonpath "$.errors[0].pointers[0]" == "/properties/type/enum"
jsonpath "$.errors[0].name" == "enum_to_const"
jsonpath "$.errors[0].message" == "An `enum` of a single value can be expressed as `const`"
jsonpath "$.errors[0].description" == null
jsonpath "$.errors[1].pointers" count == 2
jsonpath "$.errors[1].pointers[0]" == "/properties/type/enum"
jsonpath "$.errors[1].pointers[1]" == "/properties/type/type"
jsonpath "$.errors[1].name" == "enum_with_type"
jsonpath "$.errors[1].message" == "Setting `type` alongside `enum` is considered an anti-pattern, as the enumeration choices already imply their respective types"
jsonpath "$.errors[1].description" == null

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/health/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

HEAD {{base}}/self/api/schemas/health/geojson/v1.0.5/polygon
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
bytes count == 0

POST {{base}}/self/api/schemas/health/geojson/v1.0.5/polygon
HTTP 405
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.status" == 405
jsonpath "$.title" == "sourcemeta:registry/method-not-allowed"
jsonpath "$.detail" == "This HTTP method is invalid for this URL"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/schemas/health/xyz/
HTTP 404
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.status" == 404
jsonpath "$.title" == "sourcemeta:registry/not-found"
jsonpath "$.detail" == "There is nothing at this URL"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/schemas/health
HTTP 404
Content-Type: application/problem+json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
jsonpath "$.status" == 404
jsonpath "$.title" == "sourcemeta:registry/not-found"
jsonpath "$.detail" == "There is nothing at this URL"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/error
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true
