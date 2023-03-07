#!/usr/bin/env bash
#===============================================================================
# A template for a shell script.
# Helpful link: https://devhints.io/bash
#
# Requirements: -
#===============================================================================

set -o noclobber # Avoid overlay files (echo "hi" > foo)
set -o errexit   # Used to exit upon error, avoiding cascading errors
set -o pipefail  # Unveils hidden failures
set -o nounset   # Exposes unset variables

#--- FUNCTION: print_usage -----------------------------------------------------
# DESCRIPTION: print usage information
#-------------------------------------------------------------------------------
function print_usage() {
  cat <<EOF
Usage: template [OPTION]
Print predefined template to use in bash scripts.

Options:
  -h, --help    Show this help message and exit
EOF
}

#--- FUNCTION: hello -----------------------------------------------------------
# DESCRIPTION: print hello + $1
#-------------------------------------------------------------------------------
function hello() {
  echo "hello $1"
}

#---  SCRIPT LOGIC  ------------------------------------------------------------
while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do
  case $1 in
  -h | --help)
    print_usage
    exit
    ;;
  -n | --name)
    shift
    hello "$1"
    ;;
  *)
    echo -e "Unknown option $1\nUse -h or --help to see all available options"
    exit 1
    ;;
  esac
  shift
done
if [[ "$1" == '--' ]]; then shift; fi
