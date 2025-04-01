#!/usr/bin/env bash
#===============================================================================
# Make Caps_Lock a second Escape.
# Make Delete an additional Insert.
#
# Requirements: xmodmap
# Note: Use xev to find the keysym name of the key pressed.
#===============================================================================

set -o noclobber # Avoid overlay files (echo "hi" > foo)
set -o errexit   # Used to exit upon error, avoiding cascading errors
set -o pipefail  # Unveils hidden failures
set -o nounset   # Exposes unset variables

key_configs=(
  "clear lock"
  "keysym Caps_Lock = Escape"
  "keysym Delete = Insert"
)

for config in "${key_configs[@]}"; do
  xmodmap -e "$config"
done
