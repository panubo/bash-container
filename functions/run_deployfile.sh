#!/usr/bin/env bash

run_deployfile() {
    # LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd
    # Run all Deployfile commands
    local deployfile=${1:-'Deployfile'}
    local command_run=false
    if [ ! -e "$deployfile" ]; then return 0; fi
    while read line || [[ -n "$line" ]]; do
        if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then continue; fi
        (>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
        eval "${line#*:[[:space:]]}"
        rc=$?
        [ "$rc" != 0 ] && exit $rc
        command_run=true
    done < "$deployfile"
    [ $command_run ] && exit 0 || return
}

run_deployfile "$@"
