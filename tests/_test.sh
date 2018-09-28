#!/usr/bin/env bash
# Wrapper script to source and run bash functions for test

# Sets bash strict mode to run test
if [[ "${BATS_STRICT}" =~ true|True|TRUE|yes|Yes|YES ]]; then
  set -euo pipefail
  IFS=$'\n\t'
fi

# Load in the common functions
# shellcheck disable=SC1091
source ../functions/10-common.sh

# Load in the function we want to test
# shellcheck source=/dev/null
source "../functions/${1}.sh"

# Runs the function with sudo
if [[ "${BATS_SUDO:-}" =~ true|True|TRUE|yes|Yes|YES ]]; then
  sudo "${@}"
else
  "${@}"
fi
