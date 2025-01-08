#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/configuration.json"
{
  "port": 8000,
  "schemas": {
    "example/schemas": {}
  }
}
EOF

"$1" "$TMP/configuration.json" "$TMP/output" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"
-- Using configuration: $(realpath "$TMP")/configuration.json
-- Writing output to: $(realpath "$TMP")/output
error: Invalid configuration
The object value was expected to define properties "port", "schemas", and "url" but did not define the property "url"
  at instance location ""
  at evaluate path "/required"
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
