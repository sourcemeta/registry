GET {{base}}/self/api/list
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.path" == "/"
jsonpath "$.url" == "{{base}}"
jsonpath "$.breadcrumb" count == 0
jsonpath "$.entries" count == 3
jsonpath "$.entries[0].name" == "test"
jsonpath "$.entries[0].title" == "Test"
jsonpath "$.entries[0].description" == "A directory full of testing schemas"
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].health" == 99
jsonpath "$.entries[0].path" == "/test"
jsonpath "$.entries[1].name" == "sourcemeta"
jsonpath "$.entries[1].title" == "Sourcemeta"
jsonpath "$.entries[1].description" == "A provider of premium tooling and services to support JSON Schema use in production"
jsonpath "$.entries[1].email" == "hello@sourcemeta.com"
jsonpath "$.entries[1].github" == "sourcemeta"
jsonpath "$.entries[1].website" == "https://www.sourcemeta.com"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].health" == 100
jsonpath "$.entries[1].path" == "/sourcemeta"
jsonpath "$.entries[2].name" == "geojson"
jsonpath "$.entries[2].title" == "GeoJSON"
jsonpath "$.entries[2].description" == "A format for encoding a variety of geographic data structures"
jsonpath "$.entries[2].github" == "geojson"
jsonpath "$.entries[2].website" == "https://geojson.org"
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].health" == 91
jsonpath "$.entries[2].path" == "/geojson"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/list/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/list/test
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.path" == "/test"
jsonpath "$.url" == "{{base}}/test"
jsonpath "$.breadcrumb" count == 1
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test"
jsonpath "$.description" == "A directory full of testing schemas"
jsonpath "$.title" == "Test"
jsonpath "$.entries" count == 9
jsonpath "$.entries[0].name" == "v2.0"
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].health" == 100
jsonpath "$.entries[0].path" == "/test/v2.0"
jsonpath "$.entries[1].name" == "schemas"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].health" == 92
jsonpath "$.entries[1].path" == "/test/schemas"
jsonpath "$.entries[2].name" == "same"
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].health" == 100
jsonpath "$.entries[2].path" == "/test/same"
jsonpath "$.entries[3].name" == "no-blaze"
jsonpath "$.entries[3].type" == "directory"
jsonpath "$.entries[3].health" == 100
jsonpath "$.entries[3].path" == "/test/no-blaze"
jsonpath "$.entries[4].name" == "hyper"
jsonpath "$.entries[4].type" == "directory"
jsonpath "$.entries[4].health" == 100
jsonpath "$.entries[4].path" == "/test/hyper"
jsonpath "$.entries[5].name" == "extension"
jsonpath "$.entries[5].type" == "directory"
jsonpath "$.entries[5].health" == 100
jsonpath "$.entries[5].path" == "/test/extension"
jsonpath "$.entries[6].name" == "doc"
jsonpath "$.entries[6].type" == "directory"
jsonpath "$.entries[6].health" == 100
jsonpath "$.entries[6].path" == "/test/doc"
jsonpath "$.entries[6].title" == "A sample schema folder"
jsonpath "$.entries[6].description" == "For testing purposes"
jsonpath "$.entries[6].github" == "sourcemeta/registry"
jsonpath "$.entries[7].name" == "camelcase"
jsonpath "$.entries[7].type" == "directory"
jsonpath "$.entries[7].health" == 100
jsonpath "$.entries[7].path" == "/test/camelcase"
jsonpath "$.entries[8].name" == "bundling"
jsonpath "$.entries[8].type" == "directory"
jsonpath "$.entries[8].health" == 100
jsonpath "$.entries[8].path" == "/test/bundling"

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/list/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/list/test/v2.0
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.path" == "/test/v2.0"
jsonpath "$.url" == "{{base}}/test/v2.0"
jsonpath "$.breadcrumb" count == 2
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test"
jsonpath "$.breadcrumb[1].name" == "v2.0"
jsonpath "$.breadcrumb[1].path" == "/test/v2.0"
jsonpath "$.entries" count == 1
jsonpath "$.entries[0].bytes" == 130
jsonpath "$.entries[0].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].identifier" == "{{base}}/test/v2.0/schema"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].alert" == null
jsonpath "$.entries[0].provenance" == null
jsonpath "$.entries[0].path" == "/test/v2.0/schema"
jsonpath "$.entries[0].health" == 100
jsonpath "$.entries[0].dependencies" == 0

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/list/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/list/test/v2.0.json
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

GET {{base}}/self/api/list/test/schemas/versions
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.path" == "/test/schemas/versions"
jsonpath "$.url" == "{{base}}/test/schemas/versions"
jsonpath "$.health" == 100
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test"
jsonpath "$.breadcrumb[1].name" == "schemas"
jsonpath "$.breadcrumb[1].path" == "/test/schemas"
jsonpath "$.breadcrumb[2].name" == "versions"
jsonpath "$.breadcrumb[2].path" == "/test/schemas/versions"
jsonpath "$.entries" count == 1
jsonpath "$.entries[0].bytes" == 141
jsonpath "$.entries[0].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].identifier" == "{{base}}/test/schemas/versions/v1.2.3"
jsonpath "$.entries[0].name" == "v1.2.3"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].alert" == null
jsonpath "$.entries[0].provenance" == null
jsonpath "$.entries[0].path" == "/test/schemas/versions/v1.2.3"
jsonpath "$.entries[0].health" == 100
jsonpath "$.entries[0].dependencies" == 0

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/list/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/list/test/extension
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.path" == "/test/extension"
jsonpath "$.url" == "{{base}}/test/extension"
jsonpath "$.health" == 100
jsonpath "$.breadcrumb" count == 2
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test"
jsonpath "$.breadcrumb[1].name" == "extension"
jsonpath "$.breadcrumb[1].path" == "/test/extension"
jsonpath "$.entries" count == 3
jsonpath "$.entries[0].bytes" == 135
jsonpath "$.entries[0].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].identifier" == "{{base}}/test/extension/without"
jsonpath "$.entries[0].name" == "without"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].alert" == null
jsonpath "$.entries[0].provenance" == null
jsonpath "$.entries[0].path" == "/test/extension/without"
jsonpath "$.entries[0].health" == 100
jsonpath "$.entries[0].dependencies" == 0
jsonpath "$.entries[1].bytes" == 132
jsonpath "$.entries[0].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[1].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[1].identifier" == "{{base}}/test/extension/with"
jsonpath "$.entries[1].name" == "with"
jsonpath "$.entries[1].type" == "schema"
jsonpath "$.entries[1].alert" == null
jsonpath "$.entries[1].provenance" == null
jsonpath "$.entries[1].path" == "/test/extension/with"
jsonpath "$.entries[1].health" == 100
jsonpath "$.entries[1].dependencies" == 0
jsonpath "$.entries[2].bytes" == 172
jsonpath "$.entries[2].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[2].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[2].identifier" == "{{base}}/test/extension/to-without"
jsonpath "$.entries[2].name" == "to-without"
jsonpath "$.entries[2].type" == "schema"
jsonpath "$.entries[2].alert" == null
jsonpath "$.entries[2].provenance" == null
jsonpath "$.entries[2].path" == "/test/extension/to-without"
jsonpath "$.entries[2].health" == 100
jsonpath "$.entries[2].dependencies" == 1

POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/list/response
```
{{last_response}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true
