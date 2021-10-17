#!/usr/bin/env bash

# 0/1 : enable cockpit
cockpit=1
# 0/1 : Disable firewalld
disablefirewalld=0
# List of additional software to install	
addsoftwares=(nmon htop vim tmux ncdu rsync)

# check root
if [[ $EUID -ne 0 ]]
then
	sudo chmod +x "$(dirname "$0")/$0"
	sudo "$(dirname "$0")/$0"
	exit;
fi

# Update
apt update && apt upgrade -y

# Tools
if [[ -n ${addsoftwares[*]} ]]
then
    apt install -y "${addsoftwares[@]}"
fi

type -p tmux >/dev/null && curl -JLO https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux && mv tmux /usr/share/bash-completion/completions/tmux


# Cockpit
if [[ "$cockpit" -eq "1" ]]
then
    apt install -y cockpit
    apt install -y cockpit-networkmanager cockpit-dashboard cockpit-system cockpit-storaged cockpit-pcp cockpit-packagekit cockpit-docker
    systemctl enable cockpit.socket
    systemctl start cockpit.socket
    #firewall-cmd --add-service=cockpit --permanent
    #firewall-cmd --reload
fi

# Firewalld
if [[ "$disablefirewalld" -eq "1" ]]
	then
		systemctl stop firewalld
		systemctl disable firewalld
	fi

echo "Preparation completed, it is recommended to restart!"
