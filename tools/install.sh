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

    # Copy arkmanager.cfg inside linux configuation folder if it doesn't already exists
    if [ -f /etc/arkmanager/arkmanager.cfg ]; then
        mkdir -p /etc/arkmanager
        cp -n arkmanager.cfg /etc/arkmanager/arkmanager.cfg
        chown $1 /etc/arkmanager/arkmanager.cfg
    else
        echo "A previous version of ARK Server Tools was detected in your system, your old configuration was not overwritten. You may need to manually update it.";
        exit 2
    fi

else
    echo "You must specify your system steam user who own steamcmd directory to install ARK Tools."
    echo "Usage: ./install.sh steam"
    exit 1
fi

exit 0
