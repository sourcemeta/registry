GET {{base}}/self/api/list
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.url" == "/"
jsonpath "$.canonical" == "{{base}}"
jsonpath "$.breadcrumb" count == 0
jsonpath "$.entries" count == 8
jsonpath "$.entries[0].name" == "sourcemeta"
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].health" == 100
jsonpath "$.entries[0].url" == "/sourcemeta"
jsonpath "$.entries[0].github" == "sourcemeta"
jsonpath "$.entries[0].description" == "A provider of premium tooling and services to support JSON Schema use in production"
jsonpath "$.entries[0].email" == "hello@sourcemeta.com"
jsonpath "$.entries[0].title" == "Sourcemeta"
jsonpath "$.entries[0].website" == "https://www.sourcemeta.com"
jsonpath "$.entries[1].name" == "same"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].health" == 100
jsonpath "$.entries[1].url" == "/same"
jsonpath "$.entries[2].name" == "no-blaze"
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].health" == 100
jsonpath "$.entries[2].url" == "/no-blaze"
jsonpath "$.entries[3].name" == "modelcontextprotocol"
jsonpath "$.entries[3].type" == "directory"
jsonpath "$.entries[3].health" == 78
jsonpath "$.entries[3].url" == "/modelcontextprotocol"
jsonpath "$.entries[4].name" == "hyper"
jsonpath "$.entries[4].type" == "directory"
jsonpath "$.entries[4].health" == 100
jsonpath "$.entries[4].url" == "/hyper"
jsonpath "$.entries[5].name" == "geojson"
jsonpath "$.entries[5].title" == "GeoJSON"
jsonpath "$.entries[5].description" == "A format for encoding a variety of geographic data structures"
jsonpath "$.entries[5].github" == "geojson"
jsonpath "$.entries[5].website" == "https://geojson.org"
jsonpath "$.entries[5].type" == "directory"
jsonpath "$.entries[5].health" == 91
jsonpath "$.entries[5].url" == "/geojson"
jsonpath "$.entries[6].name" == "example"
jsonpath "$.entries[6].title" == "Sourcemeta"
jsonpath "$.entries[6].description" == "My description"
jsonpath "$.entries[6].email" == "hello@sourcemeta.com"
jsonpath "$.entries[6].github" == "sourcemeta"
jsonpath "$.entries[6].website" == "https://www.sourcemeta.com"
jsonpath "$.entries[6].type" == "directory"
jsonpath "$.entries[6].health" == 100
jsonpath "$.entries[6].url" == "/example"
jsonpath "$.entries[7].name" == "doc"
jsonpath "$.entries[7].title" == "A sample schema folder"
jsonpath "$.entries[7].description" == "For testing purposes"
jsonpath "$.entries[7].github" == "sourcemeta/registry"
jsonpath "$.entries[7].type" == "directory"
jsonpath "$.entries[7].health" == 100
jsonpath "$.entries[7].url" == "/doc"

GET {{base}}/self/api/list/example
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.url" == "/example"
jsonpath "$.canonical" == "{{base}}/example"
jsonpath "$.breadcrumb" count == 1
jsonpath "$.breadcrumb[0].name" == "example"
jsonpath "$.breadcrumb[0].url" == "/example"
jsonpath "$.description" == "My description"
jsonpath "$.email" == "hello@sourcemeta.com"
jsonpath "$.github" == "sourcemeta"
jsonpath "$.title" == "Sourcemeta"
jsonpath "$.website" == "https://www.sourcemeta.com"
jsonpath "$.entries" count == 5
jsonpath "$.entries[0].name" == "v2.0"
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].health" == 100
jsonpath "$.entries[0].url" == "/example/v2.0"
jsonpath "$.entries[1].name" == "schemas"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].health" == 100
jsonpath "$.entries[1].url" == "/example/schemas"
jsonpath "$.entries[2].name" == "extension"
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].health" == 100
jsonpath "$.entries[2].url" == "/example/extension"
jsonpath "$.entries[3].name" == "camelcase"
jsonpath "$.entries[3].type" == "directory"
jsonpath "$.entries[3].health" == 100
jsonpath "$.entries[3].url" == "/example/camelcase"
jsonpath "$.entries[4].name" == "bundling"
jsonpath "$.entries[4].type" == "directory"
jsonpath "$.entries[4].health" == 100
jsonpath "$.entries[4].url" == "/example/bundling"

