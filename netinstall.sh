#!/bin/bash

#
# Net Installer, used with curl
#

# Download and untar installation files
cd /tmp
curl -s https://github.com/FezVrasta/ark-server-tools/archive/master.tar.gz > master.tar.gz
tar -zxvf master.tar.gz

# Install ARK Server Tools
cd ark-server-tools-master/tools
chmod +x install.sh
sh install.sh $1 > /dev/null

status=$?

# Remove the installation files
rm -f master.tar.gz
rm -rf /tmp/ark-server-tools-master

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
