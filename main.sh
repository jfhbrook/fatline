#!/usr/bin/env bash

function main {
  log-info 'Yes this is fatline'
  log-debug 'It worked if it ends with ok'

  init-state "$@"
  log-plan

  init-homebrew-state
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

  log-info 'ok'
}

main "$@"
