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

cat << 'EOF' > "$TMP/schemas/test.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/foo.json"
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

"$1" "$TMP/registry.json" "$TMP/output"

cd "$TMP/output"
find . -mindepth 1 | LC_ALL=C sort > "$TMP/old.txt"
cd - > /dev/null

exists() {
  [ -f "$1" ] || (echo "File MUST exist: $1" 1>&2 && exit 1)
}

exists "$TMP/output/explorer/example/schemas/foo/%/schema.metapack"
mkdir "$TMP/output/explorer/example/schemas/bar"
echo "{}" > "$TMP/output/explorer/example/schemas/bar/test.json"
mkdir "$TMP/output/explorer/example/bar"
mkdir "$TMP/output/explorer/bar"

exists "$TMP/output/schemas/example/schemas/foo.json/%/schema.metapack"
mkdir "$TMP/output/schemas/example/schemas/bar.json"
echo "{}" > "$TMP/output/schemas/example/schemas/bar.json/test.json"
mkdir "$TMP/output/schemas/example/bar.json"
mkdir "$TMP/output/schemas/bar.json"

"$1" "$TMP/registry.json" "$TMP/output"

cd "$TMP/output"
find . -mindepth 1 | LC_ALL=C sort > "$TMP/new.txt"
cd - > /dev/null

echo "======================= OLD"
cat "$TMP/old.txt"
echo "======================= NEW"
cat "$TMP/new.txt"

diff "$TMP/new.txt" "$TMP/old.txt"
