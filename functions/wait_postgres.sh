
function wait_postgres {
    # LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd
    # Wait for PostgreSQL to be available
    local host=${1:-'localhost'}
    local port=${2:-'5432'}
    local timeout=${3:-30}
    echo -n "Connecting to PostgreSQL at ${host}:${port}..."
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
