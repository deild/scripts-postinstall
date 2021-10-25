#!/bin/env bash

sudo dnf install -y dnf-plugins-core
sudo dnf config-manager --add-repo https://brave-browser-rpm-release.s3.brave.com/x86_64/
sudo rpm --import https://brave-browser-rpm-release.s3.brave.com/brave-core.asc
sudo dnf install -y brave-browser


# avoir au préalable modifier le profil pour avoir généré un fichier de conf
sudo dnf install -y dconf util-linux GConf2
git clone --single-branch --branch master --depth 1 https://github.com/arcticicestudio/nord-gnome-terminal.git
cd nord-gnome-terminal/src/sh
GCONFTOOL=gconftool-2 ./nord.sh -l 3
sudo dnf remove dconf util-linux GConf2


curl -JLO https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraMono.zip
unzip FiraMono.zip -d FiraMono
sudo mv FiraMono /usr/share/fonts/
rm FiraMono.zip

# Download from https://www.gnome-look.org/p/1356095
tar xf volantes_cursors.tar.gz 
sudo mv volantes_cursors /usr/share/icons/

# download from https://www.gnome-look.org/p/1267246 par exemple Nordic-v40.tar.xz
tar xf Nordic-v40.tar.xz
sudo mv Nordic-v40 /usr/share/themes
gsettings set org.gnome.desktop.interface gtk-theme Nordic
gsettings set org.gnome.desktop.wm.preferences theme Nordic


git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
