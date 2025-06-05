#!/usr/bin/env bash

function create-new {
  log-info "Creating new package ${PACKAGE}..."
  new-package "${PACKAGE}"
}

function run-workflow {
  init-state
  download-missing-packages
  init-homebrew-state

  log-plan
  log-homebrew-plan

  run-lifecycle remove
  remove-homebrew

  update-macos
  update-macos-software
  update-homebrew
  run-lifecycle update

  install-homebrew
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
