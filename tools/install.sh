#!/bin/bash

if [ ! -z $1 ]; then
    # Copy arkmanager to /usr/bin and set permissions
    cp arkmanager /usr/bin/arkmanager
    chmod +x /usr/bin/arkmanager

    # Copy arkdaemon to /etc/init.d and set permissions
    cp arkdaemon /etc/init.d/arkdaemon
    chmod +x /etc/init.d/arkdaemon

    # Create a folder in /var/log to let Ark tools write its own log files
    mkdir -p /var/log/arktools
    chown $1 /var/log/arktools

    # Copy .arkmanager.cfg inside user home
    mv arkmanager.cfg /home/$1/.arkmanager.cfg
    chown $1 /home/$1/.arkmanager.cfg

    # Copy arkdaemon.cfg inside /etc folder
    mv arkdaemon.cfg /etc/arkdaemon.cfg
    chown $1 /etc/arkdaemon.cfg
    echo ${1} >> /etc/arkdaemon.cfg

else
    echo "You must specify your steam user to install ARK Tools. Usage: ./install.sh steam"
fi

exit 0
