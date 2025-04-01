HEAD {{base}}/static/apple-touch-icon.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count == 0

HEAD {{base}}/static/favicon.ico
HTTP 200
Content-Type: image/vnd.microsoft.icon
[Asserts]
bytes count == 0

HEAD {{base}}/static/icon.svg
HTTP 200
Content-Type: image/svg+xml
[Asserts]
bytes count == 0

HEAD {{base}}/static/icon_192x192.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count == 0

HEAD {{base}}/static/icon_512x512.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count == 0

HEAD {{base}}/static/manifest.webmanifest
HTTP 200
Content-Type: application/manifest+json
[Asserts]
bytes count == 0

GET {{base}}/static/apple-touch-icon.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count > 0

GET {{base}}/static/favicon.ico
HTTP 200
Content-Type: image/vnd.microsoft.icon
[Asserts]
bytes count > 0

GET {{base}}/static/icon.svg
HTTP 200
Content-Type: image/svg+xml
[Asserts]
bytes count > 0

GET {{base}}/static/icon_192x192.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count > 0

GET {{base}}/static/icon_512x512.png
HTTP 200
Content-Type: image/png
[Asserts]
bytes count > 0

GET {{base}}/static/manifest.webmanifest
HTTP 200
Content-Type: application/manifest+json
[Asserts]
bytes count > 0
