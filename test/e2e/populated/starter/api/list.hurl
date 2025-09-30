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
jsonpath "$.entries[0].protected" == false
jsonpath "$.entries[0].alert" == null
jsonpath "$.entries[0].provenance" == null
jsonpath "$.entries[0].path" == "/test/schemas/versions/v1.2.3"
jsonpath "$.entries[0].health" == 100
