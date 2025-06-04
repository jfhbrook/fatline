#!/usr/bin/env bash

set -euo pipefail

VERSION="${1}"

NOTES="$(./scripts/changelog-entry.py "${VERSION}")"

gh release create "${VERSION}" \
  -t "fatline v${VERSION}" \
  -n "${NOTES}" \
  bin/fatline
