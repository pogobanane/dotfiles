# My dotfiles for NixOS

- builds around nix-flakes
- very quick and dirty
- defies any consistency


# Notes

## The secrets of the undocumented nix-command flags

`nix build --keep-failed`: keeps the worktree of the build and prints its directory

`nix build --option substitute false`: dont use cache servers

## The secrets of the ssh-agents

Due to gnome we are using gnome-keyring-deamon which spawns an `openssh-9.0p1/bin/ssh-agent -D -a /run/user/1000/keyring/.ssh` but exports another `SSH_AUTH_SOCK` to terminals: `/run/user/1000/keyring/ssh`. This deamon suffers from all limitations of gnome-keyrings ssh support [[1](https://wiki.gnome.org/Projects/GnomeKeyring/Ssh)] [[2](https://wiki.gnome.org/Projects/GnomeKeyring/Goals#SSH_Agent)]:

- All `~/.ssh` keys are loaded whenever possible (but only if there also is a public key)
- You cant remove autoloaded keys
- Requiring confirmation is impossible (`ssh-add -c`)

Additionally, for some reason, we have `systemctl --user status ssh-agent` running (`openssh-9.0p1/bin/ssh-agent -a /run/user/1000/ssh-agent`), which works as expected, given that some `ssh-askpass` (such as from seahorse) is available. 

## Security to implement some day

- secure boot
- protect processes from being traced/debugged from other ones from the same user: https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
- prevent general kernel tracing (/dev/mem): https://man7.org/linux/man-pages/man7/kernel_lockdown.7.html
- enable stack protectors, kernel patches etc: use -hardened kernel


# Formatting d

follow essentially: `https://wiki.archlinux.org/title/Dm-crypt/Encrypting_an_entire_system#LVM_on_LUKS`

- set up some boot partition
- create luks partition, `cryptsetup open` it
- create LVM on luks partition `pvcreate /dev/mapper/luks*`


How to mount an encrypted zfs image:

- nix-shell -p util-linux
- sudo losetup
- sudo losetup /dev/loop${n+1} ./zfs.img
- sudo zpool import -o readonly -f -d /dev/loop${n+1} ${partitin label as of lsblk -f: e.g. zroot} -R /mnt
- sudo zfs list
- sudo zfs load-key ${encrypted zpool partition: e.g. zroot/root}
- for legacy mountpoints: sudo mount -t zfs 
