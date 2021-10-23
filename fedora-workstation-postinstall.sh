#!/bin/env bash
set -o pipefail

# List of additional software to install
addsoftwares=(vim tar git tmux ncdu htop lshw vlc fira-code-fonts)
# List of additional development software to install
adddev=(ShellCheck git-extras)
# 0/1 : Désactiver le parefeu firewalld
disablefirewalld=0
# enforcing/permissive/disabled : Statut de SELinux à activer
selinux=enforcing

arch=$(uname -m)
user="$1"

# check root
if [[ $EUID -ne 0 ]]; then
	sudo chmod +x "$(dirname "$0")/$0"
	sudo "$(dirname "$0")/$0" "$(id -nu)"
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

# Tools
if [[ -n ${addsoftwares[*]} ]]; then
	dnf install --nogpgcheck -y "${addsoftwares[@]}"
fi
type -p tmux >/dev/null && curl -JLO https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux && mv tmux /usr/share/bash-completion/completions/tmux

# Development
if [[ -n ${adddev[*]} ]]; then
	dnf install --nogpgcheck -y "${adddev[@]}"
fi

# Git exstra and toolbelt
git clone --depth 1 --single-branch --branch v1.7.0 https://github.com/nvie/git-toolbelt
cp git-toolbelt/git-* /usr/local/bin
rm -r git-toolbelt
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
curl -fsS https://starship.rs/install.sh | bash -s -- -y >/dev/null

# install rust
#type -p rustup >/dev/null && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh

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

# Visual Studio Code
if type -p code >/dev/null; then
	rpm --import https://packages.microsoft.com/keys/microsoft.asc
	sh -c 'echo -e "[code]\nname=Visual Studio Code\nbaseurl=https://packages.microsoft.com/yumrepos/vscode\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/vscode.repo'
	dnf check-update
	dnf install -y code
fi

echo "Preparation completed, it is recommended to restart!"
