# ARK: Survival Evolved Linux Server Tools

## Pre-requisites

To install ARK Server Tools you must have already installed **SteamCMD** following this guide:

https://developer.valvesoftware.com/wiki/SteamCMD#Linux

We assume you have created the `steam` user to store steamcmd and your ARK server.

## Requirements

Edit /etc/sysctl.conf and set:
```
fs.file-max=100000
```
Edit /etc/security/limits.conf and set these limits:
```
* soft nofile 100000
* hard nofile 100000
```
Add the following line to `/etc/pam.d/common-session` (Debian/Ubuntu) or `/etc/pam.d/system-auth` (RHEL/CentOS/Fedora):
```
session required pam_limits.so
```

After these edits, you'll need to restart your bash session or reconnect to your SSH shell to make the changes effective.

## Install ARK Server Tools

To install ARK Server Tools run this command:

```sh
curl -s https://raw.githubusercontent.com/FezVrasta/ark-server-tools/master/netinstall.sh | sudo bash -s steam
```

NB: You may want to change the `bash -s` parameter to fit your steam user if different from `steam`.

This will copy the `arkmanager` script and its daemon to the proper directories and will create an empty log directory in `/var/log` for ARK Server Tools.  

## Configure ARK Server

All the needed variables are stored in the /etc/arkmanager/arkmanager.cfg configuration file change them following the comments.

## Install ARK Server

To install ARK Server just run this command as normal user:

```sh
arkmanager install
```
## Commands

#### arkmanager install
installs arkmanager to the directory specified in `.arkmanager.cfg`

#### arkmanager start
starts ARK server

#### arkmanager stop
stops ARK server

#### arkmanager restart
restarts ARK server

#### arkmanager update
manually updates ARK server

#### arkmanager status
Get the status of the server. Show if the process is running, if the server is up and the current version number

#### arkmanager checkupdate
Check if a new version of the server is available but not apply it

## Credits

Original author of arkmanager: LeXaT
