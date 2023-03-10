#!/usr/bin/env bash
#===============================================================================
# Make Caps_Lock a second Escape and Pause a second Insert.
#
# Requirements: xmodmap
#===============================================================================

set -o noclobber # Avoid overlay files (echo "hi" > foo)
set -o errexit   # Used to exit upon error, avoiding cascading errors
set -o pipefail  # Unveils hidden failures
set -o nounset   # Exposes unset variables

key_configs=(
  "clear lock"
  "keysym Caps_Lock = Escape"
  "keysym Pause = Insert"
)

for config in "${key_configs[@]}"; do
  xmodmap -e "$config"
done
