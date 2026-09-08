GET {{base}}/self/v1/api/list
HTTP 200
Cache-Control: public, max-age=0, must-revalidate
Content-Type: application/json
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
Link: </self/v1/schemas/api/list/response>; rel="describedby"
[Captures]
last_response: body
schema_path: header "Link" regex "<([^>]+)>"
[Asserts]
header "Vary" == "Accept-Encoding"
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
header "ETag" exists
header "Last-Modified" exists
jsonpath "$.path" == "/"
jsonpath "$.url" == "{{base}}"
jsonpath "$.breadcrumb" count == 0
jsonpath "$.schemas" == 142
jsonpath "$.entries" count == 4
jsonpath "$.private" == false
jsonpath "$.entries[0].name" == "no-blaze"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].health" == 0
jsonpath "$.entries[0].schemas" == 2
jsonpath "$.entries[0].path" == "/no-blaze/"
jsonpath "$.entries[1].name" == "self"
jsonpath "$.entries[1].private" == false
jsonpath "$.entries[1].title" == "Self"
jsonpath "$.entries[1].description" == "The schemas that define the current version of this instance"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].health" == 100
jsonpath "$.entries[1].schemas" == 65
jsonpath "$.entries[1].path" == "/self/"
jsonpath "$.entries[2].name" == "test"
jsonpath "$.entries[2].private" == false
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].health" == 19
jsonpath "$.entries[2].schemas" == 73
jsonpath "$.entries[2].path" == "/test/"
jsonpath "$.entries[3].name" == "twins"
jsonpath "$.entries[3].private" == false
jsonpath "$.entries[3].title" == "Twins"
jsonpath "$.entries[3].description" == "Schemas whose base name collides with a sibling directory"
jsonpath "$.entries[3].type" == "directory"
jsonpath "$.entries[3].schemas" == 2
jsonpath "$.entries[3].path" == "/twins/"

POST {{base}}/self/v1/api/schemas/evaluate{{schema_path}}
```
{{last_response}}
```
HTTP 200
Cache-Control: no-store
Link: </self/v1/schemas/api/schemas/evaluate/response>; rel="describedby"
[Asserts]
header "Vary" not exists
header "Referrer-Policy" not exists
header "Content-Security-Policy" not exists
header "X-Frame-Options" not exists
header "Date" matches /^(Mon|Tue|Wed|Thu|Fri|Sat|Sun), (0[1-9]|[12][0-9]|3[01]) (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} ([01][0-9]|2[0-3]):[0-5][0-9]:[0-5][0-9] GMT$/
jsonpath "$.valid" == true
