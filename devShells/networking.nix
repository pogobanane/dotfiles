{pkgs, ...}:
  pkgs.mkShell {
    buildInputs = with pkgs; [
      bridge-utils
      tcpdump
    ];
  }
