#!/bin/bash

echo "This is interactive!"
echo "=> ~/.vimrc:"
sleep 1

if [ -e ~/.vimrc ]; then
	git diff ~/.vimrc vimrc
	read -p "Replace existing conf? (keep old one as .old) (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
fi
#echo "=> Install tmux.conf globally?"
#read -p "Continue? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

set -e
install -m "644" -b -S ".old" vimrc ~/.vimrc


# 1. run this to install vim-plug
 curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# or
# curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
#     https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# 2. create basic vimrc
echo "install plugins by running :PlugInstall in vim"






