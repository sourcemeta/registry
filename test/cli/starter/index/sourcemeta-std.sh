#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "http://localhost:8000",
  "extends": [
    "@sourcemeta/std/v0.0.1"
  ]
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/registry.json" "$TMP/dist" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/dist
Using configuration: $(realpath "$TMP")/registry.json
error: Could not locate built-in collection
  from $(realpath "$TMP")/registry.json
  at "/extends"
  to @sourcemeta/std/v0.0.1
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
