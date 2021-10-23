#!/bin/env bash

# 0/1 : enable cockpit
cockpit=1
# List of additional software to install	
addsoftwares=(vim tar git tmux ncdu htop rsync)
# 0/1 : Désactiver le parefeu firewalld
disablefirewalld=0
# enforcing/permissive/disabled : Statut de SELinux à activer
selinux=enforcing

arch=$(uname -m)

# check root
if [[ $EUID -ne 0 ]]
then
	sudo chmod +x "$(dirname "$0")/$0"
	sudo "$(dirname "$0")/$0"
	exit;
fi

# SELinux
sed -e "s/SELINUX=.*/SELINUX=$selinux/" -i /etc/sysconfig/selinux

# Upgrade
dnf -y --nogpgcheck --refresh upgrade

# Turn on EPEL repo
dnf -y install epel-release &&  dnf repolist

# Tools
if [[ -n ${addsoftwares[*]} ]]
then
	dnf install --nogpgcheck -y "${addsoftwares[@]}"
fi
type -p tmux >/dev/null && curl -JLO https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux && mv tmux /usr/share/bash-completion/completions/tmux


# Cockpit

if [[ "$cockpit" -eq "1" ]]
then
	dnf install --nogpgcheck -y cockpit
	dnf install --nogpgcheck -y cockpit-networkmanager cockpit-selinux cockpit-dashboard cockpit-system cockpit-storaged
	systemctl enable cockpit.socket
	systemctl start cockpit.socket
	firewall-cmd --add-service=cockpit --permanent
	firewall-cmd --reload
fi


# Disable firewalld

if [[ "$disablefirewalld" -eq "1" ]]
then
	systemctl stop firewalld
	systemctl disable firewalld
fi

# install or update starship
curl -fsS https://starship.rs/install.sh | bash -s -- -y


# install rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install go
case $arch in
	aarch64) 
		curl -JLO https://golang.org/dl/go1.17.2.linux-arm64.tar.gz
		rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.2.linux-arm64.tar.gz
		rm go1.17.2.linux-arm64.tar.gz
		;;
	x86_64) 
	    curl -JLO https://golang.org/dl/go1.17.2.linux-amd64.tar.gz
		rm -rf /usr/local/go && tar -C /usr/local -xzf go1.17.2.linux-amd64.tar.gz
		rm go1.17.2.linux-amd64.tar.gz
		;;
	*);;
esac
echo "Add /usr/local/go/bin to the PATH environment variable"

echo "Preparation completed, it is recommended to restart!"
