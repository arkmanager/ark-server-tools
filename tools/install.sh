#!/bin/bash

userinstall=no
steamcmd_user=
showusage=no

while [ -n "$1" ]; do
  case "$1" in
    --me)
      userinstall=yes
      steamcmd_user="--me"
    ;;
    -h|--help)
      showusage=yes
      break
    ;;
    --prefix=*)
      PREFIX="${1#--prefix=}"
    ;;
    --prefix)
      PREFIX="$2"
      shift
    ;;
    --exec-prefix=*)
      EXECPREFIX="${1#--exec-prefix=}"
    ;;
    --exec-prefix)
      EXECPREFIX="$2"
      shift
    ;;
    --data-prefix=*)
      DATAPREFIX="${1#--data-prefix=}"
    ;;
    --data-prefix)
      DATAPREFIX="$2"
      shift
    ;;
    --install-root=*)
      INSTALL_ROOT="${1#--install-root=}"
    ;;
    --install-root)
      INSTALL_ROOT="$2"
      shift
    ;;
    --bindir=*)
      BINDIR="${1#--bindir=}"
    ;;
    --bindir)
      BINDIR="$2"
      shift
    ;;
    --libexecdir=*)
      LIBEXECDIR="${1#--libexecdir=}"
    ;;
    --libexecdir)
      LIBEXECDIR="$2"
      shift
    ;;
    --datadir=*)
      DATADIR="${1#--datadir=}"
    ;;
    --datadir)
      DATADIR="$2"
      shift
    ;;
    -*)
      echo "Invalid option '$1'"
      showusage=yes
      break;
    ;;
    *)
      if [ -n "$steamcmd_user" ]; then
        echo "Multiple users specified"
        showusage=yes
        break;
      elif getent passwd "$1" >/dev/null 2>&1; then
        steamcmd_user="$1"
      else
        echo "Invalid user '$1'"
        showusage=yes
        break;
      fi
    ;;
  esac
  shift
done

if [ "$userinstall" == "yes" -a "$UID" -eq 0 ]; then
  echo "Refusing to perform user-install as root"
  showusage=yes
fi

if [ "$showusage" == "no" -a -z "$steamcmd_user" ]; then
  echo "No user specified"
  showusage=yes
fi

if [ "$userinstall" == "yes" ]; then
  PREFIX="${PREFIX:-${HOME}}"
  EXECPREFIX="${EXECPREFIX:-${PREFIX}}"
  DATAPREFIX="${DATAPREFIX:-${PREFIX}/.local/share}"
else
  PREFIX="${PREFIX:-/usr/local}"
  EXECPREFIX="${EXECPREFIX:-${PREFIX}}"
  DATAPREFIX="${DATAPREFIX:-${PREFIX}/share}"
fi

BINDIR="${BINDIR:-${EXECPREFIX}/bin}"
LIBEXECDIR="${LIBEXECDIR:-${EXECPREFIX}/libexec/arkmanager}"
DATADIR="${DATADIR:-${DATAPREFIX}/arkmanager}"

if [ "$showusage" == "yes" ]; then
    echo "Usage: ./install.sh {<user>|--me} [OPTIONS]"
    echo "You must specify your system steam user who own steamcmd directory to install ARK Tools."
    echo "Specify the special used '--me' to perform a user-install."
    echo
    echo "<user>          The user arkmanager should be run as"
    echo
    echo "Option          Description"
    echo "--help, -h      Show this help text"
    echo "--me            Perform a user-install"
    echo "--prefix        Specify the prefix under which to install arkmanager"
    echo "                [PREFIX=${PREFIX}]"
    echo "--exec-prefix   Specify the prefix under which to install executables"
    echo "                [EXECPREFIX=${EXECPREFIX}]"
    echo "--data-prefix   Specify the prefix under which to install suppor files"
    echo "                [DATAPREFIX=${DATAPREFIX}]"
    echo "--install-root  Specify the staging directory in which to perform the install"
    echo "                [INSTALL_ROOT=${INSTALL_ROOT}]"
    echo "--bindir        Specify the directory under which to install executables"
    echo "                [BINDIR=${BINDIR}]"
    echo "--libexecdir    Specify the directory under which to install executable support files"
    echo "                [LIBEXECDIR=${LIBEXECDIR}]"
    echo "--datadir       Specify the directory under which to install support files"
    echo "                [DATADIR=${DATADIR}]"
    exit 1
fi

