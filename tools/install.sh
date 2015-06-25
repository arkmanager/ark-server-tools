#!/bin/bash

EXECPREFIX="${EXECPREFIX:-/usr/local}"

if [ ! -z "$1" ]; then
    # Copy arkmanager to /usr/bin and set permissions
    cp arkmanager "${INSTALL_ROOT}${EXECPREFIX}/bin/arkmanager"
    chmod +x "${INSTALL_ROOT}${EXECPREFIX}/bin/arkmanager"

    # Copy arkdaemon to /etc/init.d ,set permissions and add it to boot
    if [ -f /lib/lsb/init-functions ]; then
      # on debian 8, sysvinit and systemd are present. If systemd is available we use it instead of sysvinit
      if [[ -f /etc/systemd/system.conf ]]; then   # used by systemd
        mkdir -p "/usr/libexec/arkmanager"
        cp lsb/arkdaemon "/usr/libexec/arkmanager/arkmanager.init"
        chmod +x "/usr/libexec/arkmanager/arkmanager.init"
        cp systemd/arkdeamon.service /etc/systemd/system/arkdaemon.service
        systemctl daemon-reload
        systemctl enable arkdaemon.service
        echo "Ark server will now start on boot, if you want to remove this feature run the following line"
        echo "systemctl disable arkmanager.service"
      else  # systemd not present, so use sysvinit
        cp lsb/arkdaemon "${INSTALL_ROOT}/etc/init.d/arkmanager"
        chmod +x "${INSTALL_ROOT}/etc/init.d/arkmanager"
        sed -i "s|^DAEMON=\"/usr|DAEMON=\"${EXECPREFIX}|" "${INSTALL_ROOT}/etc/init.d/arkmanager"
        # add to startup if the system use sysinit
        if [ -x /usr/sbin/update-rc.d -a -z "${INSTALL_ROOT}" ]; then
          update-rc.d arkmanager defaults
          echo "Ark server will now start on boot, if you want to remove this feature run the following line"
          echo "update-rc.d -f arkmanager remove"
        fi
      fi
    elif [ -f /etc/rc.d/init.d/functions ]; then
      cp redhat/arkdaemon "${INSTALL_ROOT}/etc/rc.d/init.d/arkmanager"
      chmod +x "${INSTALL_ROOT}/etc/rc.d/init.d/arkmanager"
      sed -i "s@^DAEMON=\"/usr@DAEMON=\"${EXECPREFIX}@" "${INSTALL_ROOT}/etc/rc.d/init.d/arkmanager"
      if [ -x /sbin/chkconfig -a -z "${INSTALL_ROOT}" ]; then
        chkconfig --add arkmanager
        echo "Ark server will now start on boot, if you want to remove this feature run the following line"
        echo "chkconfig arkmanager off"
      fi
    elif [ -f /sbin/runscript ]; then
      cp openrc/arkdaemon "${INSTALL_ROOT}/etc/init.d/arkmanager"
      chmod +x "${INSTALL_ROOT}/etc/init.d/arkmanager"
      sed -i "s@^DAEMON=\"/usr@DAEMON=\"${EXECPREFIX}@" "${INSTALL_ROOT}/etc/init.d/arkmanager"
      if [ -x /sbin/rc-update -a -z "${INSTALL_ROOT}" ]; then
        rc-update add arkmanager default
        echo "Ark server will now start on boot, if you want to remove this feature run the following line"
        echo "rc-update del arkmanager default"
      fi
    elif [[ /etc/systemd/system.conf ]]; then   # used by systemd
      cp systemd/arkdeamon.service /etc/systemd/system/arkdaemon.service
      systemctl enable arkdeamon.service
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
      sed -i "s|^steamcmd_user=\"steam\"|steamcmd_user=\"$1\"|;s|\"/home/steam|\"/home/$1|" "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg"
    fi

else
    echo "You must specify your system steam user who own steamcmd directory to install ARK Tools."
    echo "Usage: ./install.sh steam"
    exit 1
fi

exit 0
