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

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/configuration.json" "$TMP/output" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/configuration.json
Detecting: $(realpath "$TMP")/schemas/test.json (#1)
Ingesting: https://sourcemeta.com/example/schemas/test.json
error: The schema does not adhere to its metaschema
The integer value was expected to validate against at least one of the 2 given subschemas
  at instance location "/type"
  at evaluate path "/properties/type/anyOf"
The object value was expected to validate against the 46 defined properties subschemas
  at instance location ""
  at evaluate path "/properties"
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
