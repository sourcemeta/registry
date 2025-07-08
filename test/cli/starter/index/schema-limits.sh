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
  "schemas": {
    "example": {
      "base": "https://example.com",
      "path": "./schemas"
    }
  }
}
EOF

mkdir "$TMP/schemas"
for count in $(seq -w 1 100)
do
  cat << EOF > "$TMP/schemas/$count.json"
  {
    "\$schema": "http://json-schema.org/draft-07/schema#",
    "\$id": "https://example.com/$count.json"
  }
EOF
done

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
error: The Starter edition is restricted to 100 schemas
Buy a Pro or Enterprise license at https://www.sourcemeta.com
EOF

tail -n 2 < "$TMP/output.txt" > "$TMP/tail.txt"
diff "$TMP/tail.txt" "$TMP/expected.txt"
