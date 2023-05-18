#!/usr/bin/env bash
set -o errexit # Exit when a command fails
# Use || true if a command is allowed to fail
set -o nounset  # Treat unset variables as an error
set -o pipefail # Exit when a command in a pipeline fails

main() {
  local -r selected=$(archlinux-java status | grep -v 'default' | sed '1d' | awk '{$1=$1};1' | fzf)
  if [[ -z "$selected" || "$selected" =~ default ]]; then
    exit 0
  fi

  doas archlinux-java set "$selected"
  pkill -RTMIN+12 dwmblocks
}

main
