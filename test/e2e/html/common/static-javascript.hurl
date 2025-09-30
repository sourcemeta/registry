GET {{base}}/self/static/main.min.js
HTTP 200
Content-Type: text/javascript
[Asserts]
bytes count > 0
header "Access-Control-Allow-Origin" not exists
