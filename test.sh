#!/usr/bin/env bash

set -e

# Check for requirements
for C in 'bats curl gomplate timeout'; do
  command -v ${C} >/dev/null 2>&1 || { echo "Error: Tests require ${C} to be installed."; exit 1; }
done

# Run all bats tests

finish() {
  popd 1> /dev/null
}
trap finish EXIT

pushd tests 1> /dev/null
bats *.bats
