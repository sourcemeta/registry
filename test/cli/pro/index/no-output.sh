#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/configuration.json"
{
  "url": "http://localhost:8000",
  "port": 8000,
  "schemas": {
    "example/schemas": {
      "base": "https://example.com/schemas",
      "path": "./schemas/example/folder"
    }
  }
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/configuration.json" > "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

VERSION="$(grep '^project' < CMakeLists.txt | head -n 1 | cut -d ' ' -f 3)"

cat << EOF > "$TMP/expected.txt"
Sourcemeta Registry v$VERSION Pro Edition
Usage: sourcemeta-registry-index <configuration.json> <path/to/output/directory>
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
