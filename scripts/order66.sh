#!/usr/bin/env bash
set -o errexit  # Exit when a command fails
set -o nounset  # Treat unset variables as an error
set -o pipefail # Exit when a command in a pipeline fails

shutdown -h now
