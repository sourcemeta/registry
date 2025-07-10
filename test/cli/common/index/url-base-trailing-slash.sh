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
  "$id": "https://example.com/test.json"
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/registry.json" "$TMP/output"

# shellcheck disable=SC2016
printf '%s' '{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://sourcemeta.com/example/schemas/test.json"
}' > "$TMP/expected.json"

diff "$TMP/output/schemas/example/schemas/test.json.schema" "$TMP/expected.json"
