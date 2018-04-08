#!/usr/bin/env bats

# It is difficult to test the action of this function so we're just checking it
# runs without error and fails on common issues.

source ../functions/10-common.sh
source ../functions/import_env.sh

teardown() {
  rm -rf env 2>/dev/null || true
}

@test "import_env: run successful" {
  echo "VARIABLE=value" > env
  run import_env env
  [ "$status" -eq 0 ]
}

@test "import_env: error on missing file" {
  run import_env env
  [ "$status" -eq 1 ]
}

@test "import_env: error on directory instead of file" {
  mkdir env
  run import_env env
  [ "$status" -eq 2 ]
}
