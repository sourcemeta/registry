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

"$1" "$TMP/configuration.json" "$TMP/output"

cat << 'EOF' > "$TMP/index-top-level.json"
{
  "entries": [
    {
      "name": "example",
      "type": "directory",
      "url": "/example"
    }
  ],
  "breadcrumb": []
}
EOF

cat << 'EOF' > "$TMP/index-example.json"
{
  "entries": [
    {
      "name": "schemas",
      "type": "directory",
      "url": "/example/schemas"
    }
  ],
  "breadcrumb": [
    {
      "name": "example",
      "url": "/example"
    }
  ]
}
EOF

cat << 'EOF' > "$TMP/index-schemas.json"
{
  "entries": [
    {
      "name": "test.json",
      "type": "schema",
      "url": "/example/schemas/test.json"
    }
  ],
  "breadcrumb": [
    {
      "name": "example",
      "url": "/example"
    },
    {
      "name": "schemas",
      "url": "/example/schemas"
    }
  ]
}
EOF

diff "$TMP/output/generated/index.json" "$TMP/index-top-level.json"
diff "$TMP/output/generated/example/index.json" "$TMP/index-example.json"
diff "$TMP/output/generated/example/schemas/index.json" "$TMP/index-schemas.json"
