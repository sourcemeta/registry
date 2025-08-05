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
  "extends": [ "@foo/bar" ]
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/registry.json" "$TMP/output" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

# TODO: Throw a nicer error that points out the invalid extends
cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/registry.json
error: could not locate the requested file
  at $(dirname "$(dirname "$1")")/share/sourcemeta/registry/collections/foo/bar/registry.json
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
