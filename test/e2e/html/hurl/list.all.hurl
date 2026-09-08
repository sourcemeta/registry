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
jsonpath "$.schemas" == 115
jsonpath "$.entries" count >= 2
jsonpath "$.private" == false
jsonpath "$.entries[0].name" == "self"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].title" == "Self"
jsonpath "$.entries[0].description" == "The schemas that define the current version of this instance"
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].health" == 100
jsonpath "$.entries[0].schemas" == 65
jsonpath "$.entries[0].path" == "/self/"
jsonpath "$.entries[1].name" == "test"
jsonpath "$.entries[1].private" == false
jsonpath "$.entries[1].title" == "Test"
jsonpath "$.entries[1].description" == "A directory full of testing schemas"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].health" == 13
jsonpath "$.entries[1].schemas" == 50
jsonpath "$.entries[1].path" == "/test/"

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

GET {{base}}/self/v1/api/list/test
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
jsonpath "$.path" == "/test"
jsonpath "$.url" == "{{base}}/test"
jsonpath "$.breadcrumb" count == 1
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test/"
jsonpath "$.description" == "A directory full of testing schemas"
jsonpath "$.title" == "Test"
jsonpath "$.schemas" == 50
jsonpath "$.entries" count == 13
jsonpath "$.private" == false
jsonpath "$.entries[0].name" == "v2.0"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].health" == 0
jsonpath "$.entries[0].schemas" == 1
jsonpath "$.entries[0].path" == "/test/v2.0/"
jsonpath "$.entries[1].name" == "bundling"
jsonpath "$.entries[1].private" == false
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].health" == 59
jsonpath "$.entries[1].schemas" == 2
jsonpath "$.entries[1].path" == "/test/bundling/"
jsonpath "$.entries[2].name" == "camelcase"
jsonpath "$.entries[2].private" == false
jsonpath "$.entries[2].type" == "directory"
jsonpath "$.entries[2].health" == 25
jsonpath "$.entries[2].schemas" == 2
jsonpath "$.entries[2].path" == "/test/camelcase/"
jsonpath "$.entries[3].name" == "doc"
jsonpath "$.entries[3].private" == false
jsonpath "$.entries[3].type" == "directory"
jsonpath "$.entries[3].health" == 0
jsonpath "$.entries[3].schemas" == 4
jsonpath "$.entries[3].path" == "/test/doc/"
jsonpath "$.entries[3].title" == "A sample schema folder"
jsonpath "$.entries[3].description" == "For **testing** purposes with a [link](https://example.com)"
jsonpath "$.entries[3].github" == "sourcemeta/one"
jsonpath "$.entries[4].name" == "draft3"
jsonpath "$.entries[4].private" == false
jsonpath "$.entries[4].type" == "directory"
jsonpath "$.entries[4].health" == 25
jsonpath "$.entries[4].schemas" == 2
jsonpath "$.entries[4].path" == "/test/draft3/"
jsonpath "$.entries[5].name" == "extension"
jsonpath "$.entries[5].private" == false
jsonpath "$.entries[5].type" == "directory"
jsonpath "$.entries[5].health" == 17
jsonpath "$.entries[5].schemas" == 3
jsonpath "$.entries[5].path" == "/test/extension/"
jsonpath "$.entries[6].name" == "hyper"
jsonpath "$.entries[6].private" == false
jsonpath "$.entries[6].type" == "directory"
jsonpath "$.entries[6].health" == 34
jsonpath "$.entries[6].schemas" == 1
jsonpath "$.entries[6].path" == "/test/hyper/"
jsonpath "$.entries[7].name" == "markdown-alert"
jsonpath "$.entries[7].private" == false
jsonpath "$.entries[7].type" == "directory"
jsonpath "$.entries[7].schemas" == 1
jsonpath "$.entries[7].path" == "/test/markdown-alert/"
jsonpath "$.entries[8].name" == "no-base"
jsonpath "$.entries[8].private" == false
jsonpath "$.entries[8].type" == "directory"
jsonpath "$.entries[8].health" == 0
jsonpath "$.entries[8].schemas" == 2
jsonpath "$.entries[8].path" == "/test/no-base/"
jsonpath "$.entries[9].name" == "no-blaze"
jsonpath "$.entries[9].private" == false
jsonpath "$.entries[9].type" == "directory"
jsonpath "$.entries[9].health" == 0
jsonpath "$.entries[9].schemas" == 1
jsonpath "$.entries[9].path" == "/test/no-blaze/"
jsonpath "$.entries[10].name" == "same"
jsonpath "$.entries[10].private" == false
jsonpath "$.entries[10].type" == "directory"
jsonpath "$.entries[10].health" == 0
jsonpath "$.entries[10].schemas" == 1
jsonpath "$.entries[10].path" == "/test/same/"
jsonpath "$.entries[11].name" == "schemas"
jsonpath "$.entries[11].private" == false
jsonpath "$.entries[11].type" == "directory"
jsonpath "$.entries[11].health" == 6
jsonpath "$.entries[11].schemas" == 29
jsonpath "$.entries[11].path" == "/test/schemas/"
jsonpath "$.entries[12].name" == "unsafe-alert"
jsonpath "$.entries[12].private" == false
jsonpath "$.entries[12].type" == "directory"
jsonpath "$.entries[12].schemas" == 1
jsonpath "$.entries[12].path" == "/test/unsafe-alert/"

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

