#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "http://localhost:8000",
  "port": 8000,
  "contents": {
    "example": {
      "base": "https://example.com",
      "path": "./schemas"
    }
  }
}
EOF

mkdir "$TMP/schemas"
for count in $(seq -w 1 1000)
do
  cat << EOF > "$TMP/schemas/$count.json"
  {
    "\$schema": "http://json-schema.org/draft-07/schema#",
    "\$id": "https://example.com/$count.json"
  }
EOF
done

cat << 'EOF' > "$TMP/schemas/exceeding.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/exceeding.json"
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/registry.json" "$TMP/dist"
