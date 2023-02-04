{ config, pkgs, ... }:
{
  networking.hostName = "aendernix"; # Define your hostname.
  networking.hostId = "faae4fe4"; # for zfs
  #networking.retiolum = {
    #ipv4 = "10.243.29.201";
    #ipv6 = "42:0:3c46:2aad:ed1e:33cf:aece:d216";
  #};

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
