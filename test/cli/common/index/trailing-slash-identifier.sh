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
      "base": "https://example.com",
      "path": "./schemas"
    }
  }
}
EOF

mkdir "$TMP/schemas"

cat << 'EOF' > "$TMP/schemas/test.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/"
}
EOF

"$1" "$TMP/configuration.json" "$TMP/output" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"
Using configuration: $(realpath "$TMP")/configuration.json
Writing output to: $(realpath "$TMP")/output
Discovering schemas at: $(realpath "$TMP")/schemas
-- Found schema: $(realpath "$TMP")/schemas/test.json
https://example.com/
error: Cannot resolve the schema identifier (https://example.com/) against the collection base (https://example.com)
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
