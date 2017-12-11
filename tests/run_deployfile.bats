#!/usr/bin/env bats

@test "run all commands" {
  run ../functions/run_deployfile.sh Commandfile.onetwothree
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Running task one: echo "Command 1"' ]
  [ "${lines[1]}" = 'Command 1' ]
  [ "${lines[2]}" = 'Running task two: echo "Command 2"' ]
  [ "${lines[3]}" = 'Command 2' ]
  [ "${lines[4]}" = 'Running task three: echo "Command 3"' ]
  [ "${lines[5]}" = 'Command 3' ]
}

@test "run fail command" {
  run ../functions/run_deployfile.sh Commandfile.fail
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = 'Running task fail: false' ]
  [ "${lines[1]}" = '' ]
}

@test "Command file not exist" {
  run ../functions/run_deployfile.sh Commandfile.notexist
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = '' ]
}
