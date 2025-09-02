GET {{base}}
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.url" == "/"
jsonpath "$.canonical" == "{{base}}"
jsonpath "$.breadcrumb" count == 0
jsonpath "$.entries" count == 7
jsonpath "$.entries[0].name" == "same"
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].health" == 100
jsonpath "$.entries[0].url" == "/same"
jsonpath "$.entries[1].name" == "no-blaze"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].health" == 100
jsonpath "$.entries[1].url" == "/no-blaze"
jsonpath "$.entries[2].name" == "modelcontextprotocol"
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].health" == 78
jsonpath "$.entries[2].url" == "/modelcontextprotocol"
jsonpath "$.entries[3].name" == "hyper"
jsonpath "$.entries[3].type" == "directory"
jsonpath "$.entries[3].health" == 100
jsonpath "$.entries[3].url" == "/hyper"
jsonpath "$.entries[4].name" == "geojson"
jsonpath "$.entries[4].title" == "GeoJSON"
jsonpath "$.entries[4].description" == "A format for encoding a variety of geographic data structures"
jsonpath "$.entries[4].github" == "geojson"
jsonpath "$.entries[4].website" == "https://geojson.org"
jsonpath "$.entries[4].type" == "directory"
jsonpath "$.entries[4].health" == 91
jsonpath "$.entries[4].url" == "/geojson"
jsonpath "$.entries[5].name" == "example"
jsonpath "$.entries[5].title" == "Sourcemeta"
jsonpath "$.entries[5].description" == "My description"
jsonpath "$.entries[5].email" == "hello@sourcemeta.com"
jsonpath "$.entries[5].github" == "sourcemeta"
jsonpath "$.entries[5].website" == "https://www.sourcemeta.com"
jsonpath "$.entries[5].type" == "directory"
jsonpath "$.entries[5].health" == 100
jsonpath "$.entries[5].url" == "/example"
jsonpath "$.entries[6].name" == "doc"
jsonpath "$.entries[6].title" == "A sample schema folder"
jsonpath "$.entries[6].description" == "For testing purposes"
jsonpath "$.entries[6].github" == "sourcemeta/registry"
jsonpath "$.entries[6].type" == "directory"
jsonpath "$.entries[6].health" == 100
jsonpath "$.entries[6].url" == "/doc"

GET {{base}}/example
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
