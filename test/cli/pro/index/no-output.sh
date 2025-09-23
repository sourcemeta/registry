#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "http://localhost:8000",
  "contents": {
    "example": {
      "contents": {
        "schemas": {
          "baseUri": "https://example.com/schemas",
          "path": "./schemas/example/folder"
        }
      }
    }
  }
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/registry.json" > "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

VERSION="$2"

cat << EOF > "$TMP/expected.txt"
Sourcemeta Registry v$VERSION Pro Edition
Usage: sourcemeta-registry-index <registry.json> <path/to/output/directory>
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
