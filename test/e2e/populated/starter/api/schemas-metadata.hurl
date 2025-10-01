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
jsonpath "$.dependencies" == 0
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
jsonpath "$.dependencies" == 0
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

GET {{base}}/self/api/schemas/metadata/test/bundling/double
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.bytes" == 269
jsonpath "$.baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.health" == 100
jsonpath "$.dependencies" == 3
jsonpath "$.dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.identifier" == "{{base}}/test/bundling/double"
jsonpath "$.path" == "/test/bundling/double"
jsonpath "$.protected" == false
jsonpath "$.alert" == null
jsonpath "$.provenance" == null
jsonpath "$.examples" count == 0
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test"
jsonpath "$.breadcrumb[1].name" == "bundling"
jsonpath "$.breadcrumb[1].path" == "/test/bundling"
jsonpath "$.breadcrumb[2].name" == "double"
jsonpath "$.breadcrumb[2].path" == "/test/bundling/double"
