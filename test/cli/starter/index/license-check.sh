#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "http://localhost:8000",
  "port": 8000,
  "contents": {
    "example": {
      "base": "https://example.com",
      "path": "./schemas"
    }
  }
}
EOF

mkdir "$TMP/schemas"
cat << 'EOF' > "$TMP/schemas/schema.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/schema"
}
EOF

"$1" "$TMP/registry.json" "$TMP/dist"
