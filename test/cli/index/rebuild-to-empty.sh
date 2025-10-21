#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "https://sourcemeta.com/",
  "contents": {
    "example": {
      "contents": {
        "schemas": {
          "baseUri": "https://example.com/",
          "path": "./schemas"
        }
      }
    }
  }
}
EOF

mkdir "$TMP/schemas"

cat << 'EOF' > "$TMP/schemas/foo.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/foo"
}
EOF

"$1" "$TMP/registry.json" "$TMP/output"

cat << EOF > "$TMP/registry.json"
{
  "url": "https://sourcemeta.com/"
}
EOF

"$1" "$TMP/registry.json" "$TMP/output"

cd "$TMP/output"
find . -mindepth 1 | LC_ALL=C sort > "$TMP/new.txt"
cd - > /dev/null

cat << 'EOF' > "$TMP/new-expected.txt"
./configuration.json
./explorer
./explorer/%
./explorer/%/404.metapack
./explorer/%/404.metapack.deps
./explorer/%/directory-html.metapack
./explorer/%/directory-html.metapack.deps
./explorer/%/directory.metapack
./explorer/%/directory.metapack.deps
./explorer/%/search.metapack
./explorer/%/search.metapack.deps
./version.json
EOF

diff "$TMP/new.txt" "$TMP/new-expected.txt"
