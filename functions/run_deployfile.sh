#!/usr/bin/env bash

run_deployfile() {
    # LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd
    # Run all Deployfile commands
    local deployfile=${1:-'Deployfile'}
    if [ ! -e "$deployfile" ]; then return 0; fi
    while read line || [[ -n "$line" ]]; do
        if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then continue; fi
        (>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
        eval "${line#*:[[:space:]]}"
        rc=$?
        [ "$rc" != 0 ] && exit $rc
    done < "$deployfile"
    return
}

run_deployfile "$@"