GET {{base}}/self/v1/api/list/test/v2.0
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
jsonpath "$.path" == "/test/v2.0"
jsonpath "$.url" == "{{base}}/test/v2.0"
jsonpath "$.schemas" == 1
jsonpath "$.breadcrumb" count == 2
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test/"
jsonpath "$.breadcrumb[1].name" == "v2.0"
jsonpath "$.breadcrumb[1].path" == "/test/v2.0/"
jsonpath "$.entries" count == 1
jsonpath "$.private" == false
jsonpath "$.entries[0].bytes" == 130
jsonpath "$.entries[0].bytesBundled" == 130
jsonpath "$.entries[0].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].identifier" == "{{base}}/test/v2.0/schema"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].alert" == null
jsonpath "$.entries[0].path" == "/test/v2.0/schema"
jsonpath "$.entries[0].health" == 0
jsonpath "$.entries[0].dependencies" == 0
jsonpath "$.entries[0].priority" == 50

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

GET {{base}}/self/v1/api/list/test/v2.0.json
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
jsonpath "$.path" == "/test/v2.0"
jsonpath "$.url" == "{{base}}/test/v2.0"
jsonpath "$.schemas" == 1
jsonpath "$.breadcrumb" count == 2
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test/"
jsonpath "$.breadcrumb[1].name" == "v2.0"
jsonpath "$.breadcrumb[1].path" == "/test/v2.0/"
jsonpath "$.entries" count == 1
jsonpath "$.private" == false
jsonpath "$.entries[0].bytes" == 130
jsonpath "$.entries[0].bytesBundled" == 130
jsonpath "$.entries[0].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].identifier" == "{{base}}/test/v2.0/schema"
jsonpath "$.entries[0].name" == "schema"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].alert" == null
jsonpath "$.entries[0].path" == "/test/v2.0/schema"
jsonpath "$.entries[0].health" == 0
jsonpath "$.entries[0].dependencies" == 0
jsonpath "$.entries[0].priority" == 50

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

GET {{base}}/self/v1/api/list/test/schemas/versions
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
jsonpath "$.path" == "/test/schemas/versions"
jsonpath "$.url" == "{{base}}/test/schemas/versions"
jsonpath "$.health" == 0
jsonpath "$.schemas" == 1
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test/"
jsonpath "$.breadcrumb[1].name" == "schemas"
jsonpath "$.breadcrumb[1].path" == "/test/schemas/"
jsonpath "$.breadcrumb[2].name" == "versions"
jsonpath "$.breadcrumb[2].path" == "/test/schemas/versions/"
jsonpath "$.entries" count == 1
jsonpath "$.private" == false
jsonpath "$.entries[0].bytes" == 141
jsonpath "$.entries[0].bytesBundled" == 141
jsonpath "$.entries[0].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].identifier" == "{{base}}/test/schemas/versions/v1.2.3"
jsonpath "$.entries[0].name" == "v1.2.3"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].alert" == null
jsonpath "$.entries[0].path" == "/test/schemas/versions/v1.2.3"
jsonpath "$.entries[0].health" == 0
jsonpath "$.entries[0].dependencies" == 0
jsonpath "$.entries[0].priority" == 50

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

GET {{base}}/self/v1/api/list/test/schemas/clash/foo
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
jsonpath "$.path" == "/test/schemas/clash/foo"
jsonpath "$.url" == "{{base}}/test/schemas/clash/foo"
jsonpath "$.health" == 0
jsonpath "$.schemas" == 1
jsonpath "$.breadcrumb" count == 4
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test/"
jsonpath "$.breadcrumb[1].name" == "schemas"
jsonpath "$.breadcrumb[1].path" == "/test/schemas/"
jsonpath "$.breadcrumb[2].name" == "clash"
jsonpath "$.breadcrumb[2].path" == "/test/schemas/clash/"
jsonpath "$.breadcrumb[3].name" == "foo"
jsonpath "$.breadcrumb[3].path" == "/test/schemas/clash/foo/"
jsonpath "$.entries" count == 1
jsonpath "$.private" == false
jsonpath "$.entries[0].bytes" == 124
jsonpath "$.entries[0].bytesBundled" == 124
jsonpath "$.entries[0].baseDialect" == "https://json-schema.org/draft/2020-12/schema"
jsonpath "$.entries[0].dialect" == "https://json-schema.org/draft/2020-12/schema"
jsonpath "$.entries[0].identifier" == "{{base}}/test/schemas/clash/foo/bar"
jsonpath "$.entries[0].name" == "bar"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].alert" == null
jsonpath "$.entries[0].path" == "/test/schemas/clash/foo/bar"
jsonpath "$.entries[0].health" == 0
jsonpath "$.entries[0].dependencies" == 0
jsonpath "$.entries[0].priority" == 50

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

