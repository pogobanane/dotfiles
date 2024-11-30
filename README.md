# My dotfiles for NixOS

Built with flake-parts.

Entrypoints:

 - `devShells/`: some shells containing stuff for development (e.g. `nix shell github:pogobanane/dotfiles#latex`)
 - `homeManager/`: my (home-manager)[https://github.com/nix-community/home-manager] config. Can be used stand-alone e.g. on the (doctor-cluster)[https://github.com/TUM-DSE/doctor-cluster-config] with `nix run github:pogobanane/dotfiles#doctor-home -- switch`
 - `pkgs/`: some software i packaged for personal use (e.g. `nix run github:pogobanane/dotfiles#jack-keyboard`)
 - NixOS configurations are in `flake-configurations.nix` (e.g. `just nixos-build` and `sudo nixos-rebuild switch --flake .#aendernix`)

Table of contents (outdated):

```
git+file:///home/peter/dev/dotfiles
├───apps
│   ├───aarch64-darwin
│   │   └───doctor-home: app
│   ├───aarch64-linux
│   │   └───doctor-home: app
│   └───x86_64-linux
│       └───doctor-home: app
├───devShells
│   ├───aarch64-darwin
│   │   ├───clang omitted (use '--all-systems' to show)
│   │   ├───containers omitted (use '--all-systems' to show)
│   │   ├───default omitted (use '--all-systems' to show)
│   │   ├───latex omitted (use '--all-systems' to show)
│   │   ├───networking omitted (use '--all-systems' to show)
│   │   ├───node omitted (use '--all-systems' to show)
│   │   ├───python omitted (use '--all-systems' to show)
│   │   ├───rust omitted (use '--all-systems' to show)
│   │   └───sys-stats omitted (use '--all-systems' to show)
│   ├───aarch64-linux
│   │   ├───clang omitted (use '--all-systems' to show)
│   │   ├───containers omitted (use '--all-systems' to show)
│   │   ├───default omitted (use '--all-systems' to show)
│   │   ├───latex omitted (use '--all-systems' to show)
│   │   ├───networking omitted (use '--all-systems' to show)
│   │   ├───node omitted (use '--all-systems' to show)
│   │   ├───python omitted (use '--all-systems' to show)
│   │   ├───rust omitted (use '--all-systems' to show)
│   │   └───sys-stats omitted (use '--all-systems' to show)
│   └───x86_64-linux
│       ├───clang: development environment 'nix-shell'
│       ├───containers: development environment 'nix-shell'
│       ├───default: development environment 'nix-shell'
│       ├───latex: development environment 'nix-shell'
│       ├───networking: development environment 'nix-shell'
│       ├───node: development environment 'nix-shell'
│       ├───python: development environment 'nix-shell'
│       ├───rust: development environment 'nix-shell'
│       └───sys-stats: development environment 'nix-shell'
├───homeConfigurations: unknown
├───nixosConfigurations
│   ├───aendernix: NixOS configuration
│   └───aenderpad: NixOS configuration
└───packages
    ├───aarch64-darwin
    │   ├───jack-keyboard omitted (use '--all-systems' to show)
    │   ├───loc-git omitted (use '--all-systems' to show)
    │   ├───map-cmd omitted (use '--all-systems' to show)
    │   ├───nix-patched omitted (use '--all-systems' to show)
    │   ├───nix-top omitted (use '--all-systems' to show)
    │   ├───nixos-generations omitted (use '--all-systems' to show)
    │   ├───qmk_firmware_k3 omitted (use '--all-systems' to show)
    │   ├───revanced-cli omitted (use '--all-systems' to show)
    │   ├───self-flake omitted (use '--all-systems' to show)
    │   ├───sonixflasherc omitted (use '--all-systems' to show)
    │   └───wondershaper omitted (use '--all-systems' to show)
    ├───aarch64-linux
    │   ├───jack-keyboard omitted (use '--all-systems' to show)
    │   ├───loc-git omitted (use '--all-systems' to show)
    │   ├───map-cmd omitted (use '--all-systems' to show)
    │   ├───nix-patched omitted (use '--all-systems' to show)
    │   ├───nix-top omitted (use '--all-systems' to show)
    │   ├───nixos-generations omitted (use '--all-systems' to show)
    │   ├───qmk_firmware_k3 omitted (use '--all-systems' to show)
    │   ├───revanced-cli omitted (use '--all-systems' to show)
    │   ├───self-flake omitted (use '--all-systems' to show)
    │   ├───sonixflasherc omitted (use '--all-systems' to show)
    │   └───wondershaper omitted (use '--all-systems' to show)
    └───x86_64-linux
        ├───jack-keyboard: package 'jack-keyboard'
        ├───kobo-book-downloader: package 'kobo-book-downloader-2022-11-23'
        ├───loc-git: package 'loc-0.4.1'
        ├───map-cmd: package 'map-0.1.1'
        ├───nix-patched: package 'nix-patched-2.18.8'
        ├───nix-top: package 'nix-top-0.3.0'
        ├───nixos-generations: package 'nixos-generations'
        ├───qmk_firmware_k3: package 'qmk_firmware_k3'
        ├───revanced-cli: package 'revanced-cli'
        ├───self-flake: package 'self-flake'
        ├───sonixflasherc: package 'sonixflasherc'
        ├───webcord: package 'webcord-3.9.3'
        └───wondershaper: package 'wondershaper'
```


# Notes

Add impurities to self-flake/impure-debug-info via `nix build --override-inputs impurity "path:/tmp/foo/".


## Known issues

- the luks decryption prompt uses the uefi display (R4280). But the ignoreR4280 specialization unbinds the gpu driver from that display at boot. Thus you have to enter your password invisibly.
- Potential fix: framebuffer mapping to the default tty: `fbcon=map:<0123>` https://www.kernel.org/doc/html/latest/fb/fbcon.html (example fbcon=map:1). However during early boot stage 1, fb0 is the only one available. So no second screen then.
- I cant figure out how to bind vfio-pci to gpus after stage 1, so we have to decide which gpu to use at boot time.


## Security to implement some day

- secure boot
- protect processes from being traced/debugged from other ones from the same user: https://www.kernel.org/doc/html/latest/admin-guide/LSM/Yama.html
- prevent general kernel tracing (/dev/mem): https://man7.org/linux/man-pages/man7/kernel_lockdown.7.html
- enable stack protectors, kernel patches etc: use -hardened kernel

# Formatting disks

(legacy until all devices use disko)

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

