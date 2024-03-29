# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ inputs, modulesPath, ... }:

{
  imports =
    [ 
    (modulesPath + "/installer/scan/not-detected.nix")
    inputs.disko.nixosModules.disko
    ./disko-aendernext.nix
  ];


  # as soon as i upgrade 5.16
  # also: upstream it https://github.com/NixOS/nixos-hardware/pull/438
  #boot = lib.mkIf (lib.versionAtLeast config.boot.kernelPackages.kernel.version "5.17") {
  #  kernelParams = [ "initcall_blacklist=acpi_cpufreq_init" ];
  #  kernelModules = [ "amd-pstate" ];
  #};

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.supportedFilesystems = [ "ntfs" ];

  services.hardware.bolt.enable = true;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "usb_storage" "usbhid"];
  boot.initrd.kernelModules = [ ];
  # with linux 5.10 lts, BT audio works. With latest it doesnt.
  boot.kernelModules = [ "kvm-amd" ];
  # boot.kernelPackages = pkgs.linuxPackages; # _latest; 
  #boot.kernelPackages = pkgs.lib.mkDefault config.boot.zfs.package.latestCompatibleLinuxPackages;
  #boot.kernelPackages = let
  #    linux = pkgs.linuxPackages;
  #  in
  #    pkgs.lib.mkDefault (pkgs.recurseIntoAttrs linux);
  boot.extraModulePackages = [ ];

  # page compression because swap on zfs partitions is a bit dangerous.
  # disable, because it still leads to an unresponsive system, once many gigabyte are swapped.
  #zramSwap.enable = true;

  # only kills cgroups. So either systemd services marked for killing under OOM, or (disabled by default) the entire user slice.
  systemd.oomd.extraConfig = { 
    DefaultMemoryPressureDurationSec = "10s"; 
  };

  # configure /proc/sys/* values
  # https://docs.kernel.org/admin-guide/sysrq.html?highlight=sysrq+trigger#how-do-i-use-the-magic-sysrq-key
  boot.kernel.sysctl = {
    # sysrq allows to trigger kernel actions via alt+printscr+char
    "kernel.sysrq" = 64; # permit term e, kill i, oom-kill f
    # "vm.swappiness" = 60;
  };

  # service to kill processes when memory is low
  services.earlyoom = {
    enable = true;
    # freeMemThreshold = 10; # 10 is default
    enableNotifications = true;
  };

  swapDevices = [ ];

}
