#!/bin/sh

set -o errexit
set -o nounset

for configuration in empty headless html
do
  make configure compile
  rm -rf build/sandbox
  # As we expect this command to potentially fail
  make sandbox-index SANDBOX_CONFIGURATION=$configuration || true
done
