# My dotfiles for NixOS

- builds around nix-flakes
- very quick and dirty
- defies any consistency

Add impurities to self-flake/impure-debug-info via `nix build --override-inputs impurity "path:/tmp/foo/".

# Notes

## Known issues

- the luks decryption prompt uses the uefi display (R4280). But the ignoreR4280 specialization unbinds the gpu driver from that display at boot. Thus you have to enter your password invisibly.
- Potential fix: framebuffer mapping to the default tty: `fbcon=map:<0123>` https://www.kernel.org/doc/html/latest/fb/fbcon.html (example fbcon=map:1). However during early boot stage 1, fb0 is the only one available. So no second screen then.
- I cant figure out how to bind vfio-pci to gpus after stage 1, so we have to decide which gpu to use at boot time.

## The secrets of the undocumented nix-command flags

`nix build --keep-failed`: keeps the worktree of the build and prints its directory

`nix build --option substitute false`: dont use cache servers (didnt work when i tried it today)

## The secrets of the ssh-agents

Due to gnome we are using gnome-keyring-deamon which spawns an `openssh-9.0p1/bin/ssh-agent -D -a /run/user/1000/keyring/.ssh` but exports another `SSH_AUTH_SOCK` to terminals: `/run/user/1000/keyring/ssh`. This deamon suffers from all limitations of gnome-keyrings ssh support [[1](https://wiki.gnome.org/Projects/GnomeKeyring/Ssh)] [[2](https://wiki.gnome.org/Projects/GnomeKeyring/Goals#SSH_Agent)]:

- All `~/.ssh` keys are loaded whenever possible (but only if there also is a public key)
- You cant remove autoloaded keys
- Requiring confirmation is impossible (`ssh-add -c`)

Additionally, for some reason, we have `systemctl --user status ssh-agent` running (`openssh-9.0p1/bin/ssh-agent -a /run/user/1000/ssh-agent`), which works as expected, given that some `ssh-askpass` (such as from seahorse) is available.

More gnome BS: increase timeouts for "<app> is not responding" message in mutter source: `#define PING_TIMEOUT_DELAY 5000` https://askubuntu.com/questions/412917/how-to-increase-waiting-time-for-non-responding-programs?_gl=1*1d41o7l*_ga*MTE3MDIyNDA1Ny4xNjc4MDExNDEw*_ga_S812YQPLT2*MTY4NTI2NzU5Mi4zLjEuMTY4NTI2NzYyMy4wLjAuMA..

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

# TODO

similar to nixos-generations:
find gc roots like `./result` folders that are worth to be deleted
https://github.com/NixOS/nix/issues/4633

find all store paths used by `./result`: `nix-store --query --requisites ./result/`

calculate store sizes of paths: `nix-store --query --size $(nix-store --query --requisites ./result/)`
(maybe it is useful to use df or similar instead to get a more realistic view of how much space it takes on my disk. --size only calculates NAR size)

How to find which paths we can actually delete, if we delete certain gc-roots?
nix-store gc facilities (--gc, --delete) dont work, because they have to little options.

So list all gc-roots for all requisites to simulate garbage collection ourselves?
Or just extend nix-store?


Firefox preferences to expose timezone while suppressing fingerprinting:
privacy.resistFingerprinting	true	
privacy.resistFingerprinting.testing.setTZtoUTC	true
