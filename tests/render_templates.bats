#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/render_templates.sh

teardown() {
  rm config.yaml config2.yaml config.yaml.bad 2>/dev/null || true
}

@test "render_templates: render templates" {
  export TEST_ENV_VAR=qwerty
  run render_templates config.yaml.tmpl config2.yaml.tmpl
  [ "$status" -eq 0 ]
  [ -e "config.yaml" ]
  IFS=$'\n' file=($(cat config.yaml))
  [ "${file[0]}" == "qwerty" ]
  [ -e "config2.yaml" ]
  IFS=$'\n' file=($(cat config2.yaml))
  [ "${file[0]}" == "qwerty" ]
}

@test "render_templates: render and replace config.yaml" {
  printf "%s\n" "{{ .Env.TEST_ENV_VAR }}" > config.yaml
  export TEST_ENV_VAR=qwerty
  run render_templates config.yaml
  [ "$status" -eq 0 ]
  [ -e "config.yaml" ]
  IFS=$'\n' file=($(cat config.yaml))
  [ "${file[0]}" == "qwerty" ]
}

@test "render_templates: render fail on missing file" {
  printf "%s\n" "{{ .Env.DOESNOTEXIST }}" > config.yaml.bad
  run render_templates config.yaml.nofile
  [ "$status" -ne 0 ]
  [ "${output}" == "Error: File config.yaml.nofile is missing." ]
}

@test "render_templates: render fail on bad template" {
  run render_templates config.yaml.bad
  [ "$status" -ne 0 ]
}

@test "render_templates: check file permissions are the same" {
  printf "%s\n" "{{ .Env.TEST_ENV_VAR }}" > config.yaml
  export TEST_ENV_VAR=qwerty
  chmod 664 config.yaml
  run render_templates config.yaml
  [ "$status" -eq 0 ]
  [ "$(stat -c '%a' config.yaml )" -eq 664 ]
}
