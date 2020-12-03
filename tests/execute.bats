#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/execute.sh

@test "execute: run successful command" {
  run execute Commandfile deploy1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Executing deploy1 from Commandfile...' ]
  [ "${lines[1]}" = 'Command 1' ]
}

@test "execute: run unknown command" {
  run execute Commandfile unknown-command
  [ "$status" -eq 127 ]
  [ "$result" == '' ]
}

@test "execute: run unknown command empty" {
  run execute Commandfile.empty unknown-command
  [ "$status" -eq 127 ]
  [ "$result" == '' ]
}

@test "execute: run non-zero exiting command" {
  run execute Commandfile.fail fail
  [ "$status" -ne 0 ]
  [ "${lines[0]}" = 'Executing fail from Commandfile.fail...' ]
  [ "${lines[1]}" = '' ]
}
