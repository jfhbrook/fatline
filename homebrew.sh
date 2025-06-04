#!/usr/bin/env bash

HOMEBREW_FORMULAS_TO_INSTALL=()
HOMEBREW_CASKS_TO_INSTALL=()
HOMEBREW_FORMULAS_TO_REMOVE=()
HOMEBREW_CASKS_TO_REMOVE=()

function init-homebrew-state {
  #
  # Initialize homebrew state
  #

  for package in "${TO_INSTALL[@]}"; do
    init-homebrew-package-state install "${package}"
  done

  for package in "${TO_REMOVE[@]}"; do
    init-homebrew-package-state remove "${package}"
  done

  cleanup-homebrew-env
}

function init-homebrew-package-state {
  #
  # Init homebrew state for a command and package
  #

  local cmd
  local package
  local formulas_var
  local casks_var
  local yml_path
  local src
  local formulas
  local casks

  cmd="${1}"
  package="${2}"

  case "${cmd}" in
    install)
      formulas_var='HOMEBREW_FORMULAS_TO_INSTALL'
      casks_var='HOMEBREW_CASKS_TO_INSTALL'
      ;;
    remove)
      formulas_var='HOMEBREW_FORMULAS_TO_REMOVE'
      casks_var='HOMEBREW_CASKS_TO_REMOVE'
      ;;
    *)
      die "Command ${cmd} unsupported by homebrew"
      ;;
  esac

  yml_path="./packages/${package}/package.yml"
  src=''
  formulas="$(yq -r '.formulas[]' "${yml_path}")"
  casks="$(yq -r '.casks[]' "${yml_path}")"

  if [ -n "${formulas}" ]; then
    src="${formulas_var}+=(
${formulas}
)
"
  fi

  if [ -n "${casks}" ]; then
    src="${src}${casks_var}+=(
${casks}
)"
  fi

  eval "${src}"
}

function cleanup-homebrew-env {
  #
  # Sort and deduplicate homebrew formulas and casks
  #

  # TODO: These leave an empty element in each array - yuck

  mapfile -t HOMEBREW_FORMULAS_TO_INSTALL < <(printf '%s\n' "${HOMEBREW_FORMULAS_TO_INSTALL[@]-}" | sort -u)
  mapfile -t HOMEBREW_CASKS_TO_INSTALL < <(printf '%s\n' "${HOMEBREW_CASKS_TO_INSTALL[@]-}" | sort -u)
  mapfile -t HOMEBREW_FORMULAS_TO_REMOVE < <(printf '%s\n' "${HOMEBREW_FORMULAS_TO_REMOVE[@]-}" | sort -u)
  mapfile -t HOMEBREW_CASKS_TO_REMOVE < <(printf '%s\n' "${HOMEBREW_CASKS_TO_REMOVE[@]-}" | sort -u)
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


function install-homebrew {
  #
  # Install homebrew packages
  #

  for formula in "${HOMEBREW_FORMULAS_TO_INSTALL[@]}"; do
    if [ -n "${formula}" ]; then
      install-homebrew-formula "${formula}"
    fi
  done

  for cask in "${HOMEBREW_CASKS_TO_INSTALL[@]}"; do
    if [ -n "${cask}" ]; then
      install-homebrew-cask "${cask}"
    fi
  done
}

function update-homebrew {
  #
  # Run homebrew updates
  #

  if ! test-lifecycle 'update'; then
    return
  fi

  set -x
  brew upgrade
  set +x
}

function remove-homebrew {
  #
  # Remove homebrew packages
  #

  for formula in "${HOMEBREW_FORMULAS_TO_REMOVE[@]}"; do
    if [ -n "${formula}" ]; then
      remove-homebrew-formula "${formula}"
    fi
  done

  for cask in "${HOMEBREW_CASKS_TO_REMOVE[@]}"; do
    if [ -n "${cask}" ]; then
      remove-homebrew-cask "${cask}"
    fi
  done
}
