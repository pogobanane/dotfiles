{pkgs, ...}:
  pkgs.mkShell {
    buildInputs = with pkgs; [
      dive # inspect files of docker containers
      cntr

    ];
  }
