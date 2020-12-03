#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/run_commands.sh

@test "run_commands: only first" {
  run run_commands Commandfile deploy1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task deploy1: echo "Command 1"' ]
  [ "${lines[1]}" = 'Command 1' ]
  [ "${lines[2]}" = '' ]
}

@test "run_commands: only second" {
  run run_commands Commandfile deploy2
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task deploy2: echo "Command 2"' ]
  [ "${lines[1]}" = 'Command 2' ]
  [ "${lines[2]}" = '' ]
}

@test "run_commands: out of order args" {
  run run_commands Commandfile deploy2 deploy1
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task deploy2: echo "Command 2"' ]
  [ "${lines[1]}" = 'Command 2' ]
  [ "${lines[2]}" = 'Running task deploy1: echo "Command 1"' ]
  [ "${lines[3]}" = 'Command 1' ]
}

@test "run_commands: command not found" {
  run run_commands Commandfile /bin/true
  [ "$status" -eq 127 ]
}

@test "run_commands: failure error code returned - command failed" {
  run run_commands Commandfile fail
  [ "$status" -eq 1 ]
}

@test "run_commands: failure error code returned - command not found, and none others run" {
  run run_commands Commandfile unknown-command
  [ "$status" -eq "127" ]
}

@test "run_commands: failure error code returned - command not found, and others run" {
  run run_commands Commandfile deploy1 unknown-command deploy2
  [ "$status" -eq "127" ]
  [ "${lines[2]}" = 'Error: command unknown-command not found' ]
}

@test "run_commands: Commandfile not exist" {
  run run_commands Commandfile.notexist
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = '' ]
}
