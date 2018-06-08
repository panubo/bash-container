#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/wait_tcp.sh

@test "wait_tcp: connect to 80" {
  run wait_tcp github.com 80 5
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Connecting to github.com:80 connected.' ]
}

@test "wait_tcp: timeout connecting to filtered port" {
  run wait_tcp github.com 8080 2
  [ "$status" -eq 99 ]
  [ "${lines[0]}" = 'Connecting to github.com:8080.. timeout!' ]
}
