{ config, pkgs, ... }:
{
  # passthrough setup
  virtualisation.libvirtd = {
    enable = true;
  };
  users.groups.libvirtd.members = [ "peter" ];
  #users.groups.input.members = [ "peter" ];

  environment.systemPackages = with pkgs; [
    virt-manager
    pciutils
  ];
}
