#!/bin/bash

EXECPREFIX="${EXECPREFIX:-/usr/local}"

if [ ! -z "$1" ]; then
    # Copy arkmanager to /usr/bin and set permissions
    cp arkmanager "${INSTALL_ROOT}${EXECPREFIX}/bin/arkmanager"
    chmod +x "${INSTALL_ROOT}${EXECPREFIX}/bin/arkmanager"

    # Copy arkdaemon to /etc/init.d/arkmanager ,set permissions and add it to boot
    cp arkdaemon "${INSTALL_ROOT}/etc/init.d/arkmanager"
    chmod +x "${INSTALL_ROOT}/etc/init.d/arkmanager"
    # add to startup if the system use sysinit
    if [ -x /usr/sbin/update-rc.d -a -z "${INSTALL_ROOT}" ]; then
      update-rc.d arkmanager defaults
      echo "Ark server will now start on boot, if you want to remove this feature run the following line"
      echo "update-rc.d -f arkmanager remove"
    fi

    # Create a folder in /var/log to let Ark tools write its own log files
    mkdir -p "${INSTALL_ROOT}/var/log/arktools"
    chown "$1" "${INSTALL_ROOT}/var/log/arktools"

    # Copy arkmanager.cfg inside linux configuation folder if it doesn't already exists
    mkdir -p "${INSTALL_ROOT}/etc/arkmanager"
    if [ -f "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg" ]; then
      echo "A previous version of ARK Server Tools was detected in your system, your old configuration was not overwritten. You may need to manually update it."
      exit 2
    else
      cp -n arkmanager.cfg "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg"
      chown "$1" "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg"
    fi

else
    echo "You must specify your system steam user who own steamcmd directory to install ARK Tools."
    echo "Usage: ./install.sh steam"
    exit 1
fi

exit 0
