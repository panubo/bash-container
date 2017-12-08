#!/usr/bin/env bats

source ../functions/exec_procfile.sh

@test "run sucessful command" {
  result="$(exec_procfile Commandfile deploy1)"
  status="$?"
  [ "$status" -eq 0 ]
  echo ${result} | grep -q "Executing deploy1 from Commandfile..."
}

@test "run unknown command" {
  result="$(exec_procfile Commandfile unknown-command)"
  status="$?"
  [ "$status" -eq 0 ]
  [ "$result" == "" ]
}
