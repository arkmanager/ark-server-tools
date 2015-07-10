# ARK: Survival Evolved Linux Server Tools

This tool allows you to manage any ARK: Survival Evolved linux server without having to remember long commands.  
It provides a lot of features, to get the full list check the **Commands** section on the bottom of this page.

## Pre-requisites

To install ARK Server Tools you must have already installed **SteamCMD** following this guide:

https://developer.valvesoftware.com/wiki/SteamCMD#Linux

We assume you have created the `steam` user to store steamcmd and your ARK server.

## Requirements

To allow your ARK server to communicate with the outside you have to open some ports in your firewall:

```sh
iptables -I INPUT -p udp --dport 27016 -j ACCEPT
iptables -I INPUT -p tcp --dport 27016 -j ACCEPT
iptables -I INPUT -p udp --dport 7778 -j ACCEPT
iptables -I INPUT -p tcp --dport 7778 -j ACCEPT
iptables -I INPUT -p tcp --dport 32330 -j ACCEPT
```

NB: Change the ports according to the ones set in your `arkmanager.cfg` file.

## Install ARK Server Tools

To install ARK Server Tools run this command:

```sh
curl -sL http://git.io/vtf5N | sudo bash -s steam
```

NB: You may want to change the `bash -s` parameter to fit your steam user if different from `steam`.

This will copy the `arkmanager` script and its daemon to the proper directories and will create an empty log directory in `/var/log` for ARK Server Tools.

## Configuration

Stored in `/etc/arkmanager/arkmanager.cfg` you can find the variables needed to start the server, like the port numbers, the system environment variables and so on.

Also, in this file, you can specify any parameter you want to add to the startup command of ARK server.  
These parameters must be prefixed by the `ark_` string, some example could be:

```sh
ark_SessionName="My ARK server"
ark_MaxPlayers=50
ark_ServerPVE=False
ark_DifficultyOffset=1
```

Your session name may not contain special characters (eg. `!![EU]!! Aw&some ARK`) as it could break the startup command.  
In this case you may want to comment out the `ark_SessionName` variable and define it inside your **GameUserSettings.ini** file instead.

You can override or add variables for a specific system user creating a file called `.arkmanager.cfg` in the home directory of the system user.

## Install ARK Server

To install ARK Server just run this command as normal user:

```sh
arkmanager install
```
## Commands

To get a complete list of the script commands you can run `arkmanager --help` or `arkmanager -h`.

#### arkmanager install
installs arkmanager to the directory specified in `/etc/arkmanager/arkmanager.cfg` or `~/.arkmanager.cfg`.

#### arkmanager start
starts ARK server

#### arkmanager stop
stops ARK server

#### arkmanager restart
restarts ARK server

#### arkmanager update
manually updates ARK server if a new version is available

#### arkmanager update --force
Apply update without check the current version

#### arkmanager update --safe
Waits for server to perform world save and then updates.

#### arkmanager status
Get the status of the server. Show if the process is running, if the server is up and the current version number

#### arkmanager checkupdate
Check if a new version of the server is available but not apply it

#### arkmanager upgrade
Check for a new ARK Server Tools version and upgrades it if needed

#### arkmanager backup
Saves a backup of your server inside the backup directory

## Credits

Original author of arkmanager: LeXaT
