{config, lib, ...}: let
  #external = "wlan0";
  # external = "wlp3s0";
  external = "enp4s0f3u1u1"; # docking station home
in {
  systemd.network.netdevs.virbr.netdevConfig = {
    Name = "virbr";
    Kind = "bridge";
  };
  systemd.network.netdevs.internal.netdevConfig = {
    Name = "internal";
    Kind = "bridge";
  };
  systemd.network.networks = {
    internal.extraConfig = ''
      [Match]
      Name=internal
      [Network]
      Address=192.168.32.1/24
      Address=192.168.32.50/24
      LLMNR=true
      LLDP=true
    '';
  };
  networking.hosts = let 
    tld = "schreinerei-baumann.de";
  in {
    "192.168.32.32" = [
      "${tld}"
      "nextcloud.${tld}"
      "gitlab.${tld}"
      "warmap.${tld}"
      "okelmann-peter.${tld}"
      "pogobanane.${tld}"
      "oldhq.${tld}"
    ];
  };


  # Add any internal interface with the following command:
  # $ nmcli dev set eth0 managed no
  # $ ip link set eth0 master internal
  # to disable again:
  # $ ip link set eth0 nomaster && nmcli dev set eth0 managed yes
  services.dnsmasq.enable = !config.virtualisation.libvirtd.enable;
  services.dnsmasq.resolveLocalQueries = lib.mkDefault false; # don't use it locally for dns
  services.dnsmasq.settings = {
    interface = "internal";
    listen-address = "127.0.0.1";
    dhcp-range= [ "192.168.32.50,192.168.32.100,12h" ];
    # disable dns
    port = 0;
    ## no gateway
    #dhcp-option=3
    ## no dns
    #dhcp-option=6
    ## static leases
    #dhcp-host=52:54:00:1d:e1:33,192.168.32.2
    #dhcp-host=52:54:00:8f:73:d7,192.168.32.3
    dhcp-host= [ "22:11:11:11:11:22,192.168.32.32" ];
  };

  networking.nat = {
    enable = true;
    externalInterface = external;
    internalInterfaces = ["internal"];
    # dmzHost = "192.168.32.32";
    # dmzHost = "192.168.178.147";
    # forwardPorts = [
      # {
      #   destination = "192.168.178.147:80";
      #   proto = "tcp";
      #   sourcePort = 80;
      # }
      #{
        #destination = "192.168.32.32:443";
        #proto = "tcp";
        #sourcePort = 443;
      #}
    # ];
  };
  networking.firewall.enable = false;

  networking.firewall.allowedTCPPorts = [
    # pixiecore
    64172
  ];
  networking.firewall.allowedUDPPorts = [
    # pixiecore
    69
    4011
    # dnsmasq
    53
    67
  ];
}
