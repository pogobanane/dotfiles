{ pkgs, lib, config, ... }:
{
  options = {
    boot.hideR7240 = lib.mkOption {
      type = lib.types.bool;
      default = true;
      example = false;
      description = "Whether to bind that AMD GPU to vfio at boot";
    };
  };

  config = {
    networking.hostName = "aendernix"; # Define your hostname.
    networking.hostId = "faae4fe4"; # for zfs
    networking.retiolum = {
      ipv4 = "10.243.29.172";
      ipv6 = "42:0:3c46:f14:26a0:7b5e:349f:7f0b";
    };

    specialisation = {
      hideR7240 = {
        inheritParentConfig = true;
        configuration = {
          boot.hideR7240 = false;
        };
      };
    };

    # passthrough setup
    virtualisation.libvirtd = {
      enable = true;
    };
    boot.kernelParams = [
      # spdk/dpdk hugepages
      "default_hugepagesz=1G"
      "hugepagesz=1G"
      "hugepages=16"
    ] ++ lib.optionals config.boot.hideR7240 [
      "vfio-pci.ids=1002:699f" # TODO nixify this parameter so that it gets properly merged with other definitions
    ];
    users.groups.libvirtd.members = [ "peter" ];
    #users.groups.input.members = [ "peter" ];

    environment.systemPackages = with pkgs; [
      virt-manager
      pciutils
      heroic # epic and gog launcher
      telegram-desktop

      # do i really need these?
      wine
      winetricks
      dxvk
      lutris

      # libvirt
      swtpm
    ];
  };
}
