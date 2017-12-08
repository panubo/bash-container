
function wait_http {
    # LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd
    # Wait for HTTP to be available
    local host=${1:-'localhost'}
    local port=${2:-'80'}
    local timeout=${3:-30}
    echo -n "Connecting to HTTP at ${host}:${port}..."
    for (( i=0;; i++ )); do
        if [ ${i} -eq ${timeout} ]; then
            echo " timeout!"
            exit 99
        fi
        sleep 1
        (exec 3<>/dev/tcp/${host}/${port}) &>/dev/null && break
        echo -n "."
    done
    echo " connected."
    exec 3>&-
    exec 3<&-
}