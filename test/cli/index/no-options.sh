#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

"$1" > "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

VERSION="$2"

cat << EOF > "$TMP/expected.txt"
Sourcemeta Registry v$VERSION
Usage: sourcemeta-registry-index <registry.json> <path/to/output/directory>
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
