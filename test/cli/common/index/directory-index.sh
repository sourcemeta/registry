#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/configuration.json"
{
  "url": "https://sourcemeta.com",
  "port": 8000,
  "schemas": {
    "example/schemas": {
      "base": "https://example.com",
      "path": "./schemas"
    }
  }
}
EOF

mkdir "$TMP/schemas"

cat << 'EOF' > "$TMP/schemas/test.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/test.json"
}
EOF

# TODO: Serve these metadata files over the API so we test over there

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/configuration.json" "$TMP/output"

printf '%s' '{"entries":[{"name":"example","type":"directory","url":"/example"}],"breadcrumb":[]}' > "$TMP/index-top-level.json"

printf '%s' '{"entries":[{"name":"schemas","type":"directory","url":"/example/schemas"}],"breadcrumb":[{"name":"example","url":"/example"}]}' > "$TMP/index-example.json"

printf '%s' '{"entries":[{"name":"test","id":"https://sourcemeta.com/example/schemas/test.json","url":"/example/schemas/test.json","baseDialect":"draft7","dialect":"http://json-schema.org/draft-07/schema#","type":"schema"}],"breadcrumb":[{"name":"example","url":"/example"},{"name":"schemas","url":"/example/schemas"}]}' > "$TMP/index-schemas.json"

printf '%s' '{"id":"https://sourcemeta.com/example/schemas/test.json","url":"/example/schemas/test.json","baseDialect":"draft7","dialect":"http://json-schema.org/draft-07/schema#"}' > "$TMP/index-schema.json"

diff "$TMP/output/explorer/pages.nav" "$TMP/index-top-level.json"
diff "$TMP/output/explorer/pages/example.nav" "$TMP/index-example.json"
diff "$TMP/output/explorer/pages/example/schemas.nav" "$TMP/index-schemas.json"
diff "$TMP/output/explorer/pages/example/schemas/test.nav" "$TMP/index-schema.json"
