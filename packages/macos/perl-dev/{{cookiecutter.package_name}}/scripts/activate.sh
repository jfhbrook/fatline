#!/usr/bin/env bash

if [ -z "${PERLBREW_HOME:-}" ]; then
  set +eu
  source ~/perl5/perlbrew/etc/bashrc
  set -eu
fi
