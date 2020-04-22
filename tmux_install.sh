#!/bin/bash

echo "This is interactive!"
echo "=> ~/.tmux.conf:"
sleep 1

if [ -e ~/.tmux.conf ]; then
	git diff ~/.tmux.conf tmux.conf
	read -p "Replace existing conf? (keep old one as .old) (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
fi
#echo "=> Install tmux.conf globally?"
#read -p "Continue? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

set -e
install -m "644" -b -S ".old" tmux.conf ~/.tmux.conf

echo "Installing dep into ~/.tmux/plugins/tpm."
if [ -e ~/.tmux ]; then
	read -p "Overwrite ~./tmux/? (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
	rm -rf ~/.tmux/plugins/tpm
fi
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

echo "in tmux enter ctrl+b I to install plugins."
