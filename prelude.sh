#!/usr/bin/env bash

set -euo pipefail


#
# include: ./logging.sh
#



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
    echo 'DEBUG:' "$@" 1>&2
  fi
}

function log-info {
  if is-info; then
    echo 'INFO:' "$@" 1>&2
  fi
}

function log-warn {
  if is-warn; then
    echo 'WARN:' "$@" 1>&2
  fi
}

function log-error {
  echo 'ERROR:' "$@" 1>&2
}

function die {
  log-error "$@"
  exit 1
}


#
# include: ./init.sh
#



HOMEBREW_FORMULAS=()
HOMEBREW_CASKS=()

PACKAGE=''
FORCE=''

PRESENT=()
ABSENT=()

#
# Environment setup
#

function load-manifest-env {
  #
  # Load fatline.yml into the environment
  #

  local src
  src="PRESENT=(
    $(yq -r '.packages[]' fatline.yml | sed 's/^/  /')
  )

  ABSENT=()"

  eval "${src}"
}

function load-package-env {
  #
  # Load ./packages/${package}/package.yml into the environment
  #

  local package
  local yml_path
  local src
  local formulas
  local casks

  package="${1}"
  yml_path="./packages/${package}/package.yml"
  src=''
  formulas="$(yq -r '.formulas[]' "${yml_path}")"
  casks="$(yq -r '.casks[]' "${yml_path}")"

  if [ -n "${formulas}" ]; then
    src="HOMEBREW_FORMULAS+=(
${formulas//^/  }
)
"
  fi

  if [ -n "${casks}" ]; then
    src="${src}HOMEBREW_CASKS+=(
${casks//^/  }
)"
  fi

  eval "${src}"
}

function cleanup-homebrew-env {
  #
  # Sort and deduplicate homebrew formulas and casks
  #

  mapfile -t HOMEBREW_FORMULAS < <(printf "%s\n" "${HOMEBREW_FORMULAS[@]-}" | sort -u)
  mapfile -t HOMEBREW_CASKS < <(printf "%s\n" "${HOMEBREW_CASKS[@]-}" | sort -u)
}

function load-env {

  #
  # Load the full environment based on parsed arguments
  #

  local cmd

  cmd="${1}"

  if [ -n "${PACKAGE}" ]; then
    case "${cmd}" in
      install|update)
        PRESENT+=("${PACKAGE}")
        ;;
      remove)
        ABSENT+=("${PACKAGE}")
        ;;
    esac
  else
    load-manifest-env
  fi

  if [[ "${cmd}" == remove ]]; then
    for package in "${ABSENT[@]}"; do
      load-package-env "${package}"
    done
  else
    for package in "${PRESENT[@]}"; do
      load-package-env "${package}"
    done
  fi

  cleanup-homebrew-env
}

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
        if [ -z "${PACKAGE}" ]; then
          PACKAGE="${1}"
        else
          echo "ERROR: Unknown argument ${1}" 1>&2
          exit 1
        fi
        shift
        ;;
    esac
  done
}

function init-fatline {
  #
  # Parse command line arguments and load the environment
  #

  local cmd

  cmd="${1}"
  shift

  parse-argv "$@"
  load-env "${cmd}"
}


#
# include: ./lifecycle.sh
#



#
# Lifecycle actions
#

function package-lifecycle {
  #
  # Run a package lifecycle action
  #

  local recipe
  local package
  local justfile_path

  recipe="${1}"
  package="${2}"
  justfile_path="./packages/${package}/justfile"

  if [ ! -f "${justfile_path}" ]; then
    return
  fi

  if [[ "$(just -f "${justfile_path}" --dump --dump-format json | jq ".recipes.${recipe}")" == 'null' ]]; then
    return
  fi

  set -x

  just -f "${justfile_path}" "${recipe}"

  set +x
}

function run-lifecycle {
  #
  # Run lifecycle hooks for all packages
  #

  local cmd

  cmd="${1}"

  if [[ "${cmd}" == remove ]]; then
    for package in "${ABSENT[@]}"; do
      package-lifecycle "${cmd}" "${package}"
    done
    return
  fi

  for package in "${PRESENT[@]}"; do
    package-lifecycle "${cmd}" "${package}"
  done
}


#
# include: ./system.sh
#



#
# System hooks
#

function update-macos {
  #
  # Run MacOS OS updates
  #

  set -x
  sudo softwareupdate -i -a
  set +x
}

function update-macos-software {
  #
  # Run MacOS software updates
  #

  set -x
  mas upgrade
  set +x
}


#
# include: ./homebrew.sh
#



#
# Homebrew hooks
#

function foreach-homebrew-formula {
  #
  # Run a function for each homebrew formula
  #

  local callback
  callback="${1}"

  if [ -n "${HOMEBREW_FORMULAS:-}" ]; then
    for formula in "${HOMEBREW_FORMULAS[@]}"; do
      "${callback}" "${formula}"
    done
  fi
}

function foreach-homebrew-cask {
  #
  # Run a function for each homebrew cask
  #

  local callback
  callback="${1}"

  if [ -n "${HOMEBREW_CASKS:-}" ]; then
    for cask in "${HOMEBREW_CASKS[@]}"; do
      "${callback}" "${cask}"
    done
  fi
}

function install-homebrew-formula {
  #
  # Install a homebrew formula
  #

  local formula

  formula="${1}"

  if [ -z "${FORCE}" ]; then
    set -x
    brew install "${formula}"
    set +x
  else
    set -x
    brew list "${formula}" &>/dev/null || brew install "${formula}"
    set +x
  fi
}

function install-homebrew-cask {
  #
  # Install a homebrew cask
  #

  local cask

  cask="${1}"

  if [ -z "${FORCE}" ]; then
    set -x
    brew install --cask "${cask}"
    set +x
  else
    set -x
    brew list --cask "${cask}" &>/dev/null || brew install --cask "${cask}"
    set +x
  fi
}

function update-homebrew {
  #
  # Run homebrew updates
  #

  set -x
  brew upgrade
  set +x
}

function remove-homebrew-formula {
  #
  # Remove a homebrew formula
  #

  local formula

  formula="${1}"

  if [ -z "${FORCE}" ]; then
    set -x
    brew remove "${formula}"
    set +x
  else
    set -x
    brew list "${formula}" &>/dev/null && brew remove "${formula}"
    set +x
  fi
}

function remove-homebrew-cask {
  #
  # Remove a homebrew cask
  #

  local cask

  cask="${1}"

  if [ -z "${FORCE}" ]; then
    set -x
    brew remove --cask "${cask}"
    set +x
  else
    set -x
    brew list --cask "${cask}" &>/dev/null && brew remove --cask "${cask}"
    set +x
  fi
}


