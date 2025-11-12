#!/bin/sh

set -o errexit
set -o nounset

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

BASE_URL="$1"

# Pack the current package into a tarball in temp directory
TARBALL="$(npm pack --silent --pack-destination "$TMP")"

# Create nested package that imports one schema
mkdir -p "$TMP/nested"

cat << EOF > "$TMP/nested/package.json"
{
  "name": "nested-package",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "index.js",
  "schemas": {
    "bundling": "$BASE_URL/test/bundling/single.json"
  },
  "scripts": {
    "postinstall": "sourcemeta-registry-sync"
  },
  "dependencies": {
    "@sourcemeta/registry": "file:$TMP/$TARBALL"
  }
}
EOF

cat << 'EOF' > "$TMP/nested/index.js"
import { schemas } from "@sourcemeta/registry";
export const nestedSchema = schemas.bundling;
EOF

# Install nested package dependencies
cd "$TMP/nested"
npm install
cd - > /dev/null

# Pack the nested package
NESTED_TARBALL="$(cd "$TMP/nested" && npm pack --silent --pack-destination "$TMP")"

# Create top-level package that imports a different schema
# AND depends on the nested package
mkdir -p "$TMP/toplevel"

cat << EOF > "$TMP/toplevel/package.json"
{
  "name": "toplevel-package",
  "version": "2.0.0",
  "private": true,
  "type": "module",
  "main": "index.js",
  "schemas": {
    "v2schema": "$BASE_URL/test/v2.0/schema"
  },
  "scripts": {
    "postinstall": "sourcemeta-registry-sync"
  },
  "dependencies": {
    "@sourcemeta/registry": "file:$TMP/$TARBALL",
    "nested-package": "file:$TMP/$NESTED_TARBALL"
  }
}
EOF

cat << 'EOF' > "$TMP/toplevel/index.js"
import { schemas } from "@sourcemeta/registry";
import { nestedSchema } from "nested-package";

console.log(JSON.stringify({
  toplevel: schemas.v2schema,
  nested: nestedSchema
}, null, 2));
EOF

# Install top-level package dependencies
cd "$TMP/toplevel"
npm install
find . -mindepth 1 | LC_ALL=C sort > "$TMP/manifest.txt"
cd - > /dev/null

# Expected file structure
cat << 'EOF' > "$TMP/expected.txt"
./index.js
./node_modules
./node_modules/.bin
./node_modules/.bin/sourcemeta-registry-sync
./node_modules/.cache
./node_modules/.cache/@sourcemeta
./node_modules/.cache/@sourcemeta/registry
./node_modules/.cache/@sourcemeta/registry/nested-package
./node_modules/.cache/@sourcemeta/registry/nested-package/1.0.0
./node_modules/.cache/@sourcemeta/registry/nested-package/1.0.0/bundling.json
./node_modules/.cache/@sourcemeta/registry/nested-package/1.0.0/index.cjs
./node_modules/.cache/@sourcemeta/registry/toplevel-package
./node_modules/.cache/@sourcemeta/registry/toplevel-package/2.0.0
./node_modules/.cache/@sourcemeta/registry/toplevel-package/2.0.0/index.cjs
./node_modules/.cache/@sourcemeta/registry/toplevel-package/2.0.0/v2schema.json
./node_modules/.package-lock.json
./node_modules/@sourcemeta
./node_modules/@sourcemeta/registry
./node_modules/@sourcemeta/registry/index.cjs
./node_modules/@sourcemeta/registry/index.mjs
./node_modules/@sourcemeta/registry/install.cjs
./node_modules/@sourcemeta/registry/package.json
./node_modules/@sourcemeta/registry/postinstall.cjs
./node_modules/nested-package
./node_modules/nested-package/index.js
./node_modules/nested-package/package.json
./package-lock.json
./package.json
EOF

diff "$TMP/expected.txt" "$TMP/manifest.txt"

# Run the top-level package and verify both schemas are loaded correctly
node "$TMP/toplevel/index.js" > "$TMP/output.json"

cat << EOF > "$TMP/expected-output.json"
{
  "toplevel": {
    "\$schema": "http://json-schema.org/draft-07/schema#",
    "\$id": "$BASE_URL/test/v2.0/schema",
    "type": "integer"
  },
  "nested": {
    "\$schema": "http://json-schema.org/draft-07/schema#",
    "\$id": "$BASE_URL/test/bundling/single",
    "title": "Bundling",
    "description": "A bundling example",
    "properties": {
      "foo": {
        "\$ref": "$BASE_URL/test/v2.0/schema"
      }
    },
    "definitions": {
      "$BASE_URL/test/v2.0/schema": {
        "\$schema": "http://json-schema.org/draft-07/schema#",
        "\$id": "$BASE_URL/test/v2.0/schema",
        "type": "integer"
      }
    }
  }
}
EOF

diff "$TMP/output.json" "$TMP/expected-output.json"
