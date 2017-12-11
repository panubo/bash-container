#!/usr/bin/env bats

@test "only first" {
  run ../functions/run_deployfile_commands.sh Commandfile deploy1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task deploy1: echo "Command 1"' ]
  [ "${lines[1]}" = 'Command 1' ]
  [ "${lines[2]}" = '' ]
}

@test "only second" {
  run ../functions/run_deployfile_commands.sh Commandfile deploy2
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task deploy2: echo "Command 2"' ]
  [ "${lines[1]}" = 'Command 2' ]
  [ "${lines[2]}" = '' ]
}

@test "out of order args" {
  run ../functions/run_deployfile_commands.sh Commandfile deploy2 deploy1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task deploy2: echo "Command 2"' ]
  [ "${lines[1]}" = 'Command 2' ]
  [ "${lines[2]}" = 'Running task deploy1: echo "Command 1"' ]
  [ "${lines[3]}" = 'Command 1' ]
}

@test "failure error code returned" {
  run ../functions/run_deployfile_commands.sh Commandfile fail
  [ "$status" -eq 1 ]
}