GET {{base}}/self/v1/api/list/test/schemas/clash
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
jsonpath "$.path" == "/test/schemas/clash"
jsonpath "$.url" == "{{base}}/test/schemas/clash"
jsonpath "$.health" == 0
jsonpath "$.schemas" == 2
jsonpath "$.breadcrumb" count == 3
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test/"
jsonpath "$.breadcrumb[1].name" == "schemas"
jsonpath "$.breadcrumb[1].path" == "/test/schemas/"
jsonpath "$.breadcrumb[2].name" == "clash"
jsonpath "$.breadcrumb[2].path" == "/test/schemas/clash/"
jsonpath "$.entries" count == 2
jsonpath "$.private" == false
jsonpath "$.entries[0].name" == "foo"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].health" == 0
jsonpath "$.entries[0].schemas" == 1
jsonpath "$.entries[0].path" == "/test/schemas/clash/foo/"
jsonpath "$.entries[1].name" == "foo"
jsonpath "$.entries[1].private" == false
jsonpath "$.entries[1].type" == "schema"
jsonpath "$.entries[1].bytes" == 120
jsonpath "$.entries[1].bytesBundled" == 120
jsonpath "$.entries[1].baseDialect" == "https://json-schema.org/draft/2020-12/schema"
jsonpath "$.entries[1].dialect" == "https://json-schema.org/draft/2020-12/schema"
jsonpath "$.entries[1].identifier" == "{{base}}/test/schemas/clash/foo"
jsonpath "$.entries[1].path" == "/test/schemas/clash/foo"
jsonpath "$.entries[1].health" == 0
jsonpath "$.entries[1].dependencies" == 0
jsonpath "$.entries[1].alert" == null
jsonpath "$.entries[1].priority" == 50

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

GET {{base}}/self/v1/api/list/test/extension
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
jsonpath "$.path" == "/test/extension"
jsonpath "$.url" == "{{base}}/test/extension"
jsonpath "$.health" == 17
jsonpath "$.schemas" == 3
jsonpath "$.breadcrumb" count == 2
jsonpath "$.breadcrumb[0].name" == "test"
jsonpath "$.breadcrumb[0].path" == "/test/"
jsonpath "$.breadcrumb[1].name" == "extension"
jsonpath "$.breadcrumb[1].path" == "/test/extension/"
jsonpath "$.entries" count == 3
jsonpath "$.private" == false
jsonpath "$.entries[0].bytes" == 172
jsonpath "$.entries[0].bytesBundled" == 400
jsonpath "$.entries[0].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[0].identifier" == "{{base}}/test/extension/to-without"
jsonpath "$.entries[0].name" == "to-without"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].type" == "schema"
jsonpath "$.entries[0].alert" == null
jsonpath "$.entries[0].path" == "/test/extension/to-without"
jsonpath "$.entries[0].health" == 50
jsonpath "$.entries[0].dependencies" == 1
jsonpath "$.entries[0].priority" == 50
jsonpath "$.entries[1].bytes" == 132
jsonpath "$.entries[1].bytesBundled" == 132
jsonpath "$.entries[1].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[1].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[1].identifier" == "{{base}}/test/extension/with"
jsonpath "$.entries[1].name" == "with"
jsonpath "$.entries[1].private" == false
jsonpath "$.entries[1].type" == "schema"
jsonpath "$.entries[1].alert" == null
jsonpath "$.entries[1].path" == "/test/extension/with"
jsonpath "$.entries[1].health" == 0
jsonpath "$.entries[1].dependencies" == 0
jsonpath "$.entries[1].priority" == 50
jsonpath "$.entries[2].bytes" == 135
jsonpath "$.entries[2].bytesBundled" == 135
jsonpath "$.entries[2].baseDialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[2].dialect" == "http://json-schema.org/draft-07/schema#"
jsonpath "$.entries[2].identifier" == "{{base}}/test/extension/without"
jsonpath "$.entries[2].name" == "without"
jsonpath "$.entries[2].private" == false
jsonpath "$.entries[2].type" == "schema"
jsonpath "$.entries[2].alert" == null
jsonpath "$.entries[2].path" == "/test/extension/without"
jsonpath "$.entries[2].health" == 0
jsonpath "$.entries[2].dependencies" == 0
jsonpath "$.entries[2].priority" == 50

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
