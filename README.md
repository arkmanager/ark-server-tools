# ARK: Survival Evolved Linux Server Tools

## Pre-requisites

To install ARK Server Tools you must have already installed **SteamCMD** following this guide:

https://developer.valvesoftware.com/wiki/SteamCMD#Linux

We assume you have created the `steam` user to store steamcmd and your ARK server.

## Install requirement
Use this command to install soft requirement on your system
```
apt-get install screen unzip
```

## Install ARK Server Tools

To install ARK Server Tools run these commands:

```sh
cd ~
wget https://github.com/FezVrasta/ark-server-tools/archive/master.tar.gz
tar -zxvf master.tar.gz
cd ark-server-tools-master/tools
chmod u+x install.sh
sudo sh install.sh steam
```

NB: You may want to change the `install.sh` parameter to fit your steam user if different from `steam`.

This will copy the `arkmanager` and the `arkdaemon` to the proper directories and will create an empty log directory in `/var/log` for ARK Server Tools.

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

#### arkmanager broadcast [message]
broadcast a message to ARK server chat

```sh
arkmanager broadcast "your message here"
```

## Credits

Original author of arkmanager: LeXaT
