#!/usr/bin/env bash

DNF_PACKAGES_TO_INSTALL=()
DNF_PACKAGES_TO_REMOVE=()

function init-homebrew-state {
  #
  # Initialize homebrew state
  #

  for package in "${TO_INSTALL[@]}"; do
    init-dnf-package-state install "${package}"
  done

  for package in "${TO_REMOVE[@]}"; do
    init-dnf-package-state remove "${package}"
  done

  cleanup-dnf-env
}

function init-dnf-package-state {
  #
  # Init dnf state for a command and package
  #

  local cmd
  local package
  local packages_var
  local yml_path
  local src
  local packages

  cmd="${1}"
  package="${2}"

  case "${cmd}" in
    install)
      packages_var='DNF_PACKAGES_TO_INSTALL'
      ;;
    remove)
      packages_var='DNF_PACKAGES_TO_REMOVE'
      ;;
    *)
      die "Command ${cmd} unsupported by dnf"
      ;;
  esac

  yml_path="./${FATLINE_PACKAGE_DIR:?}/${package}/package.yml"
  src=''
  packages="$(yq -r '.packages[]' "${yml_path}")"

  if [ -n "${packages}" ]; then
    src="${packages_var}+=(
${packages}
)
"
  fi

  eval "${src}"
}

function cleanup-dnf-env {
  #
  # Sort and deduplicate dnf packages
  #

  # TODO: These leave an empty element in each array - yuck

  mapfile -t DNF_PACKAGES_TO_INSTALL < <(printf '%s\n' "${HOMEBREW_FORMULAS_TO_INSTALL[@]-}" | sort -u)
  mapfile -t DNF_PACKAGES_TO_REMOVE < <(printf '%s\n' "${HOMEBREW_FORMULAS_TO_REMOVE[@]-}" | sort -u)
}

function install-dnf-package {
  #
  # Install a dnf package
  #

  local package

  package="${1}"

  if [ -z "${FORCE}" ]; then
    set -x
    sudo dnf install -y "${package}"
    set +x
  else
    set -x
    dnf list installed "${package}" &>/dev/null || sudo dnf install -y "${package}"
    set +x
  fi
}

function remove-dnf-package {
  #
  # Remove a dnf package
  #

  local package

  package="${1}"

  if [ -z "${FORCE}" ]; then
    set -x
    sudo dnf remove "${package}"
    set +x
  else
    set -x
    dnf list packages "${package}" &>/dev/null && sudo dnf remove "${package}"
    set +x
  fi
}

function install-dnf {
  #
  # Install dnf packages
  #

  for package in "${DNF_PACKAGES_TO_INSTALL[@]}"; do
    if [ -n "${package}" ]; then
      install-dnf-package "${package}"
    fi
  done
}

function update-dnf {
  #
  # Run homebrew updates
  #

  if ! test-lifecycle 'update'; then
    return
  fi

  set -x
  sudo dnf update -y
  set +x
}

function remove-dnf {
  #
  # Remove dnf packages
  #

  for package in "${DNF_PACKAGES_TO_REMOVE[@]}"; do
    if [ -n "${package}" ]; then
      remove-dnf-package "${package}"
    fi
  done
}
