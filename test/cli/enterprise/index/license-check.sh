#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/configuration.json"
{
  "url": "http://localhost:8000",
  "port": 8000,
  "schemas": {
    "example": {
      "base": "https://example.com",
      "path": "./schemas"
    }
  }
}
EOF

mkdir "$TMP/schemas"
cat << 'EOF' > "$TMP/schemas/schema.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/schema"
}
EOF

"$1" "$TMP/configuration.json" "$TMP/dist" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"

╔════════════════════════════════════════════════════════════════════╗
║                     CONFIRM COMMERCIAL LICENSE                     ║
╠════════════════════════════════════════════════════════════════════╣
║ You are running a commercial version of the Sourcemeta Registry.   ║
║ This software requires a valid commercial license to operate.      ║
║                                                                    ║
║ To confirm your license, set the following environment variable:   ║
║   SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE                  ║
║                                                                    ║
║ By setting this variable, you agree to the terms of the license    ║
║ at: https://github.com/sourcemeta/registry                         ║
║                                                                    ║
║ Running this software without a commercial license is strictly     ║
║ prohibited and may result in legal action.                         ║
╚════════════════════════════════════════════════════════════════════╝
EOF

diff "$TMP/output.txt" "$TMP/expected.txt"
