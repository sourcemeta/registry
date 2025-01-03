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
[
  {
    "url": "/example/schemas/no-title.json",
    "title": "",
    "description": ""
  },
  {
    "url": "/example/schemas/test.json",
    "title": "My title",
    "description": "My description"
  }
]
EOF

diff "$TMP/output/search.json" "$TMP/expected.json"
