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

"$1" "$TMP/registry.json" "$TMP/output" 2> "$TMP/output.txt"
remove_threads_information "$TMP/output.txt"
cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/registry.json
Detecting: $(realpath "$TMP")/schemas/foo.json (#1)
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

# Run it once more

"$1" "$TMP/registry.json" "$TMP/output" 2> "$TMP/output.txt"
remove_threads_information "$TMP/output.txt"
cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/registry.json
Detecting: $(realpath "$TMP")/schemas/foo.json (#1)
(100%) Ingesting: https://sourcemeta.com/example/schemas/foo
(skip) Ingesting: https://sourcemeta.com/example/schemas/foo [materialise]
(100%) Analysing: https://sourcemeta.com/example/schemas/foo
(skip) Analysing: https://sourcemeta.com/example/schemas/foo [positions]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo [locations]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo [dependencies]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo [health]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo [bundle]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo [editor]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo [blaze-exhaustive]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo [metadata]
(100%) Reviewing: $(realpath "$TMP")/output/schemas
(  0%) Producing: $(realpath "$TMP")/output/explorer
(skip) Producing: $(realpath "$TMP")/output/explorer [search]
( 33%) Producing: example/schemas
(skip) Producing: example/schemas [directory]
( 66%) Producing: example
(skip) Producing: example [directory]
(100%) Producing: .
(skip) Producing: . [directory]
Generating registry web interface
EOF
diff "$TMP/output.txt" "$TMP/expected.txt"

# Update the file
cat << 'EOF' > "$TMP/schemas/foo.json"
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://example.com/foo",
  "type": "string"
}
EOF
"$1" "$TMP/registry.json" "$TMP/output" 2> "$TMP/output.txt"
remove_threads_information "$TMP/output.txt"
cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/registry.json
Detecting: $(realpath "$TMP")/schemas/foo.json (#1)
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

# Update the configuration summary
touch "$TMP/output/configuration.json"
"$1" "$TMP/registry.json" "$TMP/output" 2> "$TMP/output.txt"
remove_threads_information "$TMP/output.txt"
cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/registry.json
Detecting: $(realpath "$TMP")/schemas/foo.json (#1)
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
