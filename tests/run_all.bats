#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/run_all.sh

@test "run_all: run all commands" {
  run run_all inputs/Commandfile.onetwothree
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task one: echo "Command 1"' ]
  [ "${lines[1]}" = 'Command 1' ]
  [ "${lines[2]}" = 'Running task two: echo "Command 2"' ]
  [ "${lines[3]}" = 'Command 2' ]
  [ "${lines[4]}" = 'Running task three: echo "Command 3"' ]
  [ "${lines[5]}" = 'Command 3' ]
}

@test "run_all: run fail command" {
  bats_require_minimum_version 1.5.0
  run -1 run_all inputs/Commandfile.fail
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = 'Running task fail: false' ]
  [ "${lines[1]}" = '' ]
}

@test "run_all: command not found" {
  bats_require_minimum_version 1.5.0
  run -127 run_all inputs/Commandfile.empty
  [ "$status" -eq 127 ]
}

@test "run_all: Commandfile not exist" {
  bats_require_minimum_version 1.5.0
  run -2 run_all inputs/Commandfile.notexist
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = '' ]
}
