# KeyChron S1

works just fine with default firmware, qmk and via


# KeyChron K3

I have a Keychron K3 v1/2 ansi color/RGB optical switches with controller SN32F248B


### Using via GUI configurator

To use via to configure qmk:
- needs via enabled firmware (like mine)
- needs udev rules to allow user access (see `udev.extraRules`)
- set (json)[via_ansi.json] as "design" in via to be configurable via via.
- plug keyboard in and out

Make sure to configure a key for "reset". Pressing that brings it into bootloader mode to update firmware (via sonixflasherc).


### Which flasher to use?

**I recommend `.#sonixflasherc` cli util.**

This gui also exists but seems buggy to me:

```bash
git clone git@github.com:SonixQMK/sonix-flasher.git # 36d51d900fd4727719d31167573ca8691162d182
cd sonix-flasher
nix build .#default
./result/bin/sonix-flasher # needs to run in sonix-flasher repo
```

### Flashing firmwares:

in qmk_firmware, the following key boots to bootloader (in win mode): fn esc

even with borked firmware, you can short two pads to for bootloader (which has id 0c45:7040).

In bootloader, install firmware:

```
./sonixflasherc --vidpid 0c45/7040 --file ~/Downloads/Keychron_K3-Optical_RGB_v1.10_240B.bin
```

### Resources:

Update firmware K3: https://www.keychron.com/pages/firmware-for-k3-us-keyboard
Update bricked K3: https://www.keychron.com/pages/special-instruction-for-firmware-update-k3


### Firmwares

#### original firmware:
https://github.com/SonixQMK/Mechanical-Keyboard-Database/blob/main/stockFWs/Keychron/240B/Keychron_K3-Optical_RGB_v1.10_240B.bin

#### My firmware

build firmware: `nix build .#qmk_firmware_k3`

flash via `sudo sonixflasherc --vidpid 0c45/7040 --file ./result/keychron_k3_rgb_optical_ansi_via.bin` and then configure with via with `via_ansi.json`

- boots every time
- can do mouse
- can do via
- can't do bluetooth (just like all other QMK K3 firmwares - bluetooth firmware blobs are proprietary)

Artifacts:
- keychron_k3_rgb_optical_ansi_via.bin
- via config to use: keyboards/keychron/k3/keymaps/via/via_ansi.json

#### someone running some firmware that supposedly works:
https://github.com/seyahdoo/k3-v2-optical-qmk

.bin download: https://github.com/seyahdoo/k3-v2-optical-qmk/releases/download/v0.1.0/keychron_k3_rgb_optical_iso_iso.zip

Successfully flashes with:

```
sudo ./result/bin/sonixflasherc --vidpid 0c45/7040 --file ~/Downloads/keychron_k3_rgb_optical_iso_iso.bin
```

#### custom firmware from a deleted branch 

"works", referenced by seyahdoo (see above)

https://github.com/SonixQMK/qmk_firmware/tree/96d0671481abb3b9c751a1e35b558a86c55d9d92/keyboards/keychron/k3

bugs:

- no bluetooth
- no mouse
- booting it is buggy, but can be solved by restarting and waiting


# custom firmware fork of 1Conan 

supposedly has experimental bluetooth support (iton branches):
https://github.com/1Conan/qmk_firmware

### Original keychron bluetooth firmware 

available at (is it just complete stock firmware?):

https://www.keychron.com/pages/bluetooth-firmware-for-k3-windows-version-ansi-us-layout

### Starting bootloader / flashing

https://github.com/SonixQMK/sonix-flasher
build with `nix build`, run from the folder. `nix run` should do the same thing, but seems to fail. 

running stock firmware: 
- some key combination
- sonix-flasher second option

running sonix-qmk: 
- first sonix-flasher option
- if buggy: try unplugging, waiting, restarting a few times. Also i feel like you have to bee quick with flashing your image after getting into the bootloader
