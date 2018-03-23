#!/usr/bin/env bats

source ../functions/wait_tcp.sh

@test "wait_tcp connect to 80" {
  run wait_tcp google.com 80 5
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Connecting to google.com:80 connected.' ]
}

@test "wait_tcp timeout connecting to filtered port" {
  run wait_tcp google.com 8080 2
  [ "$status" -eq 99 ]
  [ "${lines[0]}" = 'Connecting to google.com:8080.. timeout!' ]
}