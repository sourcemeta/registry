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

cat << 'EOF' > "$TMP/schemas/test.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/test.json",
  "type": 1
}
EOF

"$1" "$TMP/registry.json" "$TMP/output" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

# Remove thread information
if [ "$(uname)" = "Darwin" ]
then
  sed -i '' 's/ \[.*\]//g' "$TMP/output.txt"
else
  sed -i 's/ \[.*\]//g' "$TMP/output.txt"
fi

cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/registry.json
Detecting: $(realpath "$TMP")/schemas/test.json (#1)
(100%) Ingesting: https://sourcemeta.com/example/schemas/test
error: The schema does not adhere to its metaschema
The integer value was expected to validate against at least one of the 2 given subschemas
  at instance location "/type"
  at evaluate path "/properties/type/anyOf"
The object value was expected to validate against the 46 defined properties subschemas
  at instance location ""
  at evaluate path "/properties"
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
