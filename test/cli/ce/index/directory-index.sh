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

ensure_not_exists() {
  [ ! -f "$1" ] || (echo "File must not exist: $1" 1>&2 && exit 1)
}

ensure_not_exists "$TMP/output/generated/index.json"
ensure_not_exists "$TMP/output/generated/example/index.json"
ensure_not_exists "$TMP/output/generated/example/schemas/index.json" 
