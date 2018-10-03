#!/usr/bin/env bats

source ../functions/10-common.sh
source ../functions/run_mountfile.sh

@test "run_mountfile: mountfile does not exist" {
  run run_mountfile Mountfile.doesntexist
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Mountfile not found' ]
}

@test "run_mountfile: datadir does not exist" {
  run run_mountfile Mountfile doesntexist
  [ "$status" -eq 1 ]
  [ "${lines[0]}" = 'Datadir not found' ]
}

@test "run_mountfile: mount (simple)" {
  # setup
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp Mountfile ${tmpdir}

  # run test
  run run_mountfile ${tmpdir}/Mountfile ${tmpdir}/data
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Mounting remote path content1 => content-uploads/1' ]
  [ "${lines[1]}" = 'Mounting remote path content2 => content-uploads/2' ]

  # check dirs exist
  [ -e "${tmpdir}/data/content1" ]
  [ -e "${tmpdir}/data/content2" ]
  [ -L "${tmpdir}/content-uploads/1" ]
  [ -L "${tmpdir}/content-uploads/2" ]

  # check ownership
  [ $(stat -c %u "${tmpdir}/data/content1") == "48" ]
  [ $(stat -c %g "${tmpdir}/data/content1") == "48" ]

  # cleanup
  rm -rf "${tmpdir}"
}

@test "run_mountfile: mount (corner cases)" {
  # setup
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp Mountfile ${tmpdir}

  # existing content
  mkdir -p "${tmpdir}/data/content2"
  echo "Some existing file with content" > "${tmpdir}/data/content2/existing.txt"

  # templated content
  mkdir -p "${tmpdir}/content-uploads/1" "${tmpdir}/content-uploads/2"
  echo "Some template file with content" > "${tmpdir}/content-uploads/1/templated.txt"
  mkdir -p "${tmpdir}/content-uploads/2"
  echo "Some template file with content" > "${tmpdir}/content-uploads/2/templated.txt"

  # run test
  run run_mountfile ${tmpdir}/Mountfile ${tmpdir}/data
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Mounting remote path content1 => content-uploads/1' ]
  [ "${lines[1]}" = 'Mounting remote path content2 => content-uploads/2' ]

  # check existing file is still there
  [ -e "${tmpdir}/data/content2/existing.txt" ]
  [ -e "${tmpdir}/content-uploads/2/existing.txt" ]

  # check template file *is* copied in
  [ ! -e "${tmpdir}/data/content1/templated.txt" ]
  [ ! -e "${tmpdir}/content-uploads/1/templated.txt" ]

  # check template file *is not* copied in
  [ ! -e "${tmpdir}/data/content2/templated.txt" ]
  [ ! -e "${tmpdir}/content-uploads/2/templated.txt" ]

  # cleanup
  rm -rf "${tmpdir}"
}

@test "run_mountfile: mount (complex)" {
  # setup
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp Mountfile.complex ${tmpdir}

  # run test
  run run_mountfile ${tmpdir}/Mountfile.complex ${tmpdir}/data
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Mounting remote path media/foo => media-uploads/foo' ]
  [ "${lines[1]}" = 'Mounting remote path media/bar => media-uploads/bar' ]
  [ "${lines[2]}" = 'Mounting remote path content1 => content-uploads/1' ]
  [ "${lines[3]}" = 'Mounting remote path content2.example.com => content2.example.com' ]
  [ "${lines[4]}" = 'Mounting remote path ephemeral => uploads/tmp' ]

  # cleanup
  rm -rf "${tmpdir}"
}

@test "run_mountfile: ephemeral mounts" {
  # setup
  tmpdir=$(mktemp -d)
  mkdir -p "${tmpdir}/data"
  cp Mountfile.ephemeral ${tmpdir}

  # run test
  run run_mountfile ${tmpdir}/Mountfile.ephemeral ${tmpdir}/data
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = 'Mounting remote path ephemeral => media/tmp' ]
  [ "${lines[1]}" = 'Mounting remote path ephemeral => uploads/tmp' ]

  # check that links are rooted in /tmp, not /tmp/data
  [ "$(dirname $(readlink -f "${tmpdir}/media/tmp"))" == '/tmp' ]
  [ "$(dirname $(readlink -f "${tmpdir}/uploads/tmp"))" == '/tmp' ]

  # cleanup
  rm -rf "${tmpdir}"
}
