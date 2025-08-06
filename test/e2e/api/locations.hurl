GET {{base}}/example/v2.0/schema.json?locations=1
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.static['{{base}}/example/v2.0/schema.json'].base" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.static['{{base}}/example/v2.0/schema.json'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/example/v2.0/schema.json'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/example/v2.0/schema.json'].parent" == null
jsonpath "$.static['{{base}}/example/v2.0/schema.json'].pointer" == ""
jsonpath "$.static['{{base}}/example/v2.0/schema.json'].relativePointer" == ""
jsonpath "$.static['{{base}}/example/v2.0/schema.json'].root" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.static['{{base}}/example/v2.0/schema.json'].type" == "resource"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$id'].base" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$id'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$id'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$id'].parent" == ""
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$id'].pointer" == "/$id"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$id'].relativePointer" == "/$id"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$id'].root" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$id'].type" == "pointer"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$schema'].base" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$schema'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$schema'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$schema'].parent" == ""
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$schema'].pointer" == "/$schema"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$schema'].relativePointer" == "/$schema"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$schema'].root" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/$schema'].type" == "pointer"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/type'].base" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/type'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/type'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/type'].parent" == ""
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/type'].pointer" == "/type"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/type'].relativePointer" == "/type"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/type'].root" == "{{base}}/example/v2.0/schema.json"
jsonpath "$.static['{{base}}/example/v2.0/schema.json#/type'].type" == "pointer"
