#!/bin/bash

#
# Net Installer, used with curl
#

steamcmd_user="$1"
channel=${2:-master} # if defined by 2nd argument install the defined version, otherwise install master
shift
shift

output=/dev/null

if [ "$1" = "--verbose" ]; then
  output=/dev/fd/1
  shift
elif [[ "$1" =~ ^--output= ]]; then
  output="${1#--output=}"
  shift
fi

unstable=
if [ "$1" = "--unstable" ]; then
  unstable=1
fi

function doInstallFromCommit(){
  local commit="$1"
  tmpdir="$(mktemp -d "ark-server-tools-XXXXXXXX")"
  if [ -z "$tmpdir" ]; then echo "Unable to create temporary directory"; exit 1; fi
  cd "$tmpdir"
  echo "Downloading installer"
  curl -L "https://github.com/FezVrasta/ark-server-tools/archive/${commit}.tar.gz" | tar -xz
  cd "ark-server-tools-${commit}/tools"
  if [ ! -f "install.sh" ]; then echo "install.sh not found in $PWD"; exit 1; fi
  sed -i -e "s|^arkstCommit='.*'|arkstCommit='${commit}'|" \
         -e "s|^arkstTag='.*'|arkstTag='${tagname}'|" \
         arkmanager
  echo "Running install.sh"
  bash install.sh "$steamcmd_user" "${reinstall_args[@]}"
  result=$?
  cd /
  rm -rf "$tmpdir"

  if [ "$result" = 0 ] || [ "$result" = 2 ]; then
    "ARK Server Tools successfully installed"
  else
    "ARK Server Tools install failed"
  fi
  exit $result
}

function doInstallFromRelease(){
  local tagname=
  local desc=

  echo "Getting latest release..."
  # Read the variables from github
  while IFS=$'\t' read n v; do
    case "${n}" in
      tag_name) tagname="${v}"; ;;
      body) desc="${v}"
    esac
  done < <(curl -s "https://api.github.com/repos/FezVrasta/ark-server-tools/releases/latest" | sed -n 's/^  "\([^"]*\)": "*\([^"]*\)"*,*/\1\t\2/p')

  if [ -n "$tagname" ]; then
    echo "Latest release is ${tagname}"
    echo "Getting commit for latest release..."
    local commit="$(curl -s "https://api.github.com/repos/FezVrasta/ark-server-tools/git/refs/tags/${tagname}" | sed -n 's/^ *"sha": "\(.*\)",.*/\1/p')"
    doUpgradeToolsFromCommit "$commit"
  else
    echo "Unable to get latest release"
  fi
}

function doInstallFromBranch(){
  channel="$1"
  commit="`curl -s "https://api.github.com/repos/FezVrasta/ark-server-tools/git/refs/heads/${channel}" | sed -n 's/^ *"sha": "\(.*\)",.*/\1/p'`"
  
  if [ -z "$commit" ]; then
    if [ -n "$unstable" ]; then
      echo "Channel ${channel} not found - trying master"
      doInstallFromBranch master
    else
      doInstallFromRelease
    fi
  fi

  doInstallFromCommit "$commit"
}

# Download and untar installation files
cd "$TEMP"

if [ "$channel" = "master" ] && [ -z "$unstable" ]; then
  doInstallFromRelease
else
  doInstallFromBranch "$channel"
fi

