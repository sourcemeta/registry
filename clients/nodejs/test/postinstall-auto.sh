#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

BASE_URL="$1"
TARBALL="$(npm pack --silent --pack-destination "$TMP")"

mkdir "$TMP/source"

cat << EOF > "$TMP/source/package.json"
{
  "name": "test",
  "type": "module",
  "private": true,
  "version": "1.0.0",
  "main": "index.js",
  "schemas": {
    "bundling": "$BASE_URL/test/bundling/single.json"
  }
}
EOF

cd "$TMP/source"
npm install --save "file:$TMP/$TARBALL"
cd - > /dev/null

cat "$TMP/source/package.json" | jq '.dependencies["@sourcemeta/registry"] = "XXX"' \
  > "$TMP/current.json"

cat << EOF > "$TMP/expected.json"
{
  "name": "test",
  "type": "module",
  "private": true,
  "version": "1.0.0",
  "main": "index.js",
  "schemas": {
    "bundling": "$BASE_URL/test/bundling/single.json"
  },
  "scripts": {
    "postinstall": "sourcemeta-registry-sync"
  },
  "dependencies": {
    "@sourcemeta/registry": "XXX"
  }
}
EOF

diff "$TMP/current.json" "$TMP/expected.json"

cd "$TMP/source"
find . -mindepth 1 | LC_ALL=C sort > "$TMP/manifest.txt"
cd - > /dev/null

cat << 'EOF' > "$TMP/expected.txt"
./node_modules
./node_modules/.bin
./node_modules/.bin/sourcemeta-registry-sync
./node_modules/.cache
./node_modules/.cache/@sourcemeta
./node_modules/.cache/@sourcemeta/registry
./node_modules/.cache/@sourcemeta/registry/test
./node_modules/.cache/@sourcemeta/registry/test/1.0.0
./node_modules/.cache/@sourcemeta/registry/test/1.0.0/bundling.json
./node_modules/.cache/@sourcemeta/registry/test/1.0.0/index.cjs
./node_modules/.package-lock.json
./node_modules/@sourcemeta
./node_modules/@sourcemeta/registry
./node_modules/@sourcemeta/registry/index.cjs
./node_modules/@sourcemeta/registry/index.mjs
./node_modules/@sourcemeta/registry/install.cjs
./node_modules/@sourcemeta/registry/package.json
./node_modules/@sourcemeta/registry/postinstall.cjs
./package-lock.json
./package.json
EOF

diff "$TMP/expected.txt" "$TMP/manifest.txt"
