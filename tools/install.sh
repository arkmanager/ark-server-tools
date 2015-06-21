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

    # Copy arkmanager.cfg inside linux configuation folder
    mkdir -p /etc/arkmanager
    mv arkmanager.cfg /etc/arkmanager/arkmanager.cfg
    chown $1 /etc/arkmanager/arkmanager.cfg

else
    echo "You must specify your system steam user who own steamcmd directory to install ARK Tools."
    echo "Usage: ./install.sh steam"
fi

exit 0
