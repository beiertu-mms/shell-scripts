#!/usr/bin/env bash

set -o errexit # Exit when a command fails
# Use || true if a command is allowed to fail
set -o nounset  # Treat unset variables as an error
set -o pipefail # Exit when a command in a pipeline fails

main() {
  local -r wireless_interface=$(ip link show | grep 'wlp' | awk '{print $2}' | sed 's/://')
  local -r wpa_name="${1:-tbe-at-home}"

  echo "Stop ${wireless_interface}"
  doas ip link set "$wireless_interface" down

  echo "Start ${wpa_name}"
  doas netctl start "$wpa_name"
}

#---  SCRIPT LOGIC  ------------------------------------------------------------
main "$@"
