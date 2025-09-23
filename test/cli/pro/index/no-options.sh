#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" > "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

VERSION="$2"

cat << EOF > "$TMP/expected.txt"
Sourcemeta Registry v$VERSION Pro Edition
Usage: sourcemeta-registry-index <registry.json> <path/to/output/directory>
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
