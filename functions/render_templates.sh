# render_templates FILENAME [FILENAME]...
# render_templates config.yaml.tmpl
# Note: the template file will be replaced if it does not end with .tmpl
render_templates() {
  command -v gomplate >/dev/null 2>&1 || error "This function requires gomplate to be installed."

  for item in ${@}; do
  	local item_dirname tempfile
  	[[ -e "${item}" ]] || error "File ${item} is missing."
  	item_dirname="$(dirname "${item}")"
  	tempfile="$(mktemp -p "${item_dirname}" -t .tmp.XXXXXXXXXX)"

    gomplate < "${item}" > "${tempfile}" || { rm "${tempfile}" 2>/dev/null; error "Failed to render template ${item}."; }
    mv "${tempfile}" "${item/%\.tmpl/}"
    
    if [[ "${DEBUG:-false}" == 'true' ]]; then
      echo "==> ${item/%\.tmpl/} <=="
      cat "${item/%\.tmpl/}"
    fi
  done
}
