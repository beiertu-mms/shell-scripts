#!/usr/bin/env bash
#===============================================================================
# A script to re-initialize git hooks for all repositories
# found in the current or given directory.
#
# Requirements: fd
#===============================================================================

set -o noclobber # Avoid overlay files (echo "hi" > foo)
set -o errexit   # Used to exit upon error, avoiding cascading errors
set -o pipefail  # Unveils hidden failures
set -o nounset   # Exposes unset variables

#--- FUNCTION: main ------------------------------------------------------------
# DESCRIPTION: re-init git repos found in the current directory or
#              the given directory in the first argument ($1).
#-------------------------------------------------------------------------------
function main() {
  for dir in $(fd -t d -H '^\.git$' "${1:-.}"); do
    (
      cd "${dir%.git/}"
      rm -f ./.git/hooks/*
      git init
    )
  done
}

#---  SCRIPT LOGIC  ------------------------------------------------------------
main "$@"
