#!/usr/bin/env bash

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
