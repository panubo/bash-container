
run_deployfile() {
    # LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd
    # Run Deployfile commands
	local deployfile=${1:-'Deployfile'}
	if [ ! -e "$deployfile" ]; then return 0; fi
	while read line || [[ -n "$line" ]]; do
		if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then continue; fi
		(>&2 echo "Running task ${line%%:*}: ${line#*:[[:space:]]}")
		eval "${line#*:[[:space:]]}"
	done < "$deployfile"
}
