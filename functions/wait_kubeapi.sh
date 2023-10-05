# wait_kubeapi [RETRIES]
# wait_kubeapi 30
wait_kubeapi() {
  # Wait for Kubernetes API to be available
  command -v kubectl >/dev/null 2>&1 || { error "This function requires kubectl to be installed."; return 1; }
  local retries="${1:-30}"
  echo -n "Connecting to Kubernetes API"
  for (( i=0;; i++ )); do
    if [[ ${i} -eq "${retries}" ]]; then
      echo " timeout!"
      return 99
    fi
    sleep 1
    (kubectl version) &>/dev/null && break
    echo -n "."
  done
  echo " connected."
  exec 3>&-
  exec 3<&-
}
