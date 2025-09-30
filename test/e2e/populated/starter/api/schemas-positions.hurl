GET {{base}}/self/api/schemas/positions/test/v2.0/schema
Accept: application/json
HTTP 200
Content-Type: application/json
Access-Control-Allow-Origin: *
[Captures]
last_response: body
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
jsonpath "$['/$id'][3]" == 49
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