if [ "$userinstall" == "yes" ]; then
    # Copy arkmanager to ~/bin
    mkdir -p "${INSTALL_ROOT}${BINDIR}"
    cp arkmanager "${INSTALL_ROOT}${BINDIR}/arkmanager"
    chmod +x "${INSTALL_ROOT}${BINDIR}/arkmanager"

    # Create a folder in ~/.local/share to store arkmanager support files
    mkdir -p "${INSTALL_ROOT}${DATADIR}"

    # Copy the uninstall script to ~/.local/share/arkmanager
    cp uninstall-user.sh "${INSTALL_ROOT}${DATADIR}/arkmanager-uninstall.sh"
    chmod +x "${INSTALL_ROOT}${DATADIR}/arkmanager-uninstall.sh"
    sed -i -e "s|^BINDIR=.*|BINDIR=\"${BINDIR}\"|" \
           -e "s|^DATADIR=.*|DATADIR=\"${DATADIR}\"|" \
           "${INSTALL_ROOT}${DATADIR}/arkmanager-uninstall.sh"

    # Create a folder in ~/logs to let Ark tools write its own log files
    mkdir -p "${INSTALL_ROOT}${PREFIX}/logs/arktools"

    # Copy arkmanager.cfg to ~/.arkmanager.cfg.NEW
    cp arkmanager.cfg "${INSTALL_ROOT}${PREFIX}/.arkmanager.cfg.NEW"
    # Change the defaults in the new config file
    sed -i -e "s|^steamcmd_user=\"steam\"|steamcmd_user=\"--me\"|" \
           -e "s|\"/home/steam|\"${PREFIX}|" \
           -e "s|/var/log/arktools|${PREFIX}/logs/arktools|" \
           -e "s|^install_bindir=.*|install_bindir=\"${BINDIR}\"|" \
           -e "s|^install_libexecdir=.*|install_libexecdir=\"${LIBEXECDIR}\"|" \
           -e "s|^install_datadir=.*|install_datadir=\"${DATADIR}\"|" \
           "${INSTALL_ROOT}${PREFIX}/.arkmanager.cfg.NEW"

    # Copy arkmanager.cfg to ~/.arkmanager.cfg if it doesn't already exist
    if [ -f "${INSTALL_ROOT}${PREFIX}/.arkmanager.cfg" ]; then
      echo "A previous version of ARK Server Tools was detected in your system, your old configuration was not overwritten. You may need to manually update it."
      echo "A copy of the new configuration file was included in '${INSTALL_ROOT}${PREFIX}/.arkmanager.cfg.NEW'. Make sure to review any changes and update your config accordingly!"
      exit 2
    else
      mv -n "${INSTALL_ROOT}${PREFIX}/.arkmanager.cfg.NEW" "${INSTALL_ROOT}${PREFIX}/.arkmanager.cfg"
    fi
