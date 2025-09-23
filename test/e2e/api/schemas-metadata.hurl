GET {{base}}/self/api/schemas/metadata/test/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.bytes" == 130
jsonpath "$.baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.health" == 100
jsonpath "$.dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.identifier" == "{{base}}/test/v2.0/schema"
jsonpath "$.path" == "/test/v2.0/schema"
jsonpath "$.protected" == false
jsonpath "$.alert" == null
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test"
jsonpath "$.breadcrumb[1].name" == "v2.0"
jsonpath "$.breadcrumb[1].path" == "/test/v2.0"
jsonpath "$.breadcrumb[2].name" == "schema"
jsonpath "$.breadcrumb[2].path" == "/test/v2.0/schema"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/metadata/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/schemas/metadata/test/no-serve/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.bytes" == 187
jsonpath "$.baseDialect" == "https://json-schema.org/draft/2020-12/schema"
jsonpath "$.health" == 100
jsonpath "$.dialect" == "https://json-schema.org/draft/2020-12/schema"
jsonpath "$.identifier" == "{{base}}/test/no-serve/schema"
jsonpath "$.path" == "/test/no-serve/schema"
jsonpath "$.protected" == true
jsonpath "$.alert" == "This collection is private"
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test"
jsonpath "$.breadcrumb[1].name" == "no-serve"
jsonpath "$.breadcrumb[1].path" == "/test/no-serve"
jsonpath "$.breadcrumb[2].name" == "schema"
jsonpath "$.breadcrumb[2].path" == "/test/no-serve/schema"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/metadata/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

HEAD {{base}}/self/api/schemas/metadata/test/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
bytes count == 0

POST {{base}}/self/api/schemas/metadata/test/v2.0/schema
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

GET {{base}}/self/api/schemas/metadata/xyz
Accept: application/json
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

GET {{base}}/self/api/schemas/metadata
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
