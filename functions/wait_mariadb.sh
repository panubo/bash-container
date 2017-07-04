# LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd

function wait_mariadb {
    # Wait for MariaDB to be available
    local host=${1:-'localhost'}
    local port=${2:-'3306'}
    local timeout=${3:-30}
    echo -n "Waiting to connect to MariaDB at ${host}:${port}"
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
