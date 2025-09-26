#!/bin/sh

set -o errexit
set -o nounset

# This is a wrapper around `sourcemeta-registry-index` specifically for the
# Dockerfile, as it reads the environment variables present in the context to
# simplify the interface for generating a Registry instance

if [ $# -lt 1 ]
then
  echo "Usage: $0 <path/to/registry.json>" 1>&2
  exit 1
fi

CONFIGURATION="$1"
shift

case "$(realpath "$CONFIGURATION")" in
  "$SOURCEMETA_REGISTRY_WORKDIR"*)
    /usr/bin/sourcemeta-registry-index "$CONFIGURATION" "$SOURCEMETA_REGISTRY_OUTPUT" "$@"
    # Automatically cleanup the source directories
    echo "Deleting $SOURCEMETA_REGISTRY_WORKDIR to keep the image small" 1>&2
    rm -rf "$SOURCEMETA_REGISTRY_WORKDIR"
    ;;
  *)
    echo "error: $1 must be inside the workding directory ($SOURCEMETA_REGISTRY_WORKDIR)" 1>&2
    exit 1
    ;;
esac
