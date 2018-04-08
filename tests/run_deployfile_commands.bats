#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/run_deployfile_commands.sh

@test "run_deployfile_commands: only first" {
  run run_deployfile_commands Commandfile deploy1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task deploy1: echo "Command 1"' ]
  [ "${lines[1]}" = 'Command 1' ]
  [ "${lines[2]}" = '' ]
}

@test "run_deployfile_commands: only second" {
  run run_deployfile_commands Commandfile deploy2
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task deploy2: echo "Command 2"' ]
  [ "${lines[1]}" = 'Command 2' ]
  [ "${lines[2]}" = '' ]
}

@test "run_deployfile_commands: out of order args" {
  run run_deployfile_commands Commandfile deploy2 deploy1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task deploy2: echo "Command 2"' ]
  [ "${lines[1]}" = 'Command 2' ]
  [ "${lines[2]}" = 'Running task deploy1: echo "Command 1"' ]
  [ "${lines[3]}" = 'Command 1' ]
}

@test "run_deployfile_commands: failure error code returned" {
  run run_deployfile_commands Commandfile fail
  [ "$status" -eq 1 ]
}

@test "run_deployfile_commands: Commandfile not exist" {
  run run_deployfile_commands Commandfile.notexist
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = '' ]
}
