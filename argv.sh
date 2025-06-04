#!/usr/bin/env bash

COMMAND="${COMMAND:-}"
PACKAGE="${PACKAGE:-}"
FORCE=''

function parse-argv {
  #
  # Parse CLI arguments
  #

  while [[ $# -gt 0 ]]; do
    case "${1}" in
      --force)
        # shellcheck disable=SC2034
        FORCE=1
        shift
        ;;
      *)
        if [ -z "${COMMAND}" ]; then
          COMMAND="${1}"
        elif [ -z "${PACKAGE}" ]; then
          PACKAGE="${1}"
        else
          die "Unknown argument ${1}"
        fi
        shift
        ;;
    esac
  done
}
