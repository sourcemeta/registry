#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "https://sourcemeta.com/",
  "contents": {
    "example": {
      "contents": {
        "schemas": {
          "baseUri": "https://example.com/",
          "path": "./schemas"
        }
      }
    }
  }
}
EOF

mkdir "$TMP/schemas"

cat << 'EOF' > "$TMP/schemas/test.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/old.json"
}
EOF

"$1" "$TMP/registry.json" "$TMP/output"

exists() {
  [ -f "$1" ] || (echo "File MUST exist: $1" 1>&2 && exit 1)
}

not_exists() {
  [ ! -f "$1" ] || (echo "File MUST NOT exists: $1" 1>&2 && exit 1)
}

exists "$TMP/output/explorer/example/schemas/old/%/schema.metapack"
exists "$TMP/output/schemas/example/schemas/old/%/bundle.metapack"
exists "$TMP/output/schemas/example/schemas/old/%/editor.metapack"
exists "$TMP/output/schemas/example/schemas/old/%/blaze-exhaustive.metapack"
exists "$TMP/output/schemas/example/schemas/old/%/schema.metapack"

cat << 'EOF' > "$TMP/schemas/test.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/new"
}
EOF

"$1" "$TMP/registry.json" "$TMP/output"

exists "$TMP/output/explorer/example/schemas/new/%/schema.metapack"
exists "$TMP/output/schemas/example/schemas/new/%/bundle.metapack"
exists "$TMP/output/schemas/example/schemas/new/%/editor.metapack"
exists "$TMP/output/schemas/example/schemas/new/%/blaze-exhaustive.metapack"
exists "$TMP/output/schemas/example/schemas/new/%/schema.metapack"

not_exists "$TMP/output/explorer/example/schemas/old/%/schema.metapack"
not_exists "$TMP/output/schemas/example/schemas/old/%/bundle.metapack"
not_exists "$TMP/output/schemas/example/schemas/old/%/editor.metapack"
not_exists "$TMP/output/schemas/example/schemas/old/%/blaze-exhaustive.metapack"
not_exists "$TMP/output/schemas/example/schemas/old/%/schema.metapack"
