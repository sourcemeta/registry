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
jsonpath "$.provenance" == null
jsonpath "$.examples" count == 0
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

GET {{base}}/self/api/schemas/metadata/test/schemas/string
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.bytes" == 357
jsonpath "$.baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.health" == 0
jsonpath "$.dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.identifier" == "{{base}}/test/schemas/string"
jsonpath "$.path" == "/test/schemas/string"
jsonpath "$.protected" == false
jsonpath "$.alert" == null
jsonpath "$.provenance" == null
jsonpath "$.examples" count == 10
jsonpath "$.examples[0]" == "example_01"
jsonpath "$.examples[1]" == "example_02"
jsonpath "$.examples[2]" == "example_03"
jsonpath "$.examples[3]" == "example_04"
jsonpath "$.examples[4]" == 5
jsonpath "$.examples[5]" == "example_06"
jsonpath "$.examples[6]" == "example_07"
jsonpath "$.examples[7]" == "example_08"
jsonpath "$.examples[8]" == "example_09"
jsonpath "$.examples[9]" == "example_10"
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test"
jsonpath "$.breadcrumb[1].name" == "schemas"
jsonpath "$.breadcrumb[1].path" == "/test/schemas"
jsonpath "$.breadcrumb[2].name" == "string"
jsonpath "$.breadcrumb[2].path" == "/test/schemas/string"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/metadata/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/schemas/metadata/test/schemas/draft4-top-level-ref
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.bytes" == 311
jsonpath "$.baseDialect" == "http://json-schema.org/draft-04/schema#"
jsonpath "$.health" == 67
jsonpath "$.dialect" == "http://json-schema.org/draft-04/schema#"
jsonpath "$.identifier" == "{{base}}/test/schemas/draft4-top-level-ref"
jsonpath "$.path" == "/test/schemas/draft4-top-level-ref"
jsonpath "$.protected" == false
jsonpath "$.alert" == null
jsonpath "$.provenance" == null
jsonpath "$.examples" count == 0
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test"
jsonpath "$.breadcrumb[1].name" == "schemas"
jsonpath "$.breadcrumb[1].path" == "/test/schemas"
jsonpath "$.breadcrumb[2].name" == "draft4-top-level-ref"
jsonpath "$.breadcrumb[2].path" == "/test/schemas/draft4-top-level-ref"

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
jsonpath "$.provenance" == null
jsonpath "$.examples" count == 0
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

# With built-in library provenance
GET {{base}}/self/api/schemas/metadata/geojson/v1.0.5/point
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.bytes" == 532
jsonpath "$.baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.health" == 84
jsonpath "$.dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.identifier" == "{{base}}/geojson/v1.0.5/point"
jsonpath "$.path" == "/geojson/v1.0.5/point"
jsonpath "$.protected" == false
jsonpath "$.alert" == null
jsonpath "$.provenance" == "@geojson/v1.0.5"
jsonpath "$.examples" count == 0
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "geojson"
jsonpath "$.breadcrumb[0].path" == "/geojson"
jsonpath "$.breadcrumb[1].name" == "v1.0.5"
jsonpath "$.breadcrumb[1].path" == "/geojson/v1.0.5"
jsonpath "$.breadcrumb[2].name" == "point"
jsonpath "$.breadcrumb[2].path" == "/geojson/v1.0.5/point"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/schemas/metadata/response
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
