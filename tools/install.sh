#!/bin/bash

EXECPREFIX="${EXECPREFIX:-/usr/local}"

if [ ! -z "$1" ]; then
    # Copy arkmanager to /usr/bin and set permissions
    cp arkmanager "${INSTALL_ROOT}${EXECPREFIX}/bin/arkmanager"
    chmod +x "${INSTALL_ROOT}${EXECPREFIX}/bin/arkmanager"

    # Copy arkdaemon to /etc/init.d ,set permissions and add it to boot
    if [ -f /lib/lsb/init-functions ]; then
      # on debian 8, sysvinit and systemd are present. If systemd is available we use it instead of sysvinit
      if [ -f /etc/systemd/system.conf ]; then   # used by systemd
        mkdir -p "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager"
        cp lsb/arkdaemon "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager/arkmanager.init"
        chmod +x "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager/arkmanager.init"
        cp systemd/arkdeamon.service "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
        sed -i "s|=/usr/|=${EXECPREFIX}/|" "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
        sed -i "s@^DAEMON=\"/usr@DAEMON=\"${EXECPREFIX}@" "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager/arkmanager.init"
        if [ -z "${INSTALL_ROOT}" ]; then
          systemctl daemon-reload
          systemctl enable arkmanager.service
          echo "Ark server will now start on boot, if you want to remove this feature run the following line"
          echo "systemctl disable arkmanager.service"
	fi
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
      # on RHEL 7, sysvinit and systemd are present. If systemd is available we use it instead of sysvinit
      if [ -f /etc/systemd/system.conf ]; then   # used by systemd
        mkdir -p "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager"
        cp redhat/arkdaemon "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager/arkmanager.init"
        chmod +x "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager/arkmanager.init"
        cp systemd/arkdeamon.service "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
        sed -i "s|=/usr/|=${EXECPREFIX}/|" "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
        sed -i "s@^DAEMON=\"/usr@DAEMON=\"${EXECPREFIX}@" "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager/arkmanager.init"
        if [ -z "${INSTALL_ROOT}" ]; then
          systemctl daemon-reload
          systemctl enable arkmanager.service
          echo "Ark server will now start on boot, if you want to remove this feature run the following line"
          echo "systemctl disable arkmanager.service"
        fi
      else # systemd not preset, so use sysvinit
        cp redhat/arkdaemon "${INSTALL_ROOT}/etc/rc.d/init.d/arkmanager"
        chmod +x "${INSTALL_ROOT}/etc/rc.d/init.d/arkmanager"
        sed -i "s@^DAEMON=\"/usr@DAEMON=\"${EXECPREFIX}@" "${INSTALL_ROOT}/etc/rc.d/init.d/arkmanager"
        if [ -x /sbin/chkconfig -a -z "${INSTALL_ROOT}" ]; then
          chkconfig --add arkmanager
          echo "Ark server will now start on boot, if you want to remove this feature run the following line"
          echo "chkconfig arkmanager off"
        fi
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
    elif [ -f /etc/systemd/system.conf ]; then   # used by systemd
      mkdir -p "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager"
      cp systemd/arkdaemon.init "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager/arkmanager.init"
      chmod +x "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager/arkmanager.init"
      cp systemd/arkdeamon.service "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
      sed -i "s|=/usr/|=${EXECPREFIX}/|" "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
      sed -i "s@^DAEMON=\"/usr@DAEMON=\"${EXECPREFIX}@" "${INSTALL_ROOT}${EXECPREFIX}/libexec/arkmanager/arkmanager.init"
      if [ -z "${INSTALL_ROOT}" ]; then
        systemctl enable arkmanager.service
        echo "Ark server will now start on boot, if you want to remove this feature run the following line"
        echo "systemctl disable arkmanager.service"
      fi
    fi

    # Create a folder in /var/log to let Ark tools write its own log files
    mkdir -p "${INSTALL_ROOT}/var/log/arktools"
    chown "$1" "${INSTALL_ROOT}/var/log/arktools"

    # Copy arkmanager.cfg inside linux configuation folder if it doesn't already exists
    mkdir -p "${INSTALL_ROOT}/etc/arkmanager"
    if [ -f "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg" ]; then
      cp -n arkmanager.cfg "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg.NEW"
      chown "$1" "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg.NEW"
      echo "A previous version of ARK Server Tools was detected in your system, your old configuration was not overwritten. You may need to manually update it."
      echo "A copy of the new configuration file was included in /etc/arkmanager. Make sure to review any changes and update your config accordingly!"
      exit 2
    else
      cp -n arkmanager.cfg "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg"
      chown "$1" "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg"
      sed -i "s|^steamcmd_user=\"steam\"|steamcmd_user=\"$1\"|;s|\"/home/steam|\"/home/$1|" "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg"
    fi

else
    echo "You must specify your system steam user who own steamcmd directory to install ARK Tools."
    echo "Usage: ./install.sh steam"
    echo
    echo "Environment variables affecting install:"
    echo "EXECPREFIX:   prefix in which to install arkmanager executable"
    echo "              [${EXECPREFIX}]"
    echo "INSTALL_ROOT: staging directory in which to perform install"
    echo "              [${INSTALL_ROOT}]"
    exit 1
fi

exit 0
