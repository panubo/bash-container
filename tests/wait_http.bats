#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/wait_http.sh

@test "wait_http: connect to 80" {
  run wait_http http://github.com:80 30 5
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "Connecting to HTTP at http://github.com"* ]]
}

@test "wait_http: timeout connecting to filtered port" {
  run wait_http http://github.com:8080 3 1
  [ "$status" -eq 99 ]
  [[ "${lines[0]}" == *". timeout!" ]]
}
