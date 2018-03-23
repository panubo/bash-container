#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/render_templates.sh

teardown() {
  rm config.yaml config.yaml.bad 2>/dev/null || true
}

@test "render config.yaml.tmpl" {
  export TEST_ENV_VAR=qwerty
  run render_templates config.yaml.tmpl
  [ "$status" -eq 0 ]
  [ -e "config.yaml" ]
  IFS=$'\n' file=($(cat config.yaml))
  [ "${file[0]}" == "qwerty" ]
}

@test "render and replace config.yaml" {
  printf "%s\n" "{{ .Env.TEST_ENV_VAR }}" > config.yaml
  export TEST_ENV_VAR=qwerty
  run render_templates config.yaml
  [ "$status" -eq 0 ]
  [ -e "config.yaml" ]
  IFS=$'\n' file=($(cat config.yaml))
  [ "${file[0]}" == "qwerty" ]
}

@test "render fail on missing file" {
  printf "%s\n" "{{ .Env.DOESNOTEXIST }}" > config.yaml.bad
  run render_templates config.yaml.nofile
  [ "$status" -ne 0 ]
  [ "${output}" == "File config.yaml.nofile is missing." ]
}

@test "render fail on bad template" {
  run render_templates config.yaml.bad
  [ "$status" -ne 0 ]
}
