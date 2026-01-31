#!/usr/bin/env bash

set -euo pipefail

mkdir -p ~/.local/bin

if [ ! -f ~/.local/bin/slowpoke ]; then
  echo "#!/usr/bin/env bash
cd '$(pwd)' && exec just "'"$@"' \
    > ~/.local/bin/${SLOWPOKE_BIN}
  chmod +x ~/.local/bin/${SLOWPOKE_BIN}
fi
