#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
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

exists "$TMP/output/explorer/pages/example/schemas/foo.meta"
exists "$TMP/output/explorer/pages/example/schemas/foo.nav"
exists "$TMP/output/explorer/pages/example/schemas/foo/bar.meta"
