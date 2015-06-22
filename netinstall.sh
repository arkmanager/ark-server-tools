#!/bin/bash

#
# Net Installer, used with curl
#

# Download and untar installation files
cd /tmp
wget https://github.com/FezVrasta/ark-server-tools/archive/master.tar.gz
tar -zxvf master.tar.gz

# Install ARK Server Tools
cd ark-server-tools-master/tools
chmod +x install.sh
sh install.sh $1

status = $?

# Remove the installation files
rm -f master.tar.gz
rm -rf /tmp/ark-server-tools-master


if (( $status == 0 )); then
  echo "ARK Server Tools were correctly installed in your system inside the home directory of $1!"
fi

if (( $status == 1 )); then
  echo "Something where wrong :("
fi

if (( $status == 2 )); then
  echo "WARNING: A previous version of ARK Server Tools was detected in your system, your old configuration was not overwritten. You may need to manually update it."
  echo "ARK Server Tools were correctly installed in your system inside the home directory of $1!"
fi
