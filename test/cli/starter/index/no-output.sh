#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "http://localhost:8000",
  "port": 8000,
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

"$1" "$TMP/registry.json" > "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

VERSION="$(grep '^project' < CMakeLists.txt | head -n 1 | cut -d ' ' -f 3)"

cat << EOF > "$TMP/expected.txt"
Sourcemeta Registry v$VERSION Starter Edition
Usage: sourcemeta-registry-index <registry.json> <path/to/output/directory>
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
