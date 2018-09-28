#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/set_timezone.sh

@test "set_timezone: set timezone Australia/Sydney" {
  run set_timezone Australia/Sydney
  [ "$status" -eq 0 ]
  [ "$(readlink /etc/localtime)" == "/usr/share/zoneinfo/Australia/Sydney" ]
}

@test "set_timezone: set timezone default" {
  run set_timezone
  [ "$status" -eq 0 ]
  [ "$(readlink /etc/localtime)" == "/usr/share/zoneinfo/Etc/UTC" ]
}

@test "set_timezone: set unknown timezone" {
  run set_timezone Australia/Goulburn
  [ "$status" -ne 0 ]
}
