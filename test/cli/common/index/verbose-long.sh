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

remove_threads_information() {
  expr='s/ \[[^]]*[^a-z-][^]]*\]//g'
  if [ "$(uname -s)" = "Darwin" ]; then
    sed -i '' "$expr" "$1"
  else
    sed -i "$expr" "$1"
  fi
}

"$1" "$TMP/registry.json" "$TMP/output" --verbose 2> "$TMP/output.txt"
remove_threads_information "$TMP/output.txt"
cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/registry.json
Detecting: $(realpath "$TMP")/schemas/foo.json (#1)
https://example.com/foo => https://sourcemeta.com/example/schemas/foo
(100%) Ingesting: https://sourcemeta.com/example/schemas/foo
(100%) Analysing: https://sourcemeta.com/example/schemas/foo
(100%) Reviewing: $(realpath "$TMP")/output/schemas
(  0%) Producing: $(realpath "$TMP")/output/explorer
( 33%) Producing: example/schemas
( 66%) Producing: example
(100%) Producing: .
Generating registry web interface
EOF
diff "$TMP/output.txt" "$TMP/expected.txt"
