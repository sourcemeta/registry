GET {{base}}/self/api/schemas/metadata/example/v2.0/schema
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

HEAD {{base}}/self/api/schemas/metadata/example/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
bytes count == 0

POST {{base}}/self/api/schemas/metadata/example/v2.0/schema
HTTP 405
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"

GET {{base}}/self/api/schemas/metadata/xyz
Accept: application/json
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"

GET {{base}}/self/api/schemas/metadata
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"
