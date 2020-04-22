#!/bin/bash

echo "This is interactive!"

set -e
which zsh
set +e

if [ -e /etc/zsh ]; then
	zshrc="/etc/zsh/zshrc"
else
	zshrc="/etc/zshrc"
fi

echo "=> $zshrc"
sleep 1

if [ -e $zshrc ]; then
	git diff $zshrc zshrc
	read -p "Replace existing conf? (keep old one as .old) (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
fi
#echo "=> Install tmux.conf globally?"
#read -p "Continue? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

set -e
sudo install -m "644" -b -S ".old" zshrc $zshrc

echo "Installing dep into /usr/share/zsh/share/antigen.zsh."
if [ -e /usr/share/zsh/share/antigen.zsh ]; then
	read -p "Overwrite /usr/share/zsh/share/antigen.zsh? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
	sudo rm /usr/share/zsh/share/antigen.zsh
fi
sudo mkdir -p /usr/share/zsh/share
sudo curl -L git.io/antigen -o /usr/share/zsh/share/antigen.zsh

echo "Run zsh once as root to install and initialize plugins globally."
