#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/render_templates.sh

input_dir="$(pwd)/inputs"

# teardown() {
#   rm config.yaml config2.yaml config.yaml.bad 2>/dev/null || true
# }

@test "render_templates: render multiple templates" {
  # setup
  tmpdir="$(mktemp -d)"
  cp ${input_dir}/config.yaml.tmpl ${input_dir}/config2.yaml.tmpl ${tmpdir}
  export TEST_ENV_VAR=qwerty
  run render_templates ${tmpdir}/config.yaml.tmpl ${tmpdir}/config2.yaml.tmpl
  [ "$status" -eq 0 ]
  [ -e "${tmpdir}/config.yaml" ]
  IFS=$'\n' file=($(cat ${tmpdir}/config.yaml))
  [ "${file[0]}" == "qwerty" ]
  [ -e "${tmpdir}/config2.yaml" ]
  IFS=$'\n' file=($(cat ${tmpdir}/config2.yaml))
  [ "${file[0]}" == "qwerty" ]
  rm -rf ${tmpdir}
}

@test "render_templates: render and replace config.yaml" {
  tmpdir="$(mktemp -d)"
  printf "%s\n" "{{ .Env.TEST_ENV_VAR }}" > ${tmpdir}/config.yaml
  export TEST_ENV_VAR=qwerty
  run render_templates ${tmpdir}/config.yaml
  [ "$status" -eq 0 ]
  [ -e "${tmpdir}/config.yaml" ]
  IFS=$'\n' file=($(cat ${tmpdir}/config.yaml))
  [ "${file[0]}" == "qwerty" ]
  rm -rf ${tmpdir}
}

@test "render_templates: render fail on missing env" {
  tmpdir="$(mktemp -d)"
  printf "%s\n" "{{ .Env.DOESNOTEXIST }}" > ${tmpdir}/config.yaml.bad
  run render_templates ${tmpdir}/config.yaml.bad
  [ "$status" -eq 1 ]
  [[ "${lines[0]}" == "Rendering template ${tmpdir}/config.yaml.bad" ]]
  [[ "${lines[1]}" == *"at <.Env.DOESNOTEXIST>: map has no entry for key"* ]]
  rm -rf ${tmpdir}
}

@test "render_templates: render fail on non existent template" {
  run render_templates config.yaml.notexist
  [ "$status" -ne 0 ]
}

@test "render_templates: check file permissions are the same after rendering" {
  tmpdir="$(mktemp -d)"
  printf "%s\n" "{{ .Env.TEST_ENV_VAR }}" > ${tmpdir}/config.yaml
  export TEST_ENV_VAR=qwerty
  chmod 664 ${tmpdir}/config.yaml
  run render_templates ${tmpdir}/config.yaml
  [ "$status" -eq 0 ]
  [ "$(stat -c '%a' ${tmpdir}/config.yaml )" -eq 664 ]
  rm -rf ${tmpdir}
}
