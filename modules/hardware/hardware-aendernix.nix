# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
  ];

  environment.systemPackages = with pkgs; [
    amdgpu_top # cool gui: amdgpu_top --gui
    rgp # performance profiling for amdgpus (more detailed perf insights?)
  ];

  # as soon as i upgrade 5.16
  # also: upstream it https://github.com/NixOS/nixos-hardware/pull/438
  #boot = lib.mkIf (lib.versionAtLeast config.boot.kernelPackages.kernel.version "5.17") {
  #  kernelParams = [ "initcall_blacklist=acpi_cpufreq_init" ];
  #  kernelModules = [ "amd-pstate" ];
  #};

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  #boot.loader.efi.canTouchEfiVariables = true; // TODO
  boot.supportedFilesystems = [ "ntfs" ];
  # changing this seems to require reboot twice:
  boot.kernelParams = [
    "add_efi_memmap" 
    "kvm.ignore_msrs=1"
    "kvm.report_ignored_msrs=0"
  ];

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ "dm-snapshot" "vfio_pci" "vfio" "vfio_iommu_type1" ];
  # with linux 5.10 lts, BT audio works. With latest it doesnt.
  boot.kernelModules = [ "kvm-amd" ];
  # boot.kernelPackages = pkgs.linuxPackages; # _latest; 
  boot.kernelPackages = let
      linux = pkgs.linuxPackages;
      # zen hangs less during high disk IO but also has noticably worse frametimes in games
      # linux = pkgs.linuxPackages_zen;
    in
      pkgs.lib.mkDefault (pkgs.recurseIntoAttrs linux);
  boot.extraModulePackages = [ ];

  # page compression because swap on zfs partitions is a bit dangerous.
  # disable, because it still leads to an unresponsive system, once many gigabyte are swapped.
  #zramSwap.enable = true;

  boot.initrd.luks.devices = {
    "nixos-lukscrypt" = {
      device = "/dev/disk/by-uuid/0ffded4d-83e3-4110-9386-6a679de1a461";
    };
  };
  # remember to set your console keyboard layout for how to input the disk password at boot
  console.keyMap = "de";
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/22be79a6-98a6-4a0f-b687-c803a02f60d9";
    fsType = "btrfs";
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/405E-B882";
    fsType = "vfat";
  };
  fileSystems."/hdd" = {
    device = "/dev/disk/by-uuid/6fe4e745-aee4-4a70-a9b9-03cd4f1894f5";
    fsType = "ext4";
  };

  swapDevices = [ ];

}
