# LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd

run_procfile() {
    # Run Procfile commands
	local procfile=${1:-'Procfile'}
	while read line || [[ -n "$line" ]]; do
		if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then continue; fi
		if [[ "${2}" == "${line%%:*}" ]]; then
			if [ "x${NO_DEPLOY}" == "x" ]; then
				(run_deploy "Deployfile")
			fi
			eval exec "${line#*:[[:space:]]}"
		fi
	done < "$procfile"
}
