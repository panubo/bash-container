
function wait_url {
    # LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd
    # Wait for URL to be available
    local url=${1:-'http://localhost'}
    local timeout=${2:-30}
    echo -n "Connecting to URL at ${url}..."
    for (( i=0;; i++ )); do
        if [ ${i} -eq ${timeout} ]; then
            echo " timeout!"
            exit 99
        fi
        sleep 1
        (curl ${url}) &>/dev/null && break
        echo -n "."
    done
    echo " connected."
    exec 3>&-
    exec 3<&-
}
