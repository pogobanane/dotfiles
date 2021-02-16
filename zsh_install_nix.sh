#!/run/current-system/sw/bin/zsh

echo "This is interactive!"

set -e
which zsh
ls ~/.nix-profile/share/antigen/antigen.zsh
set +e

zshrc="~/.zshrc" # this is not used everywhere!

echo "=> $zshrc"
sleep 1

if [ -e $zshrc ]; then
	git diff $zshrc zshrc
	read -p "Replace existing conf? (keep old one as .old) (y/N): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1
fi

set -e
install -m "644" -b -S ".old" zshrc ~/.zshrc

echo "Run zsh once to install and initialize plugins."
