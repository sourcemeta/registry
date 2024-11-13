HEAD {{base}}/apple-touch-icon.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count == 0

HEAD {{base}}/favicon.ico
HTTP 200
Content-Type: image/vnd.microsoft.icon
[Asserts]
bytes count == 0

HEAD {{base}}/icon.svg
HTTP 200
Content-Type: image/svg+xml
[Asserts]
bytes count == 0

HEAD {{base}}/icon_192x192.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count == 0

HEAD {{base}}/icon_512x512.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count == 0

HEAD {{base}}/manifest.webmanifest
HTTP 200
Content-Type: application/manifest+json
[Asserts]
bytes count == 0

GET {{base}}/apple-touch-icon.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count > 0

GET {{base}}/favicon.ico
HTTP 200
Content-Type: image/vnd.microsoft.icon
[Asserts]
bytes count > 0

GET {{base}}/icon.svg
HTTP 200
Content-Type: image/svg+xml
[Asserts]
bytes count > 0

GET {{base}}/icon_192x192.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count > 0

GET {{base}}/icon_512x512.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count > 0

GET {{base}}/manifest.webmanifest
HTTP 200
Content-Type: application/manifest+json
[Asserts]
bytes count > 0
