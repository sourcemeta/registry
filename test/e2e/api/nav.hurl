GET {{base}}/.json
HTTP 404

GET {{base}}
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.url" == "/"
jsonpath "$.canonical" == "{{base}}"
jsonpath "$.breadcrumb" count == 0
jsonpath "$.entries" count == 6
jsonpath "$.entries[0].name" == "same"
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].url" == "/same"
jsonpath "$.entries[1].name" == "no-blaze"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].url" == "/no-blaze"
jsonpath "$.entries[2].name" == "hyper"
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].url" == "/hyper"
jsonpath "$.entries[3].name" == "geojson"
jsonpath "$.entries[3].title" == "GeoJSON"
jsonpath "$.entries[3].description" == "A format for encoding a variety of geographic data structures"
jsonpath "$.entries[3].github" == "geojson"
jsonpath "$.entries[3].website" == "https://geojson.org"
jsonpath "$.entries[3].type" == "directory"
jsonpath "$.entries[3].url" == "/geojson"
jsonpath "$.entries[4].name" == "example"
jsonpath "$.entries[4].title" == "Sourcemeta"
jsonpath "$.entries[4].description" == "My description"
jsonpath "$.entries[4].email" == "hello@sourcemeta.com"
jsonpath "$.entries[4].github" == "sourcemeta"
jsonpath "$.entries[4].website" == "https://www.sourcemeta.com"
jsonpath "$.entries[4].type" == "directory"
jsonpath "$.entries[4].url" == "/example"
jsonpath "$.entries[5].name" == "doc"
jsonpath "$.entries[5].title" == "A sample schema folder"
jsonpath "$.entries[5].description" == "For testing purposes"
jsonpath "$.entries[5].github" == "sourcemeta/registry"
jsonpath "$.entries[5].type" == "directory"
jsonpath "$.entries[5].url" == "/doc"

GET {{base}}/example
Accept: application/json
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
jsonpath "$.entries[0].id" == "http://localhost:8000/example/v2.0/schema.json"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].url" == "/example/v2.0/schema"

GET {{base}}/example/v2.0.json
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
jsonpath "$.entries[0].id" == "http://localhost:8000/example/v2.0/schema.json"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].url" == "/example/v2.0/schema"

GET {{base}}/example/v2.0.json
Accept: application/json
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
jsonpath "$.entries[0].id" == "http://localhost:8000/example/v2.0/schema.json"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].url" == "/example/v2.0/schema"

GET {{base}}/example/v2.0/schema.json?meta=1
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.bytes" == 138
jsonpath "$.baseDialect" == "draft7"
jsonpath "$.health" == 100
jsonpath "$.canonical" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.id" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.url" == "/example/v2.0/schema.json"
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "example"
jsonpath "$.breadcrumb[0].url" == "/example"
jsonpath "$.breadcrumb[1].name" == "v2.0"
jsonpath "$.breadcrumb[1].url" == "/example/v2.0"
jsonpath "$.breadcrumb[2].name" == "schema"
jsonpath "$.breadcrumb[2].url" == "/example/v2.0/schema"

GET {{base}}/example/v2.0/xxxxx.json?meta=1
Accept: application/json
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]  
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"
