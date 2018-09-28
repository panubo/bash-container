# run_deployfile_strict [FILENAME]
# run_deployfile_strict Deployfile
run_deployfile_strict() {
  # Run all Deployfile commands
  local deployfile="${1:-'Deployfile'}"
  local command_run=false
  if [[ ! -e "${deployfile}" ]]; then return 2; fi
  while read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]] || [[ "${line}" == \#* ]]; then continue; fi
    (>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
    eval "${line#*:[[:space:]]}"
    rc=$?
    [[ "${rc}" -ne 0 ]] && return "${rc}"
    command_run=true
  done < "${deployfile}"
  # return 127 if no commands were run
  [[ "${command_run}" == "true" ]] && return 0 || return 127
}
