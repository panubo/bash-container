# run_procfile_commands FILENAME COMMAND [COMMAND]...
# run_procfile_commands Procfile command1 command2
run_procfile_commands() {
  # Run specified Procfile commands and then exit, or if no commands found
  # return without exiting
  #
  # Usage:
  #
  # run_commands Procfile "${@}"
  # exec "${@}"
  #
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
    # exit if one command has been run and then another is not found
    [[ "${command_run}" == "true" ]] && [[ "${command_found}" == "false" ]] && { echo "Error command ${command_name} not found"; exit 127; }
  done
  # exit 0 if commands run else return
  [[ "${command_run}" == "true" ]] && exit 0 || return 0
}
