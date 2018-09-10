# run_deployfile_commands FILENAME COMMAND [COMMAND]...
# run_deployfile Deployfile command1 command2
run_deployfile_commands() {
  # Run specified Deployfile commands
  local deployfile="${1:-'Deployfile'}"
  local command_run=false
  if [[ ! -e "${deployfile}" ]]; then return 0; fi
  shift
  for command_name in "${@}"; do
    while read -r line || [[ -n "$line" ]]; do
      if [[ -z "$line" ]] || [[ "${line}" == \#* ]]; then continue; fi
      if [[ "${command_name}" == "${line%%:*}" ]]; then
        (>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
        eval "${line#*:[[:space:]]}"
        rc="${?}"
        [ "${rc}" != 0 ] && return "${rc}"
        command_run=true
      fi
    done < "${deployfile}"
  done
  # return 127 if no commands were run
  [[ "${command_run}" == "true" ]] && return 0 || return 127
}