GET {{base}}/self/api/list/example/v2.0
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.url" == "/example/v2.0"
jsonpath "$.canonical" == "{{base}}/example/v2.0"
jsonpath "$.breadcrumb" count == 2
jsonpath "$.breadcrumb[0].name" == "example"
jsonpath "$.breadcrumb[0].url" == "/example"
jsonpath "$.breadcrumb[1].name" == "v2.0"
jsonpath "$.breadcrumb[1].url" == "/example/v2.0"
jsonpath "$.entries" count == 1
jsonpath "$.entries[0].bytes" == 138
jsonpath "$.entries[0].baseDialect" == "draft7"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].id" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].url" == "/example/v2.0/schema"
jsonpath "$.entries[0].health" == 100

GET {{base}}/self/api/list/example/v2.0.json
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"

GET {{base}}/self/api/list/example/schemas/versions
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.url" == "/example/schemas/versions"
jsonpath "$.canonical" == "{{base}}/example/schemas/versions"
jsonpath "$.health" == 100
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "example"
jsonpath "$.breadcrumb[0].url" == "/example"
jsonpath "$.breadcrumb[1].name" == "schemas"
jsonpath "$.breadcrumb[1].url" == "/example/schemas"
jsonpath "$.breadcrumb[2].name" == "versions"
jsonpath "$.breadcrumb[2].url" == "/example/schemas/versions"
jsonpath "$.entries" count == 1
jsonpath "$.entries[0].bytes" == 149
jsonpath "$.entries[0].baseDialect" == "draft7"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].id" == "{{base}}/example/schemas/versions/v1.2.3.json"
jsonpath "$.entries[0].name" == "v1.2.3"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].url" == "/example/schemas/versions/v1.2.3"
jsonpath "$.entries[0].health" == 100

GET {{base}}/self/api/list/example/extension
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.url" == "/example/extension"
jsonpath "$.canonical" == "{{base}}/example/extension"
jsonpath "$.health" == 100
jsonpath "$.breadcrumb" count == 2
jsonpath "$.breadcrumb[0].name" == "example"
jsonpath "$.breadcrumb[0].url" == "/example"
jsonpath "$.breadcrumb[1].name" == "extension"
jsonpath "$.breadcrumb[1].url" == "/example/extension"
jsonpath "$.entries" count == 3
jsonpath "$.entries[0].bytes" == 143
jsonpath "$.entries[0].baseDialect" == "draft7"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].id" == "{{base}}/example/extension/without.json"
jsonpath "$.entries[0].name" == "without"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].url" == "/example/extension/without"
jsonpath "$.entries[0].health" == 100
jsonpath "$.entries[1].bytes" == 147
jsonpath "$.entries[1].baseDialect" == "draft7"
jsonpath "$.entries[1].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[1].id" == "{{base}}/example/extension/with.schema.json"
jsonpath "$.entries[1].name" == "with"
jsonpath "$.entries[1].type" == "schema"
jsonpath "$.entries[1].url" == "/example/extension/with.schema"
jsonpath "$.entries[1].health" == 100
jsonpath "$.entries[2].bytes" == 180
jsonpath "$.entries[2].baseDialect" == "draft7"
jsonpath "$.entries[2].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[2].id" == "{{base}}/example/extension/to-without.json"
jsonpath "$.entries[2].name" == "to-without"
jsonpath "$.entries[2].type" == "schema"
jsonpath "$.entries[2].url" == "/example/extension/to-without"
jsonpath "$.entries[2].health" == 100

# API specification adherence

GET {{base}}/self/api/list
HTTP 200
[Captures]
list_body: body
POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/list
```
{{list_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/list/example/extension
HTTP 200
[Captures]
list_body: body
POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/list
```
{{list_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/self/api/list/example/v2.0.json
HTTP 404
[Captures]
list_body: body
POST {{base}}/self/api/schemas/evaluate/sourcemeta/registry/api/common/error
```
{{list_body}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true
