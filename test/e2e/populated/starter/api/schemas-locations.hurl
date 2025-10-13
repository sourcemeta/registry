GET {{base}}/self/api/schemas/locations/test/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.static['{{base}}/test/v2.0/schema'].base" == "{{base}}/test/v2.0/schema"
jsonpath "$.static['{{base}}/test/v2.0/schema'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema'].parent" == null
jsonpath "$.static['{{base}}/test/v2.0/schema'].pointer" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema'].relativePointer" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema'].root" == "{{base}}/test/v2.0/schema"
jsonpath "$.static['{{base}}/test/v2.0/schema'].type" == "resource"
jsonpath "$.static['{{base}}/test/v2.0/schema'].position" count == 4
jsonpath "$.static['{{base}}/test/v2.0/schema'].position[0]" == 1
jsonpath "$.static['{{base}}/test/v2.0/schema'].position[1]" == 1
jsonpath "$.static['{{base}}/test/v2.0/schema'].position[2]" == 5
jsonpath "$.static['{{base}}/test/v2.0/schema'].position[3]" == 1
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].base" == "{{base}}/test/v2.0/schema"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].parent" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].pointer" == "/$id"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].relativePointer" == "/$id"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].root" == "{{base}}/test/v2.0/schema"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].type" == "pointer"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].position" count == 4
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].position[0]" == 3
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].position[1]" == 3
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].position[2]" == 3
jsonpath "$.static['{{base}}/test/v2.0/schema#/$id'].position[3]" == 49
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].base" == "{{base}}/test/v2.0/schema"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].parent" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].pointer" == "/$schema"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].relativePointer" == "/$schema"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].root" == "{{base}}/test/v2.0/schema"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].type" == "pointer"
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].position" count == 4
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].position[0]" == 2
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].position[1]" == 3
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].position[2]" == 2
jsonpath "$.static['{{base}}/test/v2.0/schema#/$schema'].position[3]" == 54
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].base" == "{{base}}/test/v2.0/schema"
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].parent" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].pointer" == "/type"
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].relativePointer" == "/type"
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].root" == "{{base}}/test/v2.0/schema"
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].type" == "pointer"
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].position" count == 4
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].position[0]" == 4
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].position[1]" == 3
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].position[2]" == 4
jsonpath "$.static['{{base}}/test/v2.0/schema#/type'].position[3]" == 19
