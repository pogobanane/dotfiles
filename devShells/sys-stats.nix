{pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    buildInputs = with pkgs; [
      # block IO monitoring
      iotop     # per process io rates
      sysstat   # iostat: per device io rates
      nfs-utils # nfsiostat
      ioping    # disk latencies
      ncdu      # du but as terminal UI

      # network IO monitoring
      iftop     # per peer network rates

      # general purpose
      htop      #
      bottom    # better htop

      # network state
      ethtool

      # power monitoring
      powertop

      # available hardware exploration
      dmidecode # -t {bios, chassis, cache, slot}
      pciutils # lspci -vmm
      inxi # aggregates hw infos
      lstopo # generates text or image hw layouts/trees
    ];
  }
