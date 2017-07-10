# LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd

function genpasswd() {
    # Generate password
    local length=${1:-16}
    set +o pipefail
    strings < /dev/urandom | LC_CTYPE=C tr -dc A-Za-z0-9_ | head -c ${length}
    set -o pipefail
}
