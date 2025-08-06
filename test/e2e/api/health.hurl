GET {{base}}/example/v2.0/schema.json?health=1
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.score" == 100
jsonpath "$.errors" count == 0

GET {{base}}/geojson/v1.0.5/polygon.json?health=1
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.score" == 88
jsonpath "$.errors" count == 2
jsonpath "$.errors[0].pointer" == "/properties/type"
jsonpath "$.errors[0].name" == "enum_to_const"
jsonpath "$.errors[0].message" == "An `enum` of a single value can be expressed as `const`"
jsonpath "$.errors[0].description" == null
jsonpath "$.errors[1].pointer" == "/properties/type"
jsonpath "$.errors[1].name" == "enum_with_type"
jsonpath "$.errors[1].message" == "Setting `type` alongside `enum` is considered an anti-pattern, as the enumeration choices already imply their respective types"
jsonpath "$.errors[1].description" == null
