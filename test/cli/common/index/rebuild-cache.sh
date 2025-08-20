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
  "contents": {
    "example/schemas": {
      "base": "https://example.com",
      "path": "./schemas"
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
(100%) Ingesting: https://sourcemeta.com/example/schemas/foo.json
(100%) Analysing: https://sourcemeta.com/example/schemas/foo.json
Generating registry explorer
EOF
diff "$TMP/output.txt" "$TMP/expected.txt"

# Run it once more

"$1" "$TMP/registry.json" "$TMP/output" 2> "$TMP/output.txt"
remove_threads_information "$TMP/output.txt"
cat << EOF > "$TMP/expected.txt"
Writing output to: $(realpath "$TMP")/output
Using configuration: $(realpath "$TMP")/registry.json
Detecting: $(realpath "$TMP")/schemas/foo.json (#1)
(100%) Ingesting: https://sourcemeta.com/example/schemas/foo.json
(skip) Ingesting: https://sourcemeta.com/example/schemas/foo.json
(100%) Analysing: https://sourcemeta.com/example/schemas/foo.json
(skip) Analysing: https://sourcemeta.com/example/schemas/foo.json [positions]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo.json [locations]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo.json [dependencies]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo.json [health]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo.json [bundle]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo.json [unidentified]
(skip) Analysing: https://sourcemeta.com/example/schemas/foo.json [blaze-exhaustive]
Generating registry explorer
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
(100%) Ingesting: https://sourcemeta.com/example/schemas/foo.json
(100%) Analysing: https://sourcemeta.com/example/schemas/foo.json
Generating registry explorer
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
(100%) Ingesting: https://sourcemeta.com/example/schemas/foo.json
(100%) Analysing: https://sourcemeta.com/example/schemas/foo.json
Generating registry explorer
EOF
diff "$TMP/output.txt" "$TMP/expected.txt"
