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
  local deployfile=${1:-'Deployfile'}
  local command_run=false
  if [ ! -e "$deployfile" ]; then return 0; fi
  shift
  for command_name in "$@"; do
    while read -r line || [[ -n "$line" ]]; do
      if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then continue; fi
      if [[ "${command_name}" == "${line%%:*}" ]]; then
        (>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
        eval "${line#*:[[:space:]]}"
        rc=$?
        [ "$rc" != 0 ] && exit $rc
        command_run=true
      fi
    done < "$deployfile"
  done
  # exit 0 if commands run else return
  [ $command_run = true ] && exit 0 || return 0
}
