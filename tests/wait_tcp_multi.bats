#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/wait_tcp_multi.sh

@test "wait_tcp_multi: connect to 80" {
  run wait_tcp_multi google.com 1 80 5
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Connecting to google.com:80 connected.' ]
}

@test "wait_tcp_multi: connect to 80 (2 of 3)" {
  run wait_tcp_multi google.com,foo.example.com,bing.com 2 80 5
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Connecting to google.com:80 connected.' ]
  [ "${lines[1]}" = 'Connecting to foo.example.com:80..... timeout!' ]
  [ "${lines[2]}" = 'Connecting to bing.com:80 connected.' ]
  [ "${lines[3]}" = 'Found return 2 services up' ]
}

@test "wait_tcp_multi: timeout connecting to filtered port" {
  run wait_tcp_multi google.com 1 8080 2
  [ "$status" -eq 99 ]
  [ "${lines[0]}" = 'Connecting to google.com:8080.. timeout!' ]
}
