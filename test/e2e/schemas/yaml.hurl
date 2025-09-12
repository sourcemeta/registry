GET {{base}}/test/schemas/yaml.yaml
HTTP 404
GET {{base}}/test/schemas/yaml.yaml.json
HTTP 404

GET {{base}}/test/schemas/yaml.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists

GET {{base}}/test/schemas/yaml.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/yaml.json",
  "type": "string"
}

GET {{base}}/test/schemas/yaml.yml
HTTP 404
GET {{base}}/test/schemas/yaml.yml.json
HTTP 404

GET {{base}}/test/schemas/yml.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
Access-Control-Allow-Origin: *
[Asserts]
header "ETag" exists

GET {{base}}/test/schemas/yml.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/test/schemas/yml.json",
  "type": "string"
}
