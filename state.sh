#!/usr/bin/env bash

COMMAND="${COMMAND:-}"
PACKAGE="${PACKAGE:-}"
FORCE=''

DESIRED=()
TO_INSTALL=()
TO_UPDATE=()
TO_REMOVE=()

function ensure-manifest {
  #
  # Ensure manifest exists
  #

  if [ ! -f fatline.yml ]; then
    echo 'packages: []' > fatline.yml
  fi
}

function ensure-installed-txt {
  #
  # Ensure state exists
  #

  if [ ! -f .installed.txt ]; then
    touch .installed.txt
  fi
}

function is-installed {
  #
  # Check if a package is marked as installed
  #

  grep -q "${1}" .installed.txt
}

function load-package-desired-env {
  if [[ "${COMMAND}" != remove ]]; then
    DESIRED=( "${PACKAGE}" )
  fi
}

function print-desired {
  yq -r '.packages[]' fatline.yml
}

function load-desired-env {
  #
  # Load desired packages into the environment
  #

  if [ -n "${PACKAGE}" ]; then
    load-package-desired-env
    return
  fi

  eval "DESIRED=(
    $(print-desired | sed 's/^/  /')
  )"
}

function write-desired-txt {
  #
  # Write the desired packages file
  #

  printf "%s\n" "${DESIRED[@]}" > .desired.txt
}

function is-desired {
  #
  # Check if a package is marked as desired
  #

  grep -q "${1}" .desired.txt
}

function cleanup-desired-txt {
  #
  # Clean up the desired packages file
  #

  rm -f .desired.txt
}

function load-package-to-install-env {
  #
  # Load an individual package to TO_INSTALL
  #

  if [[ "${COMMAND}" == install ]]; then
    if [ -z "${FORCE}" ] && is-installed "${PACKAGE}"; then
      log-error "${PACKAGE} is already installed"
      cleanup-desired-txt
      exit 1
    fi
    TO_INSTALL=( "${PACKAGE}" )
  else
    TO_INSTALL=()
  fi
}

function load-to-install-env {
  #
  # Load packages to TO_INSTALL
  #

  if [ -n "${PACKAGE}" ]; then
    load-package-to-install-env
  else
    # shellcheck disable=SC2034
    mapfile -t TO_INSTALL < <(comm -23 .desired.txt .installed.txt)
  fi
}

function load-package-to-update-env {
  #
  # Load an individual package to TO_UPDATE
  #

  if [[ "${COMMAND}" == update ]]; then
    [ -z "${FORCE}" ] || echo 'forced'
    if [ -z "${FORCE}" ] && ! is-installed "${PACKAGE}"; then
      log-error "${PACKAGE} is not installed"
      cleanup-desired-txt
      exit 1
    fi
    TO_UPDATE=( "${PACKAGE}" )
  else
    TO_UPDATE=()
  fi
}

function load-to-update-env {
  #
  # Load packages to TO_UPDATE
  #

  if [ -n "${PACKAGE}" ]; then
    load-package-to-update-env
  else
    # shellcheck disable=SC2034
    mapfile -t TO_UPDATE < <(comm -12 .desired.txt .installed.txt)
  fi
}


function load-package-to-remove-env {
  #
  # Load an individual package to TO_REMOVE
  #

  if [[ "${COMMAND}" == remove ]]; then
    if [ -z "${FORCE}" ] && ! is-installed "${PACKAGE}"; then
      log-error "${PACKAGE} is already removed"
      cleanup-desired-txt
      exit 1
    fi
    TO_REMOVE=( "${PACKAGE}" )
  else
    TO_REMOVE=()
  fi
}

function load-to-remove-env {
  #
  # Load packages to TO_REMOVE
  #

  if [ -n "${PACKAGE}" ]; then
    load-package-to-remove-env
  else
    # shellcheck disable=SC2034
    mapfile -t TO_REMOVE < <(comm -13 .desired.txt .installed.txt)
  fi
}

function test-lifecycle {
  #
  # Check if a command lifecycle should be run
  #

  if [ -z "${COMMAND}" ]; then
    return 0
  elif [[ "${COMMAND}" == "${1}" ]]; then
    return 0
  else
    return 1
  fi
}

function init-state {
  ensure-manifest
  ensure-installed-txt

  load-desired-env

  write-desired-txt

  load-to-install-env
  load-to-update-env
  load-to-remove-env
  cleanup-desired-txt
}

function print-installed {
  printf "%s\n" "${TO_INSTALL[@]}" | (grep -v '^$' || true)
}

function write-removed {
  printf "%s\n" "${TO_REMOVE[@]}" | (grep -v '^$' || true) > .removed.txt
}

function cleanup-removed {
  rm -f .removed.txt
}

function save-installed {
  # Delete removed dependencies
  comm -13 .removed.txt .installed.txt > .installed.stage.txt

  # Add installed dependencies
  print-installed >> .installed.stage.txt

  # Write unique installed to file
  sort -u > .installed.txt < .installed.stage.txt

  # Clean up
  rm -f .installed.stage.txt
}

function save-manifest {
  # Start with existing manifest packages
  print-desired > .manifest.stage.txt

  # Add installed packages
  print-installed >> .manifest.stage.txt

  comm -13 .removed.txt .manifest.stage.txt \
    | sort -u \
    | jq -Rn 'inputs' \
    > .manifest.stage.json

  rm -f .manifest.stage.txt

  yq '.' fatline.yml -o json \
    | jq \
      --slurpfile packages .manifest.stage.json \
      '.packages = $packages' \
    | yq -P . \
    > fatline.new.yml

  # Clean up staged manifest
  rm -f .manifest.stage.json

  # Promote new fatline file
  mv fatline.new.yml fatline.yml
}

function save-state {
  log-info 'Saving state...'
  log-debug 'Writing .removed.txt...'
  write-removed
  log-debug 'Updating installed packages...'
  save-installed
  log-debug 'Saving fatline.yml...'
  save-manifest
  log-debug 'Cleaning up .removed.txt...'
  cleanup-removed
  log-info 'State saved.'
}
