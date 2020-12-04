#!/usr/bin/env bats

# It is difficult to test the action of this function so we're just checking it
# runs without error and fails on common issues.

source ../functions/10-common.sh
source ../functions/import_env.sh

input_dir="$(pwd)/inputs"

teardown() {
  rm -rf env 2>/dev/null || true
}

@test "import_env: run successful" {
  run import_env ${input_dir}/env.good
  [ "$status" -eq 0 ]
}

@test "import_env: error on missing file" {
  run import_env ${input_dir}/env
  [ "$status" -eq 1 ]
}

@test "import_env: error on directory instead of file" {
  tmpdir=$(mktemp -d)
  run import_env $tmpdir
  [ "$status" -eq 2 ]
  rmdir $tmpdir
}

@test "import_env: error on bad environment definition" {
  run import_env ${input_dir}/env.bad
  [ "$status" -ne 0 ]
}
