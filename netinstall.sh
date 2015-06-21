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
if [[ -n $(sh install.sh $1) ]]; then
  echo "Something where wrong :("
else
  echo "ARK Server Tools were correctly installed in your system inside the home directory of $1!"
fi

# Remove the installation files
rm -f master.tar.gz
rm -rf /tmp/ark-server-tools-master

