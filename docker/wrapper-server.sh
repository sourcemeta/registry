#!/bin/sh

set -o errexit
set -o nounset

# For better shell expansion in the Dockerfile

exec /usr/bin/sourcemeta-registry-server \
  "$SOURCEMETA_REGISTRY_OUTPUT" \
  "$SOURCEMETA_REGISTRY_PORT"
