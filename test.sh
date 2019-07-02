#!/usr/bin/env bash

set -e

# Check for requirements
for C in bats curl gomplate timeout; do
  command -v ${C} >/dev/null 2>&1 || { echo "Error: Tests require ${C} to be installed."; exit 1; }
done

# Log version of bats used
bats --version

# trap errors
finish() {
  popd 1> /dev/null
}
trap finish EXIT

# Run all bats tests
pushd tests 1> /dev/null
bats *.bats
