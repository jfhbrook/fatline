#!/usr/bin/env bash

function run-workflow {
  init-state
  download-missing-packages
  init-dnf-state

  log-plan
  log-dnf-plan

  run-lifecycle remove
  remove-dnf

  # update-fedora
  update-dnf
  run-lifecycle update

  install-dnf
  run-lifecycle install

  save-state
}
