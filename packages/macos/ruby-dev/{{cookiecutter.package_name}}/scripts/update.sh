#!/usr/bin/env bash

RUBY_VERSION="$(rbenv install -l | grep -E '^3\.' | tail -n 1)"
INSTALLED_VERSION="$(rbenv version | cut -d' ' -f 1)"

if [ -z "$(echo "${RUBY_VERSION}" | grep "${INSTALLED_VERSION}")" ]; then
  rbenv install "${RUBY_VERSION}"
  rbenv global "${RUBY_VERSION}"
fi
