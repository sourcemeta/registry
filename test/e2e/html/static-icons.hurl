HEAD {{base}}/self/static/apple-touch-icon.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count == 0
header "Access-Control-Allow-Origin" not exists

HEAD {{base}}/self/static/favicon.ico
HTTP 200
Content-Type: image/vnd.microsoft.icon
[Asserts]
bytes count == 0
header "Access-Control-Allow-Origin" not exists

HEAD {{base}}/self/static/icon.svg
HTTP 200
Content-Type: image/svg+xml
[Asserts]
bytes count == 0
header "Access-Control-Allow-Origin" not exists

HEAD {{base}}/self/static/icon_192x192.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count == 0
header "Access-Control-Allow-Origin" not exists

HEAD {{base}}/self/static/icon_512x512.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count == 0
header "Access-Control-Allow-Origin" not exists

HEAD {{base}}/self/static/manifest.webmanifest
HTTP 200
Content-Type: application/manifest+json
[Asserts]
bytes count == 0
header "Access-Control-Allow-Origin" not exists

GET {{base}}/self/static/apple-touch-icon.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count > 0
header "Access-Control-Allow-Origin" not exists

GET {{base}}/self/static/favicon.ico
HTTP 200
Content-Type: image/vnd.microsoft.icon
[Asserts]
bytes count > 0
header "Access-Control-Allow-Origin" not exists

GET {{base}}/self/static/icon.svg
HTTP 200
Content-Type: image/svg+xml
[Asserts]
bytes count > 0
header "Access-Control-Allow-Origin" not exists

GET {{base}}/self/static/icon_192x192.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count > 0
header "Access-Control-Allow-Origin" not exists

GET {{base}}/self/static/icon_512x512.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count > 0
header "Access-Control-Allow-Origin" not exists

GET {{base}}/self/static/manifest.webmanifest
HTTP 200
Content-Type: application/manifest+json
[Asserts]
bytes count > 0
header "Access-Control-Allow-Origin" not exists
