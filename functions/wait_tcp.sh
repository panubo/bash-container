# wait_tcp HOST [PORT] [RETRIES] [TCP TIMEOUT]
# wait_tcp localhost 80 30
wait_tcp() {
  # Wait for tcp service to be available
  command -v timeout >/dev/null 2>&1 || { error "This function requires timeout to be installed."; return 1; }
  local host="${1:-'localhost'}"
  local port="${2:-'80'}"
  local retries="${3:-30}"
  local tcp_timeout="${4:-2}"
  echo -n "Connecting to ${host}:${port}"
  for (( i=0;; i++ )); do
    if [[ ${i} -eq "${retries}" ]]; then
      echo " timeout!"
      return 99
    fi
    sleep 1
    timeout "${tcp_timeout}" bash -c "(exec 3<>/dev/tcp/${host}/${port}) &>/dev/null" && break
    echo -n "."
  done
  echo " connected."
  exec 3>&-
  exec 3<&-
}

wait_mariadb() {
  wait_tcp "${1}" 3306
}

wait_postgres() {
  wait_tcp "${1}" 5432
}

wait_rabbitmq() {
  wait_tcp "${1}" 5672
}

wait_redis() {
  wait_tcp "${1}" 6379
}
