# run_mountfile [FILENAME] [DATADIR]
# run_mountfile Mountfile /srv/remote
run_mountfile() {
  # Mount all dirs specified in Mountfile
  local mountfile="${1:-"Mountfile"}"
  local data_dir="${2:-"/srv/remote"}"
  local mount_uid="48"
  local mount_gid="48"
  local source_dir=""
  local target_dir=""
  local working_dir=""

  if [[ $EUID -ne 0 ]]; then echo "Must be run as root"; return 1; fi
  if [[ ! -e "${mountfile}" ]]; then echo "Mountfile not found"; return 0; fi
  if [[ ! -e "${data_dir}" ]]; then echo "Data dir not found"; return 1; fi

  # normalise path to Mountfile
  mountfile="$(realpath "${mountfile}")"

  # normalise data dir
  data_dir="$(realpath "${data_dir}")"

  # calculate working_dir from Mountfile location
  working_dir="$(dirname "${mountfile}")"

  # make sure we are operating in the same dir that holds the Mountfile
  pushd "${working_dir}" 1> /dev/null || exit 1

  while read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]] || [[ "${line}" == \#* ]]; then continue; fi
    [[ "${line}" =~ ([[:alnum:]/\.-]*)[[:space:]]?:[[:space:]]?(.*) ]]
    s="${BASH_REMATCH[1]}"
    t="${BASH_REMATCH[2]}"

    # normalise
    target_dir="$(readlink -f -m "${t}")"

    # handle ephemeral
    if [[ "${s}" == "ephemeral" ]]; then
      # create ephemeral
      source_dir="$(mktemp -d)"
    else
      # normalise
      source_dir="$(cd "${data_dir}" && readlink -f -m "${s}")"
      # safety checks
      [[ ! "${target_dir}" =~ ${working_dir} ]] && { echo "Error: Target outside working directory!" && exit 129; }
      [[ ! "${source_dir}" =~ ${data_dir} ]] && { echo "Error: Source not within data directory!" && exit 129; }
    fi

    (>&1 echo "Mounting remote path ${source_dir} => ${target_dir}")

    # make remote source dir if not exist
    [[ ! -e "${source_dir}" ]] && mkdir -p "${source_dir}"

    # remove if target_dir is a link
    [[ -L "${target_dir}" ]] && rm -f "${target_dir}"

    # create mount target (including parents) if required
    mkdir -p "${target_dir}"

    # Copy mount to remote, if remote is empty, and target_dir has files
    if [[ "$(ls -A "${target_dir}")" ]] && [ ! "$(ls -A "${source_dir}")" ]; then
      cp -a "${target_dir}/" "${source_dir}/"
      # Fix permissions recursively in remote
      chown -R ${mount_uid}:${mount_gid} "${source_dir}"
    else
      # Set permission on remote
      chown ${mount_uid}:${mount_gid} "${source_dir}"
    fi

    # Delete target_dir if exists. Create symlink to source_dir
    [[ -e "${target_dir}" ]] && rm -rf "${target_dir}"
    ln -snf "${source_dir}" "${target_dir}"

  done < "${mountfile}"
}
