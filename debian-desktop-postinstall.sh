#!/bin/env bash

# List of additional software to install	
addsoftwares=(vim tar git tmux ncdu htop)
# List of additional development software to install
adddev=(rbenv)


arch=$(uname -m)

# check root
if [[ $EUID -ne 0 ]]
then
	sudo chmod +x "$(dirname "$0")/$0"
	sudo "$(dirname "$0")/$0"
	exit;
fi

# Upgrade
apt update && apt -y upgrade

# Tools
if [[ -n ${addsoftwares[*]} ]]
then
	apt install -y "${addsoftwares[@]}"
fi
type -p tmux >/dev/null && curl -JLO https://raw.githubusercontent.com/imomaliev/tmux-bash-completion/master/completions/tmux && mv tmux /usr/share/bash-completion/completions/tmux


# Development
if [[ -n ${adddev[*]} ]]
then
	apt install -y "${adddev[@]}"
	eval "$(rbenv init -)"
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

# add gems
gem install timetrap


echo "Preparation completed, it is recommended to restart!"
