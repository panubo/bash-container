#!/usr/bin/env bats

export BATS_SUDO=true

input_dir="$(pwd)/inputs"

@test "run_mountfile: test defaults" {
  [[ $EUID -eq 0 ]] && mkdir -p /srv/remote || sudo mkdir -p /srv/remote
  run ./_test.sh run_mountfile ${input_dir}/Mountfile
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = '' ]
}

@test "run_mountfile: mountfile does not exist" {
  run ./_test.sh run_mountfile ${input_dir}/Mountfile.doesntexist
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Mountfile not found' ]
}

@test "run_mountfile: datadir does not exist" {
  run ./_test.sh run_mountfile ${input_dir}/Mountfile.simple doesntexist
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = 'Data dir not found' ]
}

@test "run_mountfile: mount (simple)" {
  # setup
  mountfile="Mountfile.simple"
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp ${input_dir}/${mountfile} ${tmpdir}

  # run test
  run ./_test.sh run_mountfile ${tmpdir}/${mountfile} ${tmpdir}/data
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Mounting remote path ${tmpdir}/data/content1 => ${tmpdir}/content-uploads/1" ]
  [ "${lines[1]}" = "Mounting remote path ${tmpdir}/data/content2 => ${tmpdir}/content-uploads/2" ]
  [ "${lines[2]}" = '' ]

  # check dirs exist
  [ -e "${tmpdir}/data/content1" ]
  [ -e "${tmpdir}/data/content2" ]
  [ -L "${tmpdir}/content-uploads/1" ]
  [ -L "${tmpdir}/content-uploads/2" ]

  # check ownership
  [ $(stat -c %u "${tmpdir}/data/content1") == "48" ]
  [ $(stat -c %g "${tmpdir}/data/content1") == "48" ]

  # cleanup
  [[ $EUID -eq 0 ]] && rm -rf "${tmpdir}" || sudo rm -rf "${tmpdir}"
}

@test "run_mountfile: mount (corner cases)" {
  # setup
  mountfile="Mountfile.simple"
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp ${input_dir}/${mountfile} ${tmpdir}

  # templated content
  mkdir -p "${tmpdir}/content-uploads/1"
  echo "Some template file with content" > "${tmpdir}/content-uploads/1/templated.txt"
  mkdir -p "${tmpdir}/content-uploads/2"
  echo "Some template file with content" > "${tmpdir}/content-uploads/2/templated.txt"

  # existing content
  mkdir -p "${tmpdir}/data/content2"
  echo "Some existing file with content" > "${tmpdir}/data/content2/existing.txt"

  # run test
  run ./_test.sh run_mountfile ${tmpdir}/${mountfile} ${tmpdir}/data
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 0 ]

  [ "${lines[0]}" = "Copying template content ${tmpdir}/content-uploads/1 => ${tmpdir}/data/content1" ]
  [ "${lines[1]}" = "Mounting remote path ${tmpdir}/data/content1 => ${tmpdir}/content-uploads/1" ]
  [ "${lines[2]}" = "Mounting remote path ${tmpdir}/data/content2 => ${tmpdir}/content-uploads/2" ]
  [ "${lines[3]}" = '' ]

  # check template file *is* copied in
  [ -e "${tmpdir}/data/content1/templated.txt" ]
  [ -e "${tmpdir}/content-uploads/1/templated.txt" ]

  # check template file *is not* copied in
  [ ! -e "${tmpdir}/data/content2/templated.txt" ]
  [ ! -e "${tmpdir}/content-uploads/2/templated.txt" ]

  # check existing file is still there
  [ -e "${tmpdir}/data/content2/existing.txt" ]
  [ -e "${tmpdir}/content-uploads/2/existing.txt" ]

  # cleanup
  [[ $EUID -eq 0 ]] && rm -rf "${tmpdir}" || sudo rm -rf "${tmpdir}"
}

