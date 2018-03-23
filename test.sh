#!/usr/bin/env bash

# Run all bats tests

set -e

finish() {
  popd 1> /dev/null
}
trap finish EXIT

pushd tests 1> /dev/null
bats *.bats
