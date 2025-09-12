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
    "self": {
      "title": "Not permitted"
    }
  }
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/registry.json" "$TMP/output" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/registry.json
error: Invalid configuration
No instance is expected to succeed against the false schema
  at instance location "/contents/self"
  at evaluate path "/properties/contents/properties/self"
The object value was expected to validate against the single defined property subschema
  at instance location "/contents"
  at evaluate path "/properties/contents/properties"
The object value was expected to validate against the 4 defined properties subschemas
  at instance location ""
  at evaluate path "/properties"
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
