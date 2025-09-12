GET {{base}}/self/api/schemas/locations/test/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.static['{{base}}/test/v2.0/schema.json'].base" == "{{base}}/test/v2.0/schema.json"
jsonpath "$.static['{{base}}/test/v2.0/schema.json'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema.json'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema.json'].parent" == null
jsonpath "$.static['{{base}}/test/v2.0/schema.json'].pointer" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema.json'].relativePointer" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema.json'].root" == "{{base}}/test/v2.0/schema.json"
jsonpath "$.static['{{base}}/test/v2.0/schema.json'].type" == "resource"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$id'].base" == "{{base}}/test/v2.0/schema.json"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$id'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$id'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$id'].parent" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$id'].pointer" == "/$id"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$id'].relativePointer" == "/$id"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$id'].root" == "{{base}}/test/v2.0/schema.json"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$id'].type" == "pointer"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$schema'].base" == "{{base}}/test/v2.0/schema.json"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$schema'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$schema'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$schema'].parent" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$schema'].pointer" == "/$schema"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$schema'].relativePointer" == "/$schema"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$schema'].root" == "{{base}}/test/v2.0/schema.json"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/$schema'].type" == "pointer"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/type'].base" == "{{base}}/test/v2.0/schema.json"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/type'].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/type'].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/type'].parent" == ""
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/type'].pointer" == "/type"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/type'].relativePointer" == "/type"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/type'].root" == "{{base}}/test/v2.0/schema.json"
jsonpath "$.static['{{base}}/test/v2.0/schema.json#/type'].type" == "pointer"

HEAD {{base}}/self/api/schemas/locations/test/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
bytes count == 0

POST {{base}}/self/api/schemas/locations/test/v2.0/schema
HTTP 405
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"

GET {{base}}/self/api/schemas/locations/xyz/
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"

GET {{base}}/self/api/schemas/locations
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"
