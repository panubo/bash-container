#!/usr/bin/env bash

run_deployfile_commands() {
    # LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd
    # Run specified Deployfile commands
    local deployfile=${1:-'Deployfile'}
    shift
    if [ ! -e "$deployfile" ]; then return 0; fi
    for command_name in "$@"; do
        while read line || [[ -n "$line" ]]; do
            if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then continue; fi
            if [[ "${command_name}" == "${line%%:*}" ]]; then
                (>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
                eval "${line#*:[[:space:]]}"
                rc=$?
                [ "$rc" != 0 ] && exit $rc
            fi
        done < "$deployfile"
    done
    return
}

run_deployfile_commands "$@"
