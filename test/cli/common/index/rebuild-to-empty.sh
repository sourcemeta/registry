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
    "example": {
      "contents": {
        "schemas": {
          "baseUri": "https://example.com/",
          "path": "./schemas"
        }
      }
    }
  }
}
EOF

mkdir "$TMP/schemas"

cat << 'EOF' > "$TMP/schemas/foo.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/foo"
}
EOF

export SOURCEMETA_REGISTRY_I_HAVE_A_COMMERCIAL_LICENSE=1

"$1" "$TMP/registry.json" "$TMP/output"

cd "$TMP/output"
find . -mindepth 1 | LC_ALL=C sort > "$TMP/current.txt"
cd - > /dev/null

cat << 'EOF' > "$TMP/current-expected.txt"
./configuration.json
./explorer
./explorer/%
./explorer/%/404.metapack
./explorer/%/404.metapack.deps
./explorer/%/directory-html.metapack
./explorer/%/directory-html.metapack.deps
./explorer/%/directory.metapack
./explorer/%/directory.metapack.deps
./explorer/%/search.metapack
./explorer/%/search.metapack.deps
./explorer/example
./explorer/example/%
./explorer/example/%/directory-html.metapack
./explorer/example/%/directory-html.metapack.deps
./explorer/example/%/directory.metapack
./explorer/example/%/directory.metapack.deps
./explorer/example/schemas
./explorer/example/schemas/%
./explorer/example/schemas/%/directory-html.metapack
./explorer/example/schemas/%/directory-html.metapack.deps
./explorer/example/schemas/%/directory.metapack
./explorer/example/schemas/%/directory.metapack.deps
./explorer/example/schemas/foo
./explorer/example/schemas/foo/%
./explorer/example/schemas/foo/%/schema-html.metapack
./explorer/example/schemas/foo/%/schema-html.metapack.deps
./explorer/example/schemas/foo/%/schema.metapack
./explorer/example/schemas/foo/%/schema.metapack.deps
./schemas
./schemas/example
./schemas/example/schemas
./schemas/example/schemas/foo
./schemas/example/schemas/foo/%
./schemas/example/schemas/foo/%/blaze-exhaustive.metapack
./schemas/example/schemas/foo/%/blaze-exhaustive.metapack.deps
./schemas/example/schemas/foo/%/bundle.metapack
./schemas/example/schemas/foo/%/bundle.metapack.deps
./schemas/example/schemas/foo/%/dependencies.metapack
./schemas/example/schemas/foo/%/dependencies.metapack.deps
./schemas/example/schemas/foo/%/editor.metapack
./schemas/example/schemas/foo/%/editor.metapack.deps
./schemas/example/schemas/foo/%/health.metapack
./schemas/example/schemas/foo/%/health.metapack.deps
./schemas/example/schemas/foo/%/locations.metapack
./schemas/example/schemas/foo/%/locations.metapack.deps
./schemas/example/schemas/foo/%/positions.metapack
./schemas/example/schemas/foo/%/positions.metapack.deps
./schemas/example/schemas/foo/%/schema.metapack
./schemas/example/schemas/foo/%/schema.metapack.deps
./version.json
EOF

diff "$TMP/current.txt" "$TMP/current-expected.txt"

cat << EOF > "$TMP/registry.json"
{
  "url": "https://sourcemeta.com/"
}
EOF

"$1" "$TMP/registry.json" "$TMP/output"

cd "$TMP/output"
find . -mindepth 1 | LC_ALL=C sort > "$TMP/new.txt"
cd - > /dev/null

cat << 'EOF' > "$TMP/new-expected.txt"
./configuration.json
./explorer
./explorer/%
./explorer/%/404.metapack
./explorer/%/404.metapack.deps
./explorer/%/directory-html.metapack
./explorer/%/directory-html.metapack.deps
./explorer/%/directory.metapack
./explorer/%/directory.metapack.deps
./explorer/%/search.metapack
./explorer/%/search.metapack.deps
./version.json
EOF

diff "$TMP/new.txt" "$TMP/new-expected.txt"
