#!/usr/bin/env bash
set -o errexit # Exit when a command fails
# Use || true if a command is allowed to fail
set -o nounset  # Treat unset variables as an error
set -o pipefail # Exit when a command in a pipeline fails

main() {
  if ! command -v v4l2-ctl &>/dev/null; then
    echo -e "${RED:-}v4l2-ctl is not installed.${NC:-}"
    exit 1
  fi

  local -r options=(
    "focus_auto=0"
    "focus_absolute=250"
    "sharpness=4"
    "brightness=10"
    "contrast=1"
    "saturation=60"
    "white_balance_temperature_auto=1"
    "backlight_compensation=1"
  )

  for option in "${options[@]}"; do
    v4l2-ctl -d0 -c "$option"
  done
}

main
