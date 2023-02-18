# H1

## The secrets of the undocumented nix-command flags

`nix build --keep-failed`: keeps the worktree of the build and prints its directory

`nix build --option substitute false`: dont use cache servers

## The secrets of the ssh-agents

Due to gnome we are using gnome-keyring-deamon which spawns an `openssh-9.0p1/bin/ssh-agent -D -a /run/user/1000/keyring/.ssh` but exports another `SSH_AUTH_SOCK` to terminals: `/run/user/1000/keyring/ssh`. This deamon suffers from all limitations of gnome-keyrings ssh support [[1](https://wiki.gnome.org/Projects/GnomeKeyring/Ssh)] [[2](https://wiki.gnome.org/Projects/GnomeKeyring/Goals#SSH_Agent)]:

- All `~/.ssh` keys are loaded whenever possible (but only if there also is a public key)
- You cant remove autoloaded keys
- Requiring confirmation is impossible (`ssh-add -c`)

Additionally, for some reason, we have `systemctl --user status ssh-agent` running (`openssh-9.0p1/bin/ssh-agent -a /run/user/1000/ssh-agent`), which works as expected, given that some `ssh-askpass` (such as from seahorse) is available. 

