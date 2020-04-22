#!/bin/bash

if [ -e /etc/zsh ]; then
	$zshrc="/etc/zsh/zshrc"
else
	$zshrc="/etc/zshrc"
fi

cp $zshrc ./vimrc
