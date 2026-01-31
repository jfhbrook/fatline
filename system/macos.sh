#!/usr/bin/env bash

function update-macos {
  #
  # Run MacOS OS updates
  #

  if ! test-lifecycle 'update'; then
    return
  fi

  set -x
  sudo softwareupdate -i -a
  set +x
}

function update-macos-software {
  #
  # Run MacOS software updates
  #

  if ! test-lifecycle 'update'; then
    return
  fi

  set -x
  mas upgrade
  set +x
}
