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
  "type": 1
}
EOF

"$1" "$TMP/configuration.json" "$TMP/output" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"
Using configuration: $(realpath "$TMP")/configuration.json
Writing output to: $(realpath "$TMP")/output
Discovering schemas at: $(realpath "$TMP")/schemas
-- Found schema: $(realpath "$TMP")/schemas/test.json
https://example.com/test.json => https://sourcemeta.com/example/schemas/test.json
-- Processing schema: https://sourcemeta.com/example/schemas/test.json
Schema output: $(realpath "$TMP")/output/schemas/example/schemas/test.json
Compiling metaschema: http://json-schema.org/draft-07/schema#
Validating against its metaschema: https://sourcemeta.com/example/schemas/test.json
error: The schema does not adhere to its metaschema
The integer value 1 was expected to equal one of the given declared values
  at instance location "/type"
  at evaluate path "/properties/type/anyOf/0/\$ref/enum"
The value was expected to consist of an array of at least 1 item
  at instance location "/type"
  at evaluate path "/properties/type/anyOf/1/type"
The integer value was expected to validate against at least one of the 2 given subschemas
  at instance location "/type"
  at evaluate path "/properties/type/anyOf"
The object value was expected to validate against the 46 defined properties subschemas
  at instance location ""
  at evaluate path "/properties"
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
