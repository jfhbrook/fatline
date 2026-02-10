#!/usr/bin/env bash

RUBY_VERSION="$(rbenv install -l | grep -E '^3\.' | tail -n 1)"

rbenv install "${RUBY_VERSION}"
rbenv global "${RUBY_VERSION}"
