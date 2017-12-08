#!/usr/bin/env bats

source ../functions/genpasswd.sh


@test "only first" {
  run genpasswd
  [ "$status" -eq 0 ]
}
