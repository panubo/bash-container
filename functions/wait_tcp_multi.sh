# wait_tcp [HOST1,HOST2,HOST3] [MINIMUM] [PORT] [RETRIES] [TCP TIMEOUT]
# wait_tcp host1,host2,host3 2 80 30
wait_tcp_multi() {
  # Wait for multiple tcp services to be available
  command -v gtimeout >/dev/null 2>&1 || { error "This function requires timeout to be installed."; return 1; }
  local hosts="${1:-'localhost'}"
  local minimum_count="${2:-'1'}"
  local port="${3:-'80'}"
  local retries="${4:-30}"
  local tcp_timeout="${5:-2}"
  local success_count=0
  for host in $(echo ${hosts} | tr "," " "); do
    echo -n "Connecting to ${host}:${port}"
    for (( i=0;; i++ )); do
      [[ ${i} -eq "${retries}" ]] && { echo " timeout!"; break; }
      sleep 1
      gtimeout "${tcp_timeout}" bash -c "(exec 3<>/dev/tcp/${host}/${port}) &>/dev/null" && { ((success_count++)); echo " connected."; break; }
      echo -n "."
    done
    [[ "${success_count}" -ge "${minimum_count}" ]] && { echo "Found return ${success_count} services up"; return 0; }
    exec 3>&-
    exec 3<&-
  done
  return 99
}

wait_multi_rabbitmq() {
  wait_tcp_multi "${1}" "${2}" 5672
}

wait_multi_redis() {
  wait_tcp_multi "${1}" "${2}" 6379
}

wait_multi_elasticsearch() {
  wait_tcp_multi "${1}" "${2}" 9200
}
