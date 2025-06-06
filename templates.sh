#!/usr/bin/env bash

FATLINE_TEMPLATE_SOURCE="${FATLINE_TEMPLATE_SOURCE:-gh:jfhbrook/fatline}"

function template-package {
  local template
  local name

  template="${1:?}"
  name="${2:?}"

  cookiecutter \
    --no-input \
    -o packages "${FATLINE_TEMPLATE_SOURCE}" \
    --directory "./packages/${template}" \
    "package_name=${name}"
}

function download-package {
  local name

  name="${1:-}"

  log-info "Downloading package ${name}..."
  template-package "${name}" "${name}"
}

function new-package {
  local name

  name="${1:-}"

  template-package _new "${name}"
}

function download-missing-packages {
  for package in "${TO_INSTALL[@]}"; do
    if [ ! -d "./packages/${package}" ]; then
      download-package "${package}"
    fi
  done
}
