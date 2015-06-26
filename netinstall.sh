#!/bin/bash

#
# Net Installer, used with curl
#

channel=${2:-master} # if defined by 2nd argument install the defined version, otherwise install master

# Download and untar installation files
cd /tmp
curl -L -k -s https://github.com/FezVrasta/ark-server-tools/archive/${channel}.tar.gz | tar xz

# Install ARK Server Tools
cd ark-server-tools-${channel}/tools
chmod +x install.sh
sh install.sh $1 > /dev/null

status=$?

rm -rf /tmp/ark-server-tools-${channel}

# Print messages
case "$status" in
  "0")
    echo "ARK Server Tools were correctly installed in your system inside the home directory of $1!"
    ;;

  "1")
    echo "Something where wrong :("
    ;;
  "2")
    echo "WARNING: A previous version of ARK Server Tools was detected in your system, your old configuration was not overwritten. You may need to manually update it."
    echo "ARK Server Tools were correctly installed in your system inside the home directory of $1!"
    ;;
esac
