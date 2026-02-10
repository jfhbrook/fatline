#!/usr/bin/env bash

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
