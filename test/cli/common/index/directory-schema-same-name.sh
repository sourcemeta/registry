#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "https://sourcemeta.com/",
  "html": {},
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

cat << 'EOF' > "$TMP/schemas/foo.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/foo.json"
}
EOF

cat << 'EOF' > "$TMP/schemas/bar.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/foo/bar.json"
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

"$1" "$TMP/registry.json" "$TMP/output"

exists() {
  [ -f "$1" ] || (echo "File MUST exist: $1" 1>&2 && exit 1)
}

exists "$TMP/output/explorer/example/schemas/foo/%/schema.metapack"
exists "$TMP/output/explorer/example/schemas/foo/%/schema-html.metapack"
exists "$TMP/output/explorer/example/schemas/foo/%/directory.metapack"
exists "$TMP/output/explorer/example/schemas/foo/%/directory-html.metapack"
exists "$TMP/output/explorer/example/schemas/foo/bar/%/schema.metapack"
exists "$TMP/output/explorer/example/schemas/foo/bar/%/schema-html.metapack"

exists "$TMP/output/schemas/example/schemas/foo.json/%/schema.metapack"
exists "$TMP/output/schemas/example/schemas/foo/bar.json/%/schema.metapack"
