#!/usr/bin/env bash

if [[ "${PERLBREW_PERL:-}" != "perl-${PERLBREW_PERL_VERSION}" ]]; then
  # TODO: perl fails some tests. Is that OK?
  perlbrew install "perl-${PERLBREW_PERL_VERSION}" \
    --thread \
    --multi \
    --notest

  perlbrew switch "perl-${PERLBREW_PERL_VERSION}"

  perlbrew install-cpm
  perlbrew install-cpanm
fi
