# run_deployfile [FILENAME]
# run_deployfile Deployfile
run_deployfile() {
  # Run all Deployfile commands
  local deployfile="${1:-'Deployfile'}"
  local command_run=false
  if [ ! -e "${deployfile}" ]; then return 0; fi
  while read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]] || [[ "${line}" == \#* ]]; then continue; fi
    (>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
    eval "${line#*:[[:space:]]}"
    rc=$?
    [[ "${rc}" != 0 ]] && exit "${rc}"
    command_run=true
  done < "${deployfile}"
  [[ "${command_run}" = true ]] && exit 0 || return
}
