#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/run_deployfile_strict.sh

@test "run_deployfile_strict: run all commands" {
  run run_deployfile_strict Commandfile.onetwothree
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task one: echo "Command 1"' ]
  [ "${lines[1]}" = 'Command 1' ]
  [ "${lines[2]}" = 'Running task two: echo "Command 2"' ]
  [ "${lines[3]}" = 'Command 2' ]
  [ "${lines[4]}" = 'Running task three: echo "Command 3"' ]
  [ "${lines[5]}" = 'Command 3' ]
}

@test "run_deployfile_strict: run fail command" {
  run run_deployfile_strict Commandfile.fail
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = 'Running task fail: false' ]
  [ "${lines[1]}" = '' ]
}

@test "run_deployfile_strict: command not found" {
  run run_deployfile_strict Commandfile.empty
  [ "$status" -eq 127 ]
}

@test "run_deployfile_strict: Commandfile not exist" {
  run run_deployfile_strict Commandfile.notexist
  [ "$status" -eq 2 ]
  [ "${lines[0]}" = '' ]
}
