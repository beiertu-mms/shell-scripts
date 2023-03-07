#!/usr/bin/env bash
#===============================================================================
# Create symbolic links for all execuable files found in the given directory.
#
# Requirements: -
#===============================================================================

set -o noclobber # Avoid overlay files (echo "hi" > foo)
set -o errexit   # Used to exit upon error, avoiding cascading errors
set -o pipefail  # Unveils hidden failures
# set -o nounset   # Exposes unset variables

#--- FUNCTION: print_usage -----------------------------------------------------
# DESCRIPTION: print usage information
#-------------------------------------------------------------------------------
function print_usage() {
  cat <<EOF
Usage: template [OPTION]
Print predefined template to use in bash scripts.

Options:
  -p, --path    The absolute path to the scripts folder. Default: \$HOME/data/github.com/beiertu-mms/shell-scripts/scripts/
  -t, --target  The absolute path to the target folder. Default: \$HOME/.local/bin/
  -h, --help    Show this help message and exit
EOF
}

#---  SCRIPT LOGIC  ------------------------------------------------------------
scripts_folder="$HOME/data/github.com/beiertu-mms/shell-scripts/scripts/"
target_folder="$HOME/.local/bin/"

while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do
  case $1 in
  -h | --help)
    print_usage
    exit
    ;;
  -p | --path)
    shift
    scripts_folder=$1
    ;;
  -t | --target)
    shift
    target_folder=$1
    ;;
  *)
    echo -e "Unknown option $1\nUse -h or --help to see all available options"
    exit 1
    ;;
  esac
  shift
done
if [[ "$1" == '--' ]]; then shift; fi

find "$scripts_folder" -type f -executable -name '*.sh' -print0 |
  while IFS= read -r -d '' file; do
    link_name="${target_folder%/}/${file#"$scripts_folder"}"

    echo -e "create sym-link\n     target: $file\n  link name: ${link_name%.sh}\n"
    ln -sf "$file" "${link_name%.sh}"
  done
