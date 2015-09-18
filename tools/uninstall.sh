#!/bin/bash
#
# uninstall.sh

BINDIR="/usr/bin"
DATADIR="/usr/share/arkmanager"
LIBEXECDIR="/usr/libexec/arkmanager"
INITSCRIPT=

if [ -f "/etc/rc.d/init.d/arkmanager" ]; then
  INITSCRIPT="/etc/rc.d/init.d/arkmanager"
  if [ -f "/etc/rc.d/init.d/functions" ]; then
    chkconfig arkmanager off
  fi
elif [ -f "/etc/init.d/arkmanager" ]; then
  INITSCRIPT="/etc/init.d/arkmanager"
  if [ -f "/lib/lsb/init-functions" ]; then
    update-rc.d -f arkmanager remove
  elif [ -f "/sbin/runscript" ]; then
    rc-update del arkmanager default
  fi
elif [ -f "/etc/systemd/system/arkmanager.service" ]; then
  INITSCRIPT="/etc/systemd/system/arkmanager.service"
  systemctl disable arkmanager.service
fi

if [ -n "$INITSCRIPT" ]; then
  for f in "${INITSCRIPT}" \
           "${BINDIR}/arkmanager" \
           "${LIBEXECDIR}/arkmanager.init" \
           "${LIBEXECDIR}/arkmanager-uninstall.sh"
  do
    if [ -f "$f" ]; then
      rm "$f"
    fi
  done
fi
