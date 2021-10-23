#!/bin/env bash

# 0/1 : enable cockpit
cockpit=1
# List of additional software to install	
addsoftwares=(vim tar git tmux ncdu htop rsync git-extras)
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
	exit
fi

# SELinux
sed -e "s/SELINUX=.*/SELINUX=$selinux/" -i /etc/sysconfig/selinux

# Upgrade
dnf upgrade --refresh --nogpgcheck
dnf check
dnf autoremove
dnf install fwupd -y
fwupdmgr get-devices
fwupdmgr refresh --force
fwupdmgr get-updates
fwupdmgr update

# Turn on EPEL repo
dnf -y install epel-release &&  dnf repolist

# Tools
if [[ -n ${addsoftwares[*]} ]]
then
	dnf install --nogpgcheck -y "${addsoftwares[@]}"
fi
if [ -f /usr/share/bash-completion/completions/tmux ]; then
	curl -JLO https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux && mv tmux /usr/share/bash-completion/completions/tmux
fi

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
# Git exstra and toolbelt
if [ ! -f /usr/local/bin/git-cleave ]; then
	git clone --depth 1 --single-branch --branch v1.7.0 https://github.com/nvie/git-toolbelt > /dev/null
	cp git-toolbelt/git-* /usr/local/bin
	rm -r git-toolbelt
fi


# Disable firewalld

if [[ "$disablefirewalld" -eq "1" ]]
then
	systemctl stop firewalld
	systemctl disable firewalld
fi

# install or update starship
type -p starship >/dev/null || curl -fsS https://starship.rs/install.sh | bash -s -- -y >/dev/null


# install rust
type -p ruspup >/dev/null || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

# install go
if [ ! -f /usr/local/go/bin/go ]; then
	goVersion='1.17.2'
	case $arch in
	aarch64)
		curl -JLO https://golang.org/dl/go${goVersion}.linux-arm64.tar.gz
		rm -rf /usr/local/go && tar -C /usr/local -xzf go${goVersion}.linux-arm64.tar.gz
		rm go${goVersion}.linux-arm64.tar.gz
		;;
	x86_64)
		curl -JLO https://golang.org/dl/go${goVersion}.linux-amd64.tar.gz
		rm -rf /usr/local/go && tar -C /usr/local -xzf go${goVersion}.linux-amd64.tar.gz
		rm go${goVersion}.linux-amd64.tar.gz
		;;
	*) ;;
	esac
	echo "Add /usr/local/go/bin to the PATH environment variable"
fi

echo "Preparation completed, it is recommended to restart!"
