GET {{base}}/self/api/schemas/positions/example/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
jsonpath "$['']" count == 4
jsonpath "$[''][0]" == 1
jsonpath "$[''][1]" == 1
jsonpath "$[''][2]" == 5
jsonpath "$[''][3]" == 1
jsonpath "$['/$id']" count == 4
jsonpath "$['/$id'][0]" == 3
jsonpath "$['/$id'][1]" == 10
jsonpath "$['/$id'][2]" == 3
jsonpath "$['/$id'][3]" == 57
jsonpath "$['/$schema']" count == 4
jsonpath "$['/$schema'][0]" == 2
jsonpath "$['/$schema'][1]" == 14
jsonpath "$['/$schema'][2]" == 2
jsonpath "$['/$schema'][3]" == 54
jsonpath "$['/type']" count == 4
jsonpath "$['/type'][0]" == 4
jsonpath "$['/type'][1]" == 11
jsonpath "$['/type'][2]" == 4
jsonpath "$['/type'][3]" == 19

HEAD {{base}}/self/api/schemas/positions/example/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists
header "Last-Modified" exists
bytes count == 0

POST {{base}}/self/api/schemas/positions/example/v2.0/schema
HTTP 405
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 405
jsonpath "$.error" == "method-not-allowed"
jsonpath "$.message" == "This HTTP method is invalid for this URL"

GET {{base}}/self/api/schemas/positions/xyz/
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"

GET {{base}}/self/api/schemas/positions
HTTP 404
Content-Type: application/json
Access-Control-Allow-Origin: *
[Asserts]
jsonpath "$.code" == 404
jsonpath "$.error" == "not-found"
jsonpath "$.message" == "There is nothing at this URL"
