#!/usr/bin/env bats

source ../functions/run_deployfile.sh

@test "run all commands" {
  run run_deployfile Deployfile.onetwothree
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task one: echo "Command 1"' ]
  [ "${lines[1]}" = 'Command 1' ]
  [ "${lines[2]}" = 'Running task two: echo "Command 2"' ]
  [ "${lines[3]}" = 'Command 2' ]
  [ "${lines[4]}" = 'Running task three: echo "Command 3"' ]
  [ "${lines[5]}" = 'Command 3' ]
}

@test "run fail command" {
  run run_deployfile Deployfile.fail
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = 'Running task fail: false' ]
  [ "${lines[1]}" = '' ]
}
