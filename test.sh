#!/usr/bin/env bash

# Run all bats tests

pushd tests 1> /dev/null
bats *.bats
popd 1> /dev/null
