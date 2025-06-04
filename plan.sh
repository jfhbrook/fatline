#!/usr/bin/env bash

function log-plan {
  if [[ ${#TO_INSTALL[@]} -gt 0 ]]; then
    log-debug "Install: ${TO_INSTALL[*]}"
  else
    log-debug 'No packages to install'
  fi

  if [[ ${#TO_UPDATE[@]} -gt 0 ]]; then
    log-debug "Update: ${TO_UPDATE[*]}"
  else
    log-debug 'No packages to update'
  fi

  if [[ ${#TO_REMOVE[@]} -gt 0 ]]; then
    log-debug "Remove: ${TO_REMOVE[*]}"
  else
    log-debug 'No packages to remove'
  fi
}

function log-homebrew-plan {
  local formulas_to_install
  local formulas_to_remove
  local casks_to_install
  local casks_to_remove

  formulas_to_install="${HOMEBREW_FORMULAS_TO_INSTALL}"
  casks_to_install="${HOMEBREW_CASKS_TO_INSTALL}"
  formulas_to_remove="${HOMEBREW_FORMULAS_TO_REMOVE}"
  casks_to_remove="${HOMEBREW_CASKS_TO_REMOVE}"

  if [ -n "${formulas_to_install}" ]; then
    log-debug "installing formulas: ${formulas_to_install}"
  else
    log-debug 'No formulas to install'
  fi

  if [ -n "${casks_to_install}" ]; then
    log-debug "installing casks: ${casks_to_install}"
  else
    log-debug 'No casks to install'
  fi

  if [ -n "${formulas_to_remove}" ]; then
    log-debug "removing formulas: ${formulas_to_install}"
  else
    log-debug 'No formulas to remove'
  fi

  if [ -n "${casks_to_remove}" ]; then
    log-debug "removing casks: ${casks_to_install}"
  else
    log-debug 'No casks to remove'
  fi
}
