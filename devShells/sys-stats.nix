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
    ];
  }
