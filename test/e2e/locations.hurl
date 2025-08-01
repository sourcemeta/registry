GET {{base}}/example/v2.0/schema.json?locations=1
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$" count == 4
jsonpath "$[0].base" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[0].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$[0].parent" == null
jsonpath "$[0].pointer" == ""
jsonpath "$[0].referenceType" == "static"
jsonpath "$[0].relativePointer" == ""
jsonpath "$[0].root" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[0].type" == "resource"
jsonpath "$[0].uri" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[1].base" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[1].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$[1].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$[1].parent" == ""
jsonpath "$[1].pointer" == "/$id"
jsonpath "$[1].referenceType" == "static"
jsonpath "$[1].relativePointer" == "/$id"
jsonpath "$[1].root" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[1].type" == "pointer"
jsonpath "$[1].uri" == "{{base}}/example/v2.0/schema.json#/$id"
jsonpath "$[2].base" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[2].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$[2].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$[2].parent" == ""
jsonpath "$[2].pointer" == "/$schema"
jsonpath "$[2].referenceType" == "static"
jsonpath "$[2].relativePointer" == "/$schema"
jsonpath "$[2].root" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[2].type" == "pointer"
jsonpath "$[2].uri" == "{{base}}/example/v2.0/schema.json#/$schema"
jsonpath "$[3].base" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[3].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$[3].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$[3].parent" == ""
jsonpath "$[3].pointer" == "/type"
jsonpath "$[3].referenceType" == "static"
jsonpath "$[3].relativePointer" == "/type"
jsonpath "$[3].root" == "{{base}}/example/v2.0/schema.json"
jsonpath "$[3].type" == "pointer"
jsonpath "$[3].uri" == "{{base}}/example/v2.0/schema.json#/type"

GET {{base}}/example/v2.0?locations=1
Accept: text/html
HTTP 200
[Asserts]
header "Access-Control-Allow-Origin" not exists
