#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "https://sourcemeta.com/",
  "port": 8000,
  "schemas": {
    "example/schemas": {
      "base": "https://example.com/",
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

echo "foobar" > "$TMP/output"
export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/registry.json" "$TMP/output" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"
error: file already exists
  at $(realpath "$TMP")/output
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
