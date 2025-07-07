GET {{base}}/example/schemas/yaml.yaml
HTTP 404
GET {{base}}/example/schemas/yaml.yaml.json
HTTP 404

GET {{base}}/example/schemas/yaml.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
[Asserts]
header "ETag" exists

GET {{base}}/example/schemas/yaml.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/yaml.json",
  "type": "string"
}

GET {{base}}/example/schemas/yaml.yml
HTTP 404
GET {{base}}/example/schemas/yaml.yml.json
HTTP 404

GET {{base}}/example/schemas/yml.json
HTTP 200
Content-Type: application/schema+json
Link: <http://json-schema.org/draft-07/schema\#>; rel="describedby"
[Asserts]
header "ETag" exists

GET {{base}}/example/schemas/yml.json
HTTP 200
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "{{base}}/example/schemas/yml.json",
  "type": "string"
}
