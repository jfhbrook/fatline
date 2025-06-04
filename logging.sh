#!/usr/bin/env bash

COLOR_RED='\e[0;31m'
COLOR_YELLOW='\e[0;33m'
COLOR_GREEN='\e[0;32m'
COLOR_MAGENTA='\e[0;35m'
COLOR_RESET='\e[0m'

FATLINE_LOG_LEVEL="${FATLINE_LOG_LEVEL:-INFO}"
DEBUG="${DEBUG:-}"

function is-debug {
  [[ "${FATLINE_LOG_LEVEL}" == 'DEBUG' ]] || [ -n "${DEBUG}" ]
}

function is-info {
  [[ "${FATLINE_LOG_LEVEL}" == 'INFO' ]] || is-debug
}

function is-warn {
  [[ "${FATLINE_LOG_LEVEL}" == 'WARN' ]] || is-info
}

function log-debug {
  if is-debug; then
    echo -e "${COLOR_MAGENTA}DEBUG${COLOR_RESET}:" "$@" 1>&2
  fi
}

function log-info {
  if is-info; then
    echo -e "${COLOR_GREEN}INFO${COLOR_RESET}:" "$@" 1>&2
  fi
}

function log-warn {
  if is-warn; then
    echo -e "${COLOR_YELLOW}WARN${COLOR_RESET}:" "$@" 1>&2
  fi
}

function log-error {
  echo -e "${COLOR_RED}ERROR${COLOR_RESET}:" "$@" 1>&2
}

function die {
  log-error "$@"
  exit 1
}