@test "run_mountfile: mount (complex)" {
  # setup
  mountfile="Mountfile.complex"
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp ${input_dir}/${mountfile} ${tmpdir}

  # run test
  run ./_test.sh run_mountfile ${tmpdir}/${mountfile} ${tmpdir}/data
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "Mounting remote path ${tmpdir}/data/media/foo => ${tmpdir}/media-uploads/foo" ]
  [ "${lines[1]}" = "Mounting remote path ${tmpdir}/data/media/bar => ${tmpdir}/media-uploads/bar" ]
  [ "${lines[2]}" = "Mounting remote path ${tmpdir}/data/content-1 => ${tmpdir}/content-uploads/1" ]
  [ "${lines[3]}" = "Mounting remote path ${tmpdir}/data/content2.example.com => ${tmpdir}/content2.example.com" ]
  grep -E '^Mounting remote path /tmp/tmp.*$' <<< "${lines[4]}"
  [ "${lines[5]}" = '' ]

  # cleanup
  [[ $EUID -eq 0 ]] && rm -rf "${tmpdir}" || sudo rm -rf "${tmpdir}"
}

@test "run_mountfile: ephemeral mounts" {
  # setup
  mountfile="Mountfile.ephemeral"
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp ${input_dir}/${mountfile} ${tmpdir}

  # run test
  run ./_test.sh run_mountfile ${tmpdir}/${mountfile} ${tmpdir}/data
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 0 ]
  grep -E '^Mounting remote path /tmp/tmp.*$' <<< "${lines[0]}"
  grep -E '^Mounting remote path /tmp/tmp.*$' <<< "${lines[1]}"
  [ "${lines[2]}" = '' ]

  # check that links are rooted in /tmp, not /tmp/data
  [ "$(dirname $(realpath "${tmpdir}/media/tmp"))" == '/tmp' ]
  [ "$(dirname $(realpath "${tmpdir}/uploads/tmp"))" == '/tmp' ]

  # cleanup
  [[ $EUID -eq 0 ]] && rm -rf "${tmpdir}" || sudo rm -rf "${tmpdir}"
}

@test "run_mountfile: target outside working" {
  # setup
  mountfile="${input_dir}/Mountfile.outsideworking"
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"

  # run test
  run ./_test.sh run_mountfile ${mountfile} "${tmpdir}/data"
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 129 ]
  [ "${lines[0]}" = 'Error: Target outside working directory!' ]
  [ "${lines[1]}" = '' ]
}

@test "run_mountfile: source outside data" {
  # setup
  mountfile="Mountfile.outsidedata"
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp ${input_dir}/${mountfile} ${tmpdir}

  # run test
  run ./_test.sh run_mountfile ${tmpdir}/${mountfile} "${tmpdir}/data"
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 129 ]
  [ "${lines[0]}" = 'Error: Source not within data directory!' ]
  [ "${lines[1]}" = '' ]

  # cleanup
  [[ $EUID -eq 0 ]] && rm -rf "${tmpdir}" || sudo rm -rf "${tmpdir}"
}

@test "run_mountfile: re-mounting" {
  # setup
  mountfile="Mountfile.simple"
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp ${input_dir}/${mountfile} ${tmpdir}

  # run test
  run ./_test.sh run_mountfile ${tmpdir}/${mountfile} ${tmpdir}/data
  # remount
  run ./_test.sh run_mountfile ${tmpdir}/${mountfile} ${tmpdir}/data
  echo "output = ${output}" # log output on test failure
  [ "$status" -eq 0 ]

  [ "${lines[0]}" = "Mounting remote path ${tmpdir}/data/content1 => ${tmpdir}/content-uploads/1" ]
  [ "${lines[1]}" = "Mounting remote path ${tmpdir}/data/content2 => ${tmpdir}/content-uploads/2" ]
  [ "${lines[2]}" = '' ]

  # check mount source is not a link
  [ ! -L "${tmpdir}/data/content1" ]
  [ ! -L "${tmpdir}/data/content2" ]

  # check mount target is a link
  [ -L "${tmpdir}/content-uploads/1" ]
  [ -L "${tmpdir}/content-uploads/2" ]

  # cleanup
  [[ $EUID -eq 0 ]] && rm -rf "${tmpdir}" || sudo rm -rf "${tmpdir}"
}
