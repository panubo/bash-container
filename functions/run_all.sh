# run_all [FILENAME]
# run_all Procfile
run_all() {
  # Run all Procfile commands
  local procfile="${1:-'Procfile'}"
  local command_run="false"
  if [[ ! -e "${procfile}" ]]; then return 2; fi
  while read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]] || [[ "${line}" == \#* ]]; then continue; fi
    (>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
    eval "${line#*:[[:space:]]}"
    rc=$?
    [[ "${rc}" -ne 0 ]] && return "${rc}"
    command_run=true
  done < "${procfile}"
  # return 127 if no commands were run
  [[ "${command_run}" == "true" ]] && return 0 || return 127
}

# aliases
run_deployfile() {
  run_all Deployfile "${@}"
}

run_procfile() {
  run_all Procfile "${@}"
}
