#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/wait_kubeapi.sh

@test "wait_kubeapi: connecting to mock kubeapi" {
  kubectl() {
    echo "Mocked kubectl command"
    sleep 1
  }
  run wait_kubeapi 5
  [ "$status" -eq 0 ]
  [[ "${lines[0]}" == "Connecting to Kubernetes API"* ]]
}

@test "wait_kubeapi: timeout connecting mock kubeapi" {
  kubectl() {
    echo "Mocked kubectl command"
    exit 1
  }
  run wait_kubeapi 1
  [ "$status" -eq 99 ]
  [[ "${lines[0]}" == *". timeout!" ]]
}