else
    # Copy arkmanager to /usr/bin and set permissions
    cp arkmanager "${INSTALL_ROOT}${BINDIR}/arkmanager"
    chmod +x "${INSTALL_ROOT}${BINDIR}/arkmanager"

    # Copy the uninstall script to ~/.local/share/arkmanager
    mkdir -p "${INSTALL_ROOT}${LIBEXECDIR}"
    cp uninstall.sh "${INSTALL_ROOT}${DATADIR}/arkmanager-uninstall.sh"
    chmod +x "${INSTALL_ROOT}${DATADIR}/arkmanager-uninstall.sh"
    sed -i -e "s|^BINDIR=.*|BINDIR=\"${BINDIR}\"|" \
           -e "s|^LIBEXECDIR=.*|LIBEXECDIR=\"${LIBEXECDIR}\"|" \
           -e "s|^DATADIR=.*|DATADIR=\"${DATADIR}\"|" \
           "${INSTALL_ROOT}${DATADIR}/arkmanager-uninstall.sh"

    # Copy arkdaemon to /etc/init.d ,set permissions and add it to boot
    if [ -f /lib/lsb/init-functions ]; then
      # on debian 8, sysvinit and systemd are present. If systemd is available we use it instead of sysvinit
      if [ -f /etc/systemd/system.conf ]; then   # used by systemd
        mkdir -p "${INSTALL_ROOT}${LIBEXECDIRPREFIX}"
        cp lsb/arkdaemon "${INSTALL_ROOT}${LIBEXECDIR}/arkmanager.init"
        chmod +x "${INSTALL_ROOT}${LIBEXECDIR}/arkmanager.init"
        cp systemd/arkdeamon.service "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
        sed -i "s|=/usr/libexec/arkmanager/|=${LIBEXECDIR}/|" "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
        sed -i "s@^DAEMON=\"/usr/bin/@DAEMON=\"${BINDIR}/@" "${INSTALL_ROOT}${LIBEXECDIR}/arkmanager.init"
        if [ -z "${INSTALL_ROOT}" ]; then
          systemctl daemon-reload
          systemctl enable arkmanager.service
          echo "Ark server will now start on boot, if you want to remove this feature run the following line"
          echo "systemctl disable arkmanager.service"
	fi
      else  # systemd not present, so use sysvinit
        cp lsb/arkdaemon "${INSTALL_ROOT}/etc/init.d/arkmanager"
        chmod +x "${INSTALL_ROOT}/etc/init.d/arkmanager"
        sed -i "s|^DAEMON=\"/usr/bin/|DAEMON=\"${BINDIR}/|" "${INSTALL_ROOT}/etc/init.d/arkmanager"
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
        mkdir -p "${INSTALL_ROOT}${LIBEXECDIR}"
        cp redhat/arkdaemon "${INSTALL_ROOT}${LIBEXECDIR}/arkmanager.init"
        chmod +x "${INSTALL_ROOT}${LIBEXECDIR}/arkmanager.init"
        cp systemd/arkdeamon.service "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
        sed -i "s|=/usr/libexec/arkmanager/|=${LIBEXECDIR}/|" "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
        sed -i "s@^DAEMON=\"/usr/bin/@DAEMON=\"${BINDIR}/@" "${INSTALL_ROOT}${LIBEXECDIR}/arkmanager.init"
        if [ -z "${INSTALL_ROOT}" ]; then
          systemctl daemon-reload
          systemctl enable arkmanager.service
          echo "Ark server will now start on boot, if you want to remove this feature run the following line"
          echo "systemctl disable arkmanager.service"
        fi
      else # systemd not preset, so use sysvinit
        cp redhat/arkdaemon "${INSTALL_ROOT}/etc/rc.d/init.d/arkmanager"
        chmod +x "${INSTALL_ROOT}/etc/rc.d/init.d/arkmanager"
        sed -i "s@^DAEMON=\"/usr/bin/@DAEMON=\"${BINDIR}/@" "${INSTALL_ROOT}/etc/rc.d/init.d/arkmanager"
        if [ -x /sbin/chkconfig -a -z "${INSTALL_ROOT}" ]; then
          chkconfig --add arkmanager
          echo "Ark server will now start on boot, if you want to remove this feature run the following line"
          echo "chkconfig arkmanager off"
        fi
      fi
    elif [ -f /sbin/runscript ]; then
      cp openrc/arkdaemon "${INSTALL_ROOT}/etc/init.d/arkmanager"
      chmod +x "${INSTALL_ROOT}/etc/init.d/arkmanager"
      sed -i "s@^DAEMON=\"/usr/bin/@DAEMON=\"${BINDIR}/@" "${INSTALL_ROOT}/etc/init.d/arkmanager"
      if [ -x /sbin/rc-update -a -z "${INSTALL_ROOT}" ]; then
        rc-update add arkmanager default
        echo "Ark server will now start on boot, if you want to remove this feature run the following line"
        echo "rc-update del arkmanager default"
      fi
    elif [ -f /etc/systemd/system.conf ]; then   # used by systemd
      mkdir -p "${INSTALL_ROOT}${LIBEXECDIR}"
      cp systemd/arkdaemon.init "${INSTALL_ROOT}${LIBEXECDIR}/arkmanager.init"
      chmod +x "${INSTALL_ROOT}${LIBEXECDIR}/arkmanager.init"
      cp systemd/arkdeamon.service "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
      sed -i "s|=/usr/libexec/arkmanager/|=${LIBEXECDIR}/|" "${INSTALL_ROOT}/etc/systemd/system/arkmanager.service"
      sed -i "s@^DAEMON=\"/usr/bin/@DAEMON=\"${BINDIR}/@" "${INSTALL_ROOT}${LIBEXECDIR}/arkmanager.init"
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
    cp arkmanager.cfg "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg.NEW"
    chown "$1" "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg.NEW"
    sed -i -e "s|^steamcmd_user=\"steam\"|steamcmd_user=\"$1\"|" \
           -e "s|\"/home/steam|\"/home/$1|" \
           -e "s|^install_bindir=.*|install_bindir=\"${BINDIR}\"|" \
           -e "s|^install_libexecdir=.*|install_libexecdir=\"${LIBEXECDIR}\"|" \
           -e "s|^install_datadir=.*|install_datadir=\"${DATADIR}\"|" \
           "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg"

    if [ -f "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg" ]; then
      echo "A previous version of ARK Server Tools was detected in your system, your old configuration was not overwritten. You may need to manually update it."
      echo "A copy of the new configuration file was included in /etc/arkmanager. Make sure to review any changes and update your config accordingly!"
      exit 2
    else
      mv -n "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg.NEW" "${INSTALL_ROOT}/etc/arkmanager/arkmanager.cfg"
    fi
fi

exit 0
