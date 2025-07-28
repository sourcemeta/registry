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

cat << 'EOF' > "$TMP/schemas/test.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/old.json"
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

"$1" "$TMP/registry.json" "$TMP/output"

exists() {
  [ -f "$1" ] || (echo "File MUST exist: $1" 1>&2 && exit 1)
}

not_exists() {
  [ ! -f "$1" ] || (echo "File MUST NOT exists: $1" 1>&2 && exit 1)
}

exists "$TMP/output/explorer/pages/example/schemas/old.nav"
exists "$TMP/output/schemas/example/schemas/old.json.bundle"
exists "$TMP/output/schemas/example/schemas/old.json.unidentified"
exists "$TMP/output/schemas/example/schemas/old.json.blaze-exhaustive"
exists "$TMP/output/schemas/example/schemas/old.json.schema"

cat << 'EOF' > "$TMP/schemas/test.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/new.json"
}
EOF

"$1" "$TMP/registry.json" "$TMP/output"

exists "$TMP/output/explorer/pages/example/schemas/new.nav"
exists "$TMP/output/schemas/example/schemas/new.json.bundle"
exists "$TMP/output/schemas/example/schemas/new.json.unidentified"
exists "$TMP/output/schemas/example/schemas/new.json.blaze-exhaustive"
exists "$TMP/output/schemas/example/schemas/new.json.schema"

not_exists "$TMP/output/explorer/pages/example/schemas/old.nav"
not_exists "$TMP/output/schemas/example/schemas/old.json.bundle"
not_exists "$TMP/output/schemas/example/schemas/old.json.unidentified"
not_exists "$TMP/output/schemas/example/schemas/old.json.blaze-exhaustive"
not_exists "$TMP/output/schemas/example/schemas/old.json.schema"
