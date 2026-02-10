#!/usr/bin/env bash

function create-new {
  log-info "Creating new package ${PACKAGE}..."
  new-package "${PACKAGE}"
}

function run-workflow {
  init-state
  download-missing-packages
  init-dnf-state

  log-plan
  log-dnf-plan

  run-lifecycle remove
  remove-dnf

  update-fedora
  update-dnf
  run-lifecycle update

  install-dnf
  run-lifecycle install

  save-state
}

function main {
  log-info 'Yes this is fatline'
  log-debug 'It worked if it ends with ok'

  parse-argv "$@"

  case "${COMMAND}" in
    new)
      create-new
      ;;
    *)
      run-workflow
      ;;
  esac

  log-info 'ok'
}

main "$@"
