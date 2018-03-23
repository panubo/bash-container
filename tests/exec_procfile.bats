#!/usr/bin/env bats

source ../functions/exec_procfile.sh

@test "run successful command" {
  run exec_procfile Commandfile deploy1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Executing deploy1 from Commandfile...' ]
  [ "${lines[1]}" = 'Command 1' ]
}

@test "run unknown command" {
  run exec_procfile Commandfile unknown-command
  [ "$status" -eq 0 ]
  [ "$result" == "" ]
}

@test "run non-zero exiting command" {
  run exec_procfile Commandfile.fail fail
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = 'Executing fail from Commandfile.fail...' ]
  [ "${lines[1]}" = '' ]
}
