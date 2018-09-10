# exec_procfile FILENAME TYPE
# exec_procfile Procfile web
exec_procfile() {
  # Exec Procfile command
  local procfile="${1:-'Procfile'}"
  if [[ ! -e "${procfile}" ]]; then return 0; fi
  while read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]] || [[ "${line}" == \#* ]]; then continue; fi
    if [[ "${2}" == "${line%%:*}" ]]; then
      echo "Executing ${2} from ${1}..."
      eval exec "${line#*:[[:space:]]}"
    fi
  done < "${procfile}"
  # return 1 if no commands were run
  return 1
}
