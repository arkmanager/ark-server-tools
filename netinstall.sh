#!/bin/bash

#
# Net Installer, used with curl
#

arkstGithubRepo="arkmanager/ark-server-tools"

steamcmd_user="$1"
shift

args=()
unstable=
userinstall=
userinstall2=
commit=

for arg in "$@"; do
  case "$arg" in
    --unstable) unstable=1; ;;
    --repo=*) arkstGithubRepo="${arg#--repo=}"; ;;
    --perform-user-install) userinstall2=yes; ;;
    --yes-i-really-want-to-perform-a-user-install) userinstall=yes; ;;
    --commit=*) commit="${arg#--commit=}"; ;;
    --tag=*) commit="$(curl -s "https://api.github.com/repos/${arkstGithubRepo}/git/refs/tags/${arg#--tag=}" | sed -n 's/^ *"sha": "\(.*\)",.*/\1/p')"; ;;
    *)
      if [[ -n "$channel" || "$arg" == --* ]]; then
        args+=("$arg")
      else
        channel="$arg"
      fi
    ;;
  esac
done

if [ -z "$channel" ]; then
  channel="master"
fi

if [[ "$steamcmd_user" == "--me" && -z "$userinstall2" ]]; then
  echo "You have requested a user-install.  You probably don't want this."
  echo "A user-install will create ~/.config/arkmanager/instances/main.cfg"
  echo "This config file will override /etc/arkmanager/instances/main.cfg"
  echo "Add --perform-user-install if you want this."
  exit 1
elif [[ "$steamcmd_user" == "--me" && -z "$userinstall" ]]; then
  echo "You have requested a user-install.  You probably don't want this."
  echo "A user-install will create ~/.config/arkmanager/instances/main.cfg"
  echo "This config file will override /etc/arkmanager/instances/main.cfg"
  echo "Add --yes-i-really-want-to-perform-a-user-install if you really want this."
  exit 1
elif [[ "$steamcmd_user" == "--me" ]]; then
  echo "You have requested a user-install.  You probably don't want this."
  echo "A user-install will create ~/.config/arkmanager/instances/main.cfg"
  echo "This config file will override /etc/arkmanager/instances/main.cfg"
  echo "You have been warned."
fi

function die(){
  echo "$@" >&2
  exit
}

function doInstallFromCommit(){
  local commit="$1"
  shift
  tmpdir="$(mktemp -t -d "ark-server-tools-XXXXXXXX")"
  if [ -z "$tmpdir" ]; then echo "Unable to create temporary directory"; exit 1; fi
  cd "$tmpdir" || die "Unable to change to temporary directory"
  echo "Downloading installer"
  curl -s -L "https://github.com/${arkstGithubRepo}/archive/${commit}.tar.gz" | tar -xz
  cd "ark-server-tools-${commit}/tools" || die "Unable to change to extracted directory"
  if [ ! -f "install.sh" ]; then echo "install.sh not found in $PWD"; exit 1; fi
  sed -i -e "s|^arkstCommit='.*'|arkstCommit='${commit}'|" \
         -e "s|^arkstTag='.*'|arkstTag='${tagname}'|" \
         arkmanager
  echo "Running install.sh"
  bash install.sh "$steamcmd_user" "$@"
  result=$?
  cd /
  rm -rf "$tmpdir"

  if [ "$result" = 0 ] || [ "$result" = 2 ]; then
    echo "ARK Server Tools successfully installed"
  else
    echo "ARK Server Tools install failed"
  fi
  return $result
}

function doInstallFromRelease(){
  local tagname=

  echo "Getting latest release..."
  # Read the variables from github
  while IFS=$'\t' read -r n v; do
    case "${n}" in
      tag_name) tagname="${v}"; ;;
    esac
  done < <(curl -s "https://api.github.com/repos/${arkstGithubRepo}/releases/latest" | sed -n 's/^  "\([^"]*\)": "*\([^"]*\)"*,*/\1\t\2/p')

  if [ -n "$tagname" ]; then
    echo "Latest release is ${tagname}"
    echo "Getting commit for latest release..."
    # shellcheck disable=SC2155
    local commit="$(curl -s "https://api.github.com/repos/${arkstGithubRepo}/git/refs/tags/${tagname}" | sed -n 's/^ *"sha": "\(.*\)",.*/\1/p')"
    doInstallFromCommit "$commit" "$@"
  else
    echo "Unable to get latest release"
    return 1
  fi
}

function doInstallFromBranch(){
  channel="$1"
  shift
  commit="$(curl -s "https://api.github.com/repos/${arkstGithubRepo}/git/refs/heads/${channel}" | sed -n 's/^ *"sha": "\(.*\)",.*/\1/p')"
  
  if [ -z "$commit" ]; then
    if [ -n "$unstable" ]; then
      echo "Channel ${channel} not found - trying master"
      doInstallFromBranch master "$@"
    else
      doInstallFromRelease "$@"
    fi
  else
    doInstallFromCommit "$commit"
  fi
}

# Download and untar installation files
cd "$TEMP" || die "Unable to change to temporary directory"

if [ -n "$commit" ]; then
  doInstallFromCommit "$commit" "${args[@]}"
elif [ "$channel" = "master" ] && [ -z "$unstable" ]; then
  doInstallFromRelease "${args[@]}"
else
  doInstallFromBranch "$channel" "${args[@]}"
fi

