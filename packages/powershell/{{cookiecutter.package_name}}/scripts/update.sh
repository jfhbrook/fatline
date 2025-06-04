#!/usr/bin/env bash

source ./modules.sh

for module in "${POWERSHELL_MODULES[@]}"; do
  pwsh -c "Update-Module ${module}"
done
