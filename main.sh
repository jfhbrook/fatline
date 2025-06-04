#!/usr/bin/env bash

function create-new {
  log-info "Creating new package ${PACKAGE}..."
  new-package "${PACKAGE}"
}

function run-workflow {
  init-state
  init-homebrew-state

  log-plan
  log-homebrew-plan

  remove-homebrew
  run-lifecycle remove

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
