#!/bin/env bash
set -o pipefail

# List of additional software to install
addsoftwares=(vim tar git tmux ncdu htop lshw gnome-tweak-tool vlc openfortivpn)
# List of additional development software to install
adddev=(ShellCheck git-extras pass)
# 0/1 : Désactiver le parefeu firewalld
disablefirewalld=0
# enforcing/permissive/disabled : Statut de SELinux à activer
selinux=enforcing

arch=$(uname -m)

# check root
if [[ $EUID -ne 0 ]]; then
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
fwupdmgr get-devices
fwupdmgr refresh --force
fwupdmgr get-updates
fwupdmgr update

# Use RPM Fusion for Fedora
dnf install "https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm"
dnf install "https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm"

# Tools
if [[ -n ${addsoftwares[*]} ]]; then
	dnf install --nogpgcheck -y "${addsoftwares[@]}"
fi
if [ -f /usr/share/bash-completion/completions/tmux ]; then
	curl -JLO https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux && mv tmux /usr/share/bash-completion/completions/tmux
fi

# Development
if [[ -n ${adddev[*]} ]]; then
	dnf install --nogpgcheck -y "${adddev[@]}"
fi

# Git exstra and toolbelt
if [ ! -f /usr/local/bin/git-cleave ]; then
	git clone --depth 1 --single-branch --branch v1.7.0 https://github.com/nvie/git-toolbelt >/dev/null
	cp git-toolbelt/git-* /usr/local/bin
	rm -r git-toolbelt
fi
# git clone --depth 1 --single-branch --branch 6.3.0 https://github.com/tj/git-extras
# cd git-extras
# make install
# cd
# rm -r git-extras

# Ruby
# if  ! type -p ruby > /dev/null ; then
# 	dnf install git-core zlib zlib-devel gcc-c++ patch readline readline-devel libyaml-devel libffi-devel openssl-devel make bzip2 autoconf automake libtool bison curl sqlite-devel
# 	sudo -u "$user" git clone https://github.com/rbenv/rbenv.git "/home/$user/.rbenv"
# 	export PATH="/home/$user/.rbenv/bin:$PATH"
# 	eval "$(rbenv init -)"
# 	sudo -u "$user" git clone https://github.com/rbenv/ruby-build.git "/home/$user/.rbenv/plugins/ruby-build"
# 	export PATH="/home/$user/.rbenv/plugins/ruby-build/bin:$PATH"
# 	sudo -u "$user" rbenv install 3.0.2
# 	sudo -u "$user" rbenv global 3.0.2
# 	ruby -v
# fi

# Disable firewalld

if [[ "$disablefirewalld" -eq "1" ]]; then
	systemctl stop firewalld
	systemctl disable firewalld
fi

# install or update starship
type -p starship >/dev/null || curl -fsS https://starship.rs/install.sh | bash -s -- -y >/dev/null

# install rust
if type -p ruspup >/dev/null; then
	rustup upgrade
else
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
fi

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

# TODO needs ruby with rbenv
# add gems
# gem install timetrap

if [ ! "vm.swappiness = 1" = "$(sudo sysctl vm.swappiness)" ]; then
	echo "vm.swappiness = 1" >>/etc/sysctl.d/01-swapp.conf
	sysctl --load /etc/sysctl.d/01-swapp.conf
fi

if [ ! "net.ipv6.conf.all.disable_ipv6 = 1" = "$(sudo sysctl net.ipv6.conf.all.disable_ipv6)" ]; then
	# désactivation de ipv6 pour toutes les interfaces
	# désactivation de l’auto configuration pour toutes les interfaces
	echo "net.ipv6.conf.all.disable_ipv6 = 1" >>/etc/sysctl.d/02-ipv6-disable.conf
	echo "net.ipv6.conf.all.autoconf = 0" >>/etc/sysctl.d/02-ipv6-disable.conf
	sysctl --load /etc/sysctl.d/02-ipv6-disable.conf
fi
if [ ! "net.ipv6.conf.default.disable_ipv6 = 1" = "$(sudo net.ipv6.conf.default.disable_ipv6)" ]; then
	# désactivation de ipv6 pour les nouvelles interfaces (ex:si ajout de carte réseau)
	# désactivation de l’auto configuration pour les nouvelles interfaces
	echo "net.ipv6.conf.default.disable_ipv6 = 1" >>/etc/sysctl.d/02-ipv6-disable.conf
	echo "net.ipv6.conf.default.autoconf = 0" >>/etc/sysctl.d/02-ipv6-disable.conf
	sysctl --load /etc/sysctl.d/02-ipv6-disable.conf
fi
if [ ! "net.ipv6.conf.lo.disable_ipv6 = 1" = "$(sudo sysctl net.ipv6.conf.lo.disable_ipv6)" ]; then
	echo "net.ipv6.conf.lo.disable_ipv6 = 1" >>/etc/sysctl.d/02-ipv6-disable.conf
	echo "net.ipv6.conf.lo.autoconf = 0" >>/etc/sysctl.d/02-ipv6-disable.conf
	sysctl --load /etc/sysctl.d/02-ipv6-disable.conf
fi

echo "Preparation completed, it is recommended to restart!"
