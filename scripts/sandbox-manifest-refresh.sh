#!/bin/sh

set -o errexit
set -o nounset

for edition in starter pro enterprise
do
  for configuration in empty headless html
  do
    make configure compile EDITION=$edition 
    rm -rf build/sandbox 
    # As we expect this command to potentially fail
    make sandbox-index EDITION=$edition SANDBOX_CONFIGURATION=$configuration || true
  done
done
