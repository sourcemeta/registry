GET {{base}}/.json
HTTP 404

GET {{base}}
Accept: application/json
HTTP 200
Content-Type: application/json
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.url" == "/"
jsonpath "$.canonical" == "{{base}}"
jsonpath "$.breadcrumb" count == 0
jsonpath "$.entries" count == 4
jsonpath "$.entries[0].name" == "same"
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].url" == "/same"
jsonpath "$.entries[1].name" == "hyper"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].url" == "/hyper"
jsonpath "$.entries[2].name" == "example"
jsonpath "$.entries[2].title" == "Sourcemeta"
jsonpath "$.entries[2].description" == "My description"
jsonpath "$.entries[2].email" == "hello@sourcemeta.com"
jsonpath "$.entries[2].github" == "sourcemeta"
jsonpath "$.entries[2].website" == "https://www.sourcemeta.com"
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].url" == "/example"
jsonpath "$.entries[3].name" == "doc"
jsonpath "$.entries[3].title" == "A sample schema folder"
jsonpath "$.entries[3].description" == "For testing purposes"
jsonpath "$.entries[3].github" == "sourcemeta/registry"
jsonpath "$.entries[3].type" == "directory"
jsonpath "$.entries[3].url" == "/doc"

GET {{base}}/example
Accept: application/json
HTTP 200
Content-Type: application/json
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
jsonpath "$.entries[0].url" == "/example/v2.0"
jsonpath "$.entries[1].name" == "schemas"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].url" == "/example/schemas"
jsonpath "$.entries[2].name" == "extension"
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].url" == "/example/extension"
jsonpath "$.entries[3].name" == "camelcase"
jsonpath "$.entries[3].type" == "directory"
jsonpath "$.entries[3].url" == "/example/camelcase"
jsonpath "$.entries[4].name" == "bundling"
jsonpath "$.entries[4].type" == "directory"
jsonpath "$.entries[4].url" == "/example/bundling"

GET {{base}}/example/v2.0
Accept: application/json
HTTP 200
Content-Type: application/json
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
jsonpath "$.entries[0].baseDialect" == "draft7"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].id" == "http://localhost:8000/example/v2.0/schema.json"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].url" == "/example/v2.0/schema.json"

GET {{base}}/example/v2.0.json
HTTP 200
Content-Type: application/json
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
jsonpath "$.entries[0].baseDialect" == "draft7"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].id" == "http://localhost:8000/example/v2.0/schema.json"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].url" == "/example/v2.0/schema.json"

GET {{base}}/example/v2.0.json
Accept: application/json
HTTP 200
Content-Type: application/json
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
jsonpath "$.entries[0].baseDialect" == "draft7"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].id" == "http://localhost:8000/example/v2.0/schema.json"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].url" == "/example/v2.0/schema.json"
