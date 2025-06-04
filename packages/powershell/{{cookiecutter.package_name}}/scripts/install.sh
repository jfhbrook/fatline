#!/usr/bin/env bash

pwsh -c 'Set-PSRepository -Name PSGallery -InstallationPolicy Trusted'
pwsh -c 'Install-Module Microsoft.PowerShell.PSResourceGet -Repository PSGallery -Force -AllowClobber'
pwsh -c 'Set-PSResourceRepository -Name PSGallery -Trusted'

source ./modules.sh

for module in "${POWERSHELL_MODULES[@]}"; do
  pwsh -c "Install-Module ${module}"
done
