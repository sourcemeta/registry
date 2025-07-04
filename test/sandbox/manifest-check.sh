#!/bin/sh

set -o errexit
set -o nounset

if [ $# -lt 2 ]
then
  echo "Usage: $0 <directory> <manifest.txt>" 1>&2
  exit 1
fi

TMP="$(mktemp -d)"
clean() { rm -rf "$TMP"; }
trap clean EXIT

DIRECTORY="$1"
MANIFEST="$2"

cd "$DIRECTORY"
find . -mindepth 1 | sort > "$TMP/manifest.txt"
cat "$TMP/manifest.txt"
cd - > /dev/null
diff "$TMP/manifest.txt" "$MANIFEST"
