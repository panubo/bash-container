
exec_procfile() {
    # LICENSE: MIT License, Copyright (c) 2017 Volt Grid Pty Ltd
    # Exec Procfile command
	local procfile=${1:-'Procfile'}
	while read line || [[ -n "$line" ]]; do
		if [[ -z "$line" ]] || [[ "$line" == \#* ]]; then continue; fi
		if [[ "${2}" == "${line%%:*}" ]]; then
			echo "Executing ${2} from ${1}..."
			eval exec "${line#*:[[:space:]]}"
		fi
	done < "$procfile"
}
