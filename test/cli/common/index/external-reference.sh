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
  "allOf": [ { "$ref": "https://sourcemeta.com/external" } ]
}
EOF

"$1" "$TMP/configuration.json" "$TMP/output" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"
Using configuration: $(realpath "$TMP")/configuration.json
Writing output to: $(realpath "$TMP")/output
Discovering schemas at: $(realpath "$TMP")/schemas
-- Found schema: $(realpath "$TMP")/schemas/test.json (#1)
https://example.com/test.json => https://sourcemeta.com/example/schemas/test.json
-- Processing schema: https://sourcemeta.com/example/schemas/test.json
Schema output: $(realpath "$TMP")/output/schemas/example/schemas/test.json
Validating against its metaschema: https://sourcemeta.com/example/schemas/test.json
Bundling: https://sourcemeta.com/example/schemas/test.json
error: Could not resolve the requested schema
  at https://sourcemeta.com/external
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
