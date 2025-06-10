#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/configuration.json"
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
  "$id": "https://example.com/test.json",
  "title": "My title",
  "description": "My description"
}
EOF

cat << 'EOF' > "$TMP/schemas/no-title.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/no-title.json"
}
EOF

"$1" "$TMP/configuration.json" "$TMP/output"

cat << 'EOF' > "$TMP/expected.json"
["/example/schemas/test.json","My title","My description"]
["/example/schemas/no-title.json","",""]
EOF

cat "$TMP/output/search.jsonl"

diff "$TMP/output/search.jsonl" "$TMP/expected.json"
