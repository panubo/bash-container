#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/exec_procfile.sh

@test "exec_procfile: run successful command" {
  run exec_procfile Commandfile deploy1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Executing deploy1 from Commandfile...' ]
  [ "${lines[1]}" = 'Command 1' ]
}

@test "exec_procfile: run unknown command" {
  run exec_procfile Commandfile unknown-command
  [ "$status" -eq 127 ]
  [ "$result" == '' ]
}

@test "exec_procfile: run unknown command empty" {
  run exec_procfile Commandfile.empty unknown-command
  [ "$status" -eq 127 ]
  [ "$result" == '' ]
}

@test "exec_procfile: run non-zero exiting command" {
  run exec_procfile Commandfile.fail fail
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = 'Executing fail from Commandfile.fail...' ]
  [ "${lines[1]}" = '' ]
}
