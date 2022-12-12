{ lib, config, pkgs, ... }: let 
  self-flake = pkgs.callPackage ../pkgs/self-flake.nix {};
in {

  systemd.tmpfiles.rules = [
    "L+ /run/current-system-flake - - - - ${self-flake}"
  ];
}
