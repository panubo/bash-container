#!/usr/bin/env bats

export BATS_SUDO=true

@test "set_timezone: set timezone Australia/Sydney" {
  run ./_test.sh set_timezone Australia/Sydney
  [ "$status" -eq 0 ]
  [ "$(readlink /etc/localtime)" == "/usr/share/zoneinfo/Australia/Sydney" ]
}

@test "set_timezone: set timezone default" {
  run ./_test.sh set_timezone
  [ "$status" -eq 0 ]
  [ "$(readlink /etc/localtime)" == "/usr/share/zoneinfo/Etc/UTC" ]
}

@test "set_timezone: set unknown timezone" {
  run ./_test.sh set_timezone Australia/Goulburn
  [ "$status" -eq 1 ]
}
