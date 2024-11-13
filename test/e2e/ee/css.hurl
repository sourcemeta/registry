# HEAD
HEAD {{base}}/style.min.css
HTTP 200
Content-Type: text/css
[Asserts]
bytes count == 0

# Without GZIP
GET {{base}}/style.min.css
HTTP 200
Content-Type: text/css
[Asserts]
bytes count > 0

# With GZIP
GET {{base}}/style.min.css
Accept-Encoding: gzip
HTTP 200
Content-Type: text/css
Content-Encoding: gzip
[Asserts]
bytes count > 0

# Idempotent ETag
GET {{base}}/style.min.css
HTTP 200
[Asserts]
header "ETag" exists
[Captures]
css_etag: header "ETag"
GET {{base}}/style.min.css
HTTP 200
[Asserts]
bytes count > 0
header "ETag" == {{css_etag}}

# If-None-Match with match
GET {{base}}/style.min.css
If-None-Match: {{css_etag}}
HTTP 304
[Asserts]
header "Content-Type" not exists
bytes count == 0

# If-None-Match with weak match
GET {{base}}/style.min.css
If-None-Match: W/{{css_etag}}
HTTP 304
[Asserts]
header "Content-Type" not exists
bytes count == 0

# If-None-Match without match
GET {{base}}/style.min.css
If-None-Match: "12345"
HTTP 200
Content-Type: text/css
[Asserts]
bytes count > 0

# Last-Modified
GET {{base}}/style.min.css
HTTP 200
[Asserts]
header "Last-Modified" matches /^(Sun|Mon|Tue|Wed|Thu|Fri|Sat), [0-3][0-9] (Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [0-9]{4} [0-2][0-9]:[0-5][0-9]:[0-5][0-9] GMT$/

# Idempotent Last-Modified
GET {{base}}/style.min.css
HTTP 200
[Asserts]
header "Last-Modified" exists
[Captures]
css_last_modified: header "Last-Modified"
GET {{base}}/style.min.css
HTTP 200
[Asserts]
header "Last-Modified" == {{css_last_modified}}

# Invalid If-Modified-Since
GET {{base}}/style.min.css
If-Modified-Since: FOO
Content-Type: text/css
HTTP 200
[Asserts]
bytes count > 0

# If-Modified-Since exact
GET {{base}}/style.min.css
If-Modified-Since: {{css_last_modified}}
HTTP 304
[Asserts]
header "Content-Type" not exists
bytes count == 0

# If-Modified-Since false
GET {{base}}/style.min.css
If-Modified-Since: Thu, 01 Jan 2100 00:00:00 GMT
HTTP 304
[Asserts]
header "Content-Type" not exists
bytes count == 0

# If-Modified-Since true
GET {{base}}/style.min.css
If-Modified-Since: Thu, 01 Jan 1970 00:00:00 GMT
HTTP 200
Content-Type: text/css
[Asserts]
bytes count > 0

# Proper HEAD
GET {{base}}/style.min.css
HTTP 200
[Asserts]
header "Content-Length" exists
[Captures]
css_content_length: header "Content-Length"
HEAD {{base}}/style.min.css
HTTP 200
[Asserts]
header "Content-Length" exists
header "Content-Length" == {{css_content_length}}
