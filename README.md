# ARK: Survival Evolved Linux Server Tools

## Pre-requisites

To install ARK Server Tools you must have already installed **SteamCMD** following this guide:

https://developer.valvesoftware.com/wiki/SteamCMD#Linux

We assume you have created the `steam` user to store steamcmd and your ARK server.

## Install ARK Server Tools

To install ARK Server Tools run these commands:

```sh
cd ~
wget https://github.com/FezVrasta/ark-server-tools/archive/master.zip
unzip master.zip -d arktools
cd arktools/tools
chmod u+x install.sh
sudo sh install.sh steam
```

NB: You may want to change the `install.sh` parameter to fit your steam user if different from `steam`.

This will copy the `arkmanager` and the `arkdaemon` to the proper directories and will create an empty log directory in `/var/log` for ARK Server Tools.

## Install ARK Server

To install ARK Server just run this command as normal user:

```sh
arkmanager install
```

## Credits

Original author of arkmanager: LeXaT
