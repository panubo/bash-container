set_timezone() {
  TZ="${1:-Etc/UTC}"
  if [[ ! -e "/usr/share/zoneinfo/${TZ}" ]]; then
    error "Unable to find timezone ${TZ}"
    return 1
  fi
  export TZ
  ln -snf "/usr/share/zoneinfo/${TZ}" "/etc/localtime"
}
