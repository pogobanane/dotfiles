{pkgs, ...}:
  pkgs.mkShell {
    buildInputs = with pkgs; [
      # block IO monitoring
      iotop     # per process io rates
      sysstat   # iostat: per device io rates
      nfs-utils # nfsiostat

      # network IO monitoring
      iftop     # per peer network rates

      # general purpose
      htop      #
      bottom    # better htop

    ];
  }
