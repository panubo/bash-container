# Docker --env-file doesn't interpret env files the the same as bash (`. ./env`) does 
# eg. 'VARIABLE="foo bar"' would be 'VARIABLE=foo bar' in bash but 'VARIABLE="foo bar"' with Docker
# This function sources and env file and then exports each variable by name (avoiding issues trying to do export $(cat env | xargs))
# Since this is executed as a function the exports will be available to sub processes.
# Usage: import_env ENVFILE
import_env() {
  local file
  [[ ! -e "${1}" ]] && error "${1} does not exist"
  [[ ! -f "${1}" ]] && error "${1} is not a file"
  file="$(realpath "${1}")"
  # shellcheck disable=SC1090
  . "${file}"

  while read -r item; do
  	# Disabling shellcheck warning see https://github.com/koalaman/shellcheck/wiki/SC2163
  	# shellcheck disable=SC2163
    export "${item?}"
  done < <(sed -E -e '/^(#|$)/d' -e 's/([a-zA-Z0-9_])=.*/\1/' "${file}")
}
