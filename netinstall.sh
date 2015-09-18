#!/bin/bash

#
# Net Installer, used with curl
#

steamcmd_user="$1"
channel=${2:-master} # if defined by 2nd argument install the defined version, otherwise install master
shift 2

# Download and untar installation files
cd /tmp
COMMIT="`curl -L -k -s https://api.github.com/repos/FezVrasta/ark-server-tools/git/refs/heads/${channel} | sed -n 's/^ *"sha": "\(.*\)",.*/\1/p'`"

if [ -z "$COMMIT" ]; then
  if [ "$channel" != "master" ]; then
    echo "Channel ${channel} not found - trying master"
    channel=master
    COMMIT="`curl -L -k -s https://api.github.com/repos/FezVrasta/ark-server-tools/git/refs/heads/${channel} | sed -n 's/^ *"sha": "\(.*\)",.*/\1/p'`"
  fi
fi

if [ -z "$COMMIT" ]; then
  echo "Unable to retrieve latest commit"
  exit 1
fi

mkdir ark-server-tools-${channel}
cd ark-server-tools-${channel}
curl -L -k -s https://github.com/FezVrasta/ark-server-tools/archive/${COMMIT}.tar.gz | tar xz

# Install ARK Server Tools
cd ark-server-tools-${COMMIT}/tools
sed -i "s|^arkstCommit='.*'$|arkstCommit='${COMMIT}'|" arkmanager
version=`<../.version`
sed -i "s|^arkstVersion=\".*\"|arkstVersion='${version}'|" arkmanager
chmod +x install.sh
bash install.sh "$steamcmd_user" "$@" > /dev/null

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
