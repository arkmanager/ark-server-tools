#!/bin/bash
#
# uninstall-user.sh

BINDIR="/home/steam/bin"
DATADIR="/home/steam/.local/share/arkmanager"

for f in "${BINDIR}/arkmanager" \
         "${DATADIR}/uninstall.sh"
do
  if [ -f "$f" ]; then
    rm "$f"
  fi
done
