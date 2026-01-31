#!/usr/bin/env bash

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

  case "${1}" in
    install)
      for package in "${TO_INSTALL[@]}"; do
        package-lifecycle install "${package}"
      done
      ;;
    update)
      for package in "${TO_UPDATE[@]}"; do
        package-lifecycle update "${package}"
      done
      ;;
    remove)
      for package in "${TO_REMOVE[@]}"; do
        package-lifecycle remove "${package}"
      done
      ;;
    *)
      die "Unknown command: ${1}"
      ;;
  esac
}
