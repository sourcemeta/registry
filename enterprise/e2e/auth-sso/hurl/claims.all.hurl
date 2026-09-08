# A policy naming no rule asks its provider for nothing beyond a subject
GET {{base}}/self/v1/auth/login/keycloak
HTTP 303
Cache-Control: no-store
[Asserts]
header "Location" startsWith "https://keycloak:8443/realms/main/protocol/openid-connect/auth?"
header "Location" contains "client_id=registry"
header "Location" contains "scope=openid"
header "Location" not contains "scope=openid%20email"
header "Location" not contains "claims="
cookie "sourcemeta_one_transaction" exists

# A policy naming a domain has to read an address, so the login asks for the
# scope OpenID Connect Core Section 5.4 says carries one. Nothing else does,
# so without this the rule could never match
GET {{base}}/self/v1/auth/login/corp
HTTP 303
Cache-Control: no-store
[Asserts]
header "Location" startsWith "https://keycloak:8443/realms/main/protocol/openid-connect/auth?"
header "Location" contains "client_id=registry"
header "Location" contains "scope=openid%20email"
header "Location" contains "claims=%7B%22id_token%22%3A%7B%22email%22%3A%7B%22essential%22%3Atrue%7D%2C%22email_verified%22%3A%7B%22essential%22%3Atrue%7D%7D%7D"
header "Location" contains "code_challenge_method=S256"
header "Location" contains "state="
header "Location" contains "nonce="
cookie "sourcemeta_one_transaction" exists

# A group is carried by no standard scope, so nothing is invented for it. The
# provider is asked through the claims request parameter instead, naming the
# claim against the identity token, which is what a rule is answered against
GET {{base}}/self/v1/auth/login/team
HTTP 303
Cache-Control: no-store
[Asserts]
header "Location" startsWith "https://keycloak:8443/realms/main/protocol/openid-connect/auth?"
header "Location" contains "client_id=registry"
header "Location" contains "scope=openid"
header "Location" not contains "scope=openid%20groups"
header "Location" not contains "%20groups"
header "Location" contains "claims=%7B%22id_token%22%3A%7B%22groups%22%3A%7B%22essential%22%3Atrue%7D%7D%7D"
cookie "sourcemeta_one_transaction" exists

# The gated collections are closed to anybody carrying nothing
GET {{base}}/team/roster.json
HTTP 404
Content-Type: application/problem+json
Cache-Control: no-store
Link: </self/v1/schemas/api/error>; rel="describedby"
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
[Captures]
team_denied: body
team_denied_schema: header "Link" regex "<([^>]+)>"
{
  "type": "urn:sourcemeta:one:not-found",
  "title": "Not Found",
  "status": 404,
  "detail": "There is nothing at this URL"
}

POST {{base}}/self/v1/api/schemas/evaluate{{team_denied_schema}}
```
{{team_denied}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

GET {{base}}/corp/policy.json
HTTP 404
Content-Type: application/problem+json
Cache-Control: no-store
Link: </self/v1/schemas/api/error>; rel="describedby"
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
[Captures]
corp_denied: body
corp_denied_schema: header "Link" regex "<([^>]+)>"
{
  "type": "urn:sourcemeta:one:not-found",
  "title": "Not Found",
  "status": 404,
  "detail": "There is nothing at this URL"
}

POST {{base}}/self/v1/api/schemas/evaluate{{corp_denied_schema}}
```
{{corp_denied}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A session another policy minted does not carry over, since a session is only
# ever read under the policy its payload names
GET {{base}}/team/roster.json
Cookie: sourcemeta_one_session=not-a-session
HTTP 404
Content-Type: application/problem+json
Cache-Control: no-store
Link: </self/v1/schemas/api/error>; rel="describedby"
{
  "type": "urn:sourcemeta:one:not-found",
  "title": "Not Found",
  "status": 404,
  "detail": "There is nothing at this URL"
}

# Neither gated collection appears in the root listing. A rule narrows who a
# policy admits, and whoever it does not admit is told no more than a stranger
# is, so the collections it governs are absent here rather than named as doors
# somebody might go and ask about
GET {{base}}/self/v1/api/list
HTTP 200
Content-Type: application/json
Cache-Control: public, max-age=0, must-revalidate
Link: </self/v1/schemas/api/list/response>; rel="describedby"
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
[Captures]
root_listing: body
root_listing_schema: header "Link" regex "<([^>]+)>"
[Asserts]
jsonpath "$.path" == "/"
jsonpath "$.url" == "{{base}}"
jsonpath "$.breadcrumb" count == 0
jsonpath "$.schemas" == 66
jsonpath "$.private" == false
jsonpath "$.entries" count == 2
jsonpath "$.entries[0].name" == "public"
jsonpath "$.entries[0].type" == "directory"
jsonpath "$.entries[0].path" == "/public/"
jsonpath "$.entries[0].private" == false
jsonpath "$.entries[0].schemas" == 1
jsonpath "$.entries[0].health" == 0
jsonpath "$.entries[1].name" == "self"
jsonpath "$.entries[1].type" == "directory"
jsonpath "$.entries[1].path" == "/self/"
jsonpath "$.entries[1].private" == false
jsonpath "$.entries[1].schemas" == 65
jsonpath "$.entries[1].health" == 99

POST {{base}}/self/v1/api/schemas/evaluate{{root_listing_schema}}
```
{{root_listing}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true

# A gated listing is closed to anybody carrying nothing, exactly as its
# schemas are
GET {{base}}/self/v1/api/list/team
HTTP 404
Content-Type: application/problem+json
Cache-Control: no-store
Link: </self/v1/schemas/api/error>; rel="describedby"
Access-Control-Allow-Origin: *
Access-Control-Expose-Headers: Link, ETag
[Captures]
team_listing_denied: body
team_listing_denied_schema: header "Link" regex "<([^>]+)>"
{
  "type": "urn:sourcemeta:one:not-found",
  "title": "Not Found",
  "status": 404,
  "detail": "There is nothing at this URL"
}

POST {{base}}/self/v1/api/schemas/evaluate{{team_listing_denied_schema}}
```
{{team_listing_denied}}
```
HTTP 200
[Asserts]
jsonpath "$.valid" == true
