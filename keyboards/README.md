# KeyChron S1

works just fine with default firmware, qmk and via

# KeyChron K3 (v1?)

### someone running some firmware that supposedly works

https://github.com/seyahdoo/k3-v2-optical-qmk

### custom firmware from a deleted branch 

"works", referenced by seyahdoo

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
