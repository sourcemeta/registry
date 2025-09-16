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
INPUT="$2"

cp "$INPUT" "$TMP/current.txt"
cd "$DIRECTORY"
find . -mindepth 1 | LC_ALL=C sort > "$TMP/manifest.txt"
cd - > /dev/null
cp "$TMP/manifest.txt" "$INPUT"
diff "$TMP/manifest.txt" "$TMP/current.txt"
