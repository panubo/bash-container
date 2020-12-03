# run_commands FILENAME COMMAND [COMMAND]...
# run_commands Procfile command1 command2
run_commands() {
  # Run specified Procfile commands and then return, or if no commands found
  # return with 127. Exits with 127 on failure to find subsequent commands.
  local procfile=${1:-'Procfile'}
  local command_run="false"
  if [ ! -e "$procfile" ]; then return 0; fi
  shift
  for command_name in "$@"; do
   local command_found="false"
    while read -r line || [[ -n "$line" ]]; do
      if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then continue; fi
      if [[ "${command_name}" == "${line%%:*}" ]]; then
        command_found="true"
        (>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
        eval "${line#*:[[:space:]]}"
        rc="${?}"
        command_run="true"
        [ "$rc" != 0 ] && exit "${rc}"
      fi
    done < "$procfile"
    # return if one command has been run and then another is not found
    [[ "${command_run}" == "true" ]] && [[ "${command_found}" == "false" ]] && { error "command ${command_name} not found"; exit 127; }
  done
  # return 127 if no commands were run
  [[ "${command_run}" == "true" ]] && return 0 || return 127
}

# aliases
run_procfile_commands() {
  run_commands Procfile "${@}"
}

run_deployfile_commands() {
  run_commands Deployfile "${@}"
}
