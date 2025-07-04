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

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/configuration.json" "$TMP/output"

cat << 'EOF' > "$TMP/index-top-level.json"
{"entries":[{"name":"example","type":"directory","url":"/example"}],"breadcrumb":[]}
EOF

cat << 'EOF' > "$TMP/index-example.json"
{"entries":[{"name":"schemas","type":"directory","url":"/example/schemas"}],"breadcrumb":[{"name":"example","url":"/example"}]}
EOF

cat << EOF > "$TMP/index-schemas.json"
{"entries":[{"name":"test","id":"https://sourcemeta.com/example/schemas/test.json","url":"/example/schemas/test.json","baseDialect":"draft7","dialect":"http://json-schema.org/draft-07/schema#","type":"schema"}],"breadcrumb":[{"name":"example","url":"/example"},{"name":"schemas","url":"/example/schemas"}]}
EOF

cat << EOF > "$TMP/index-schema.json"
{"id":"https://sourcemeta.com/example/schemas/test.json","url":"/example/schemas/test.json","baseDialect":"draft7","dialect":"http://json-schema.org/draft-07/schema#"}
EOF

diff "$TMP/output/explorer/pages.nav" "$TMP/index-top-level.json"
diff "$TMP/output/explorer/pages/example.nav" "$TMP/index-example.json"
diff "$TMP/output/explorer/pages/example/schemas.nav" "$TMP/index-schemas.json"
diff "$TMP/output/explorer/pages/example/schemas/test.nav" "$TMP/index-schema.json"
