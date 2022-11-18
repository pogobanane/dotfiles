# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
  ];


  # as soon as i upgrade 5.16
  # also: upstream it https://github.com/NixOS/nixos-hardware/pull/438
  #boot = lib.mkIf (lib.versionAtLeast config.boot.kernelPackages.kernel.version "5.17") {
  #  kernelParams = [ "initcall_blacklist=acpi_cpufreq_init" ];
  #  kernelModules = [ "amd-pstate" ];
  #};

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" ];
  boot.initrd.kernelModules = [ ];
  # with linux 5.10 lts, BT audio works. With latest it doesnt.
  boot.kernelModules = [ "kvm-amd" ];
  # boot.kernelPackages = pkgs.linuxPackages; # _latest; 
  boot.kernelPackages = let
      linux = pkgs.linuxPackages;
    in
      pkgs.lib.mkDefault (pkgs.recurseIntoAttrs linux);
  boot.extraModulePackages = [ ];

  # page compression because swap on zfs partitions is a bit dangerous.
  # disable, because it still leads to an unresponsive system, once many gigabyte are swapped.
  #zramSwap.enable = true;

  fileSystems."/" =
    { device = "zroot/root/nixos";
      fsType = "zfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/3E25-330D";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "zroot/root/home";
      fsType = "zfs";
    };

  fileSystems."/tmp" =
    { device = "zroot/root/tmp";
      fsType = "zfs";
    };

  swapDevices = [ ];

}
