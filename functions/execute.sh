# execute FILENAME TYPE
# execute Procfile web
execute() {
  # Exec Procfile command
  local procfile="${1:-'Procfile'}"
  if [[ ! -e "${procfile}" ]]; then return 0; fi
  while read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]] || [[ "${line}" == \#* ]]; then continue; fi
    if [[ "${2}" == "${line%%:*}" ]]; then
      echo "Executing ${2} from $(basename "${1}")..."
      eval exec "${line#*:[[:space:]]}"
    fi
  done < "${procfile}"
  # return 127 if no command was exec'd
  return 127
}

exec_procfile() {
  execute Procfile "$1"
}
