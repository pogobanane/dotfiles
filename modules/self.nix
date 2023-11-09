{ pkgs, ... }: let 
  self-flake = pkgs.callPackage ../pkgs/self-flake.nix { impure-debug-info = ../.; };
in {

  systemd.tmpfiles.rules = [
    "L+ /etc/nixos - - - - ${self-flake}"
  ];
}
