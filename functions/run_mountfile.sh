# run_mountfile [FILENAME] [DATADIR]
# run_mountfile Mountfile /srv/remote
run_mountfile() {
  # Mount all dirs specified in Mountfile
  local mountfile="${1:-'Mountfile'}"
  local data="${2:-'/srv/remote'}"
  local mount_uid="48"
  local mount_gid="48"
  local source_dir=""
  local target_dir=""
  local working_dir=""

  if [[ $EUID -ne 0 ]]; then echo "Must be run as root"; return 1; fi
  if [[ ! -e "${mountfile}" ]]; then echo "Mountfile not found"; return 0; fi
  if [[ ! -e "${data}" ]]; then echo "Data dir not found"; return 1; fi

  # normalise path to Mountfile
  mountfile="$(readlink -f "${mountfile}")"

  # normalise data dir
  data="$(readlink -f "${data}")"

  # calculate working_dir from Mountfile location
  working_dir="$(dirname "${mountfile}")"

  # make sure we are operating in the same dir that holds the Mountfile
  pushd "${working_dir}" 1> /dev/null || exit 1

  while read -r line || [[ -n "${line}" ]]; do
    if [[ -z "${line}" ]] || [[ "${line}" == \#* ]]; then continue; fi
    [[ "${line}" =~ ([[:alnum:]/\.-]*)[[:space:]]?:[[:space:]]?(.*) ]]
    source_dir="${BASH_REMATCH[1]}"
    target_dir="${BASH_REMATCH[2]}"
    (>&1 echo "Mounting remote path ${source_dir} => ${target_dir}")

    # create ephemeral or remote dir if not exist
    if [[ "${source_dir}" == "ephemeral" ]]; then
      source_dir="$(mktemp -d)"
    else
      # make remote source dir if not exist
      [[ ! -e "${data}/${source_dir}" ]] && mkdir -p "${data}/${source_dir}"
      source_dir="${data}/${source_dir}"
    fi

    # remove if target_dir is a link
    [[ -L "${target_dir}" ]] && rm -f "${target_dir}"

    # create mount target (including parents) if required
    # NB this path is not normalised, however we are operating in $working_dir so relative paths are ok
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
