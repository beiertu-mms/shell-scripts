#!/usr/bin/env bash
set -o errexit # Exit when a command fails
# Use || true if a command is allowed to fail
set -o nounset  # Treat unset variables as an error
set -o pipefail # Exit when a command in a pipeline fails

main() {
  if ! command -v i3lock &>/dev/null; then
    echo -e "${RED:-}i3lock is not installed.${NC:-}"
    exit 1
  fi

  local -r BLANK='#00000000'
  local -r CLEAR='#ffffff22'
  local -r DEFAULT='#ff00ffcc'
  local -r TEXT='#ee00eeee'
  local -r WRONG='#880000bb'
  local -r VERIFYING='#bb00bbbb'

  i3lock \
    --insidever-color=$CLEAR \
    --ringver-color=$VERIFYING \
    \
    --insidewrong-color=$CLEAR \
    --ringwrong-color=$WRONG \
    \
    --inside-color=$BLANK \
    --ring-color=$DEFAULT \
    --line-color=$BLANK \
    --separator-color=$DEFAULT \
    \
    --verif-color=$TEXT \
    --wrong-color=$TEXT \
    --time-color=$TEXT \
    --date-color=$TEXT \
    --layout-color=$TEXT \
    --keyhl-color=$WRONG \
    --bshl-color=$WRONG \
    \
    --screen 1 \
    --blur 10 \
    --clock \
    --indicator \
    --time-str="%H:%M:%S" \
    --date-str="%A, %Y-%m-%d"
}

main
