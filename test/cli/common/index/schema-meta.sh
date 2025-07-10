#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

cat << EOF > "$TMP/registry.json"
{
  "url": "https://sourcemeta.com",
  "port": 8000,
  "schemas": {
    "example/schemas": {
      "base": "https://example.com",
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

CHECKSUM_SCHEMA="$(md5sum "$TMP/output/schemas/example/schemas/test.json.schema" | cut -d ' ' -f 1)"
TIMESTAMP_SCHEMA="$(date -u -r "$TMP/output/schemas/example/schemas/test.json.schema" "+%a, %d %b %Y %H:%M:%S GMT")"
printf '{"dialect":"http://json-schema.org/draft-07/schema#","mime":"application/schema+json","md5":"%s","lastModified":"%s"}' \
  "$CHECKSUM_SCHEMA" "$TIMESTAMP_SCHEMA" > "$TMP/schema.json"

CHECKSUM_BUNDLE="$(md5sum "$TMP/output/schemas/example/schemas/test.json.bundle" | cut -d ' ' -f 1)"
TIMESTAMP_BUNDLE="$(date -u -r "$TMP/output/schemas/example/schemas/test.json.bundle" "+%a, %d %b %Y %H:%M:%S GMT")"
printf '{"dialect":"http://json-schema.org/draft-07/schema#","mime":"application/schema+json","md5":"%s","lastModified":"%s"}' \
  "$CHECKSUM_BUNDLE" "$TIMESTAMP_BUNDLE" > "$TMP/bundle.json"

CHECKSUM_UNIDENTIFIED="$(md5sum "$TMP/output/schemas/example/schemas/test.json.unidentified" | cut -d ' ' -f 1)"
TIMESTAMP_UNIDENTIFIED="$(date -u -r "$TMP/output/schemas/example/schemas/test.json.unidentified" "+%a, %d %b %Y %H:%M:%S GMT")"
printf '{"dialect":"http://json-schema.org/draft-07/schema#","mime":"application/schema+json","md5":"%s","lastModified":"%s"}' \
  "$CHECKSUM_UNIDENTIFIED" "$TIMESTAMP_UNIDENTIFIED" > "$TMP/unidentified.json"

diff "$TMP/output/schemas/example/schemas/test.json.schema.meta" "$TMP/schema.json"
diff "$TMP/output/schemas/example/schemas/test.json.bundle.meta" "$TMP/bundle.json"
diff "$TMP/output/schemas/example/schemas/test.json.unidentified.meta" "$TMP/unidentified.json"
