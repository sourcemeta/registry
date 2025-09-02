#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "http://localhost:8000",
  "contents": {
    "example": {
      "baseUri": "https://example.com",
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

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1
"$1" "$TMP/registry.json" "$TMP/dist"

cat << 'EOF' > "$TMP/schemas/exceeding.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/exceeding.json"
}
EOF

"$1" "$TMP/registry.json" "$TMP/dist" 2> "$TMP/output.txt" && CODE="$?" || CODE="$?"
test "$CODE" = "1" || exit 1

cat << EOF > "$TMP/expected.txt"
error: The Pro edition is restricted to 1000 schemas
Upgrade to the Enterprise edition to waive limits
Buy a new license at https://www.sourcemeta.com
EOF

tail -n 3 < "$TMP/output.txt" > "$TMP/tail.txt"
diff "$TMP/tail.txt" "$TMP/expected.txt"
