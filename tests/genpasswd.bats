#!/usr/bin/env bats

#source ../functions/genpasswd.sh


@test "generate password" {
  run ./functions/genpasswd.sh
  status="$?"
  [ "$?" -eq 0 ]
}
