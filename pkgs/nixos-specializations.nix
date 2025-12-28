{ pkgs, stdenv, ... }:
# stdenv.mkDerivation {
#   name = "nixos-specializations";
#   runtimeInputs = [ pkgs.bash ];
#   src = ./.;
#   skipUnpack = true;
#   installPhase = ''
#     ls
#     mkdir -p $out/bin
#     cp ./nixos-specializations $out/bin/nixos-specializations
#   '';
# }
pkgs.writeShellApplication {
  name = "nixos-specializations";
  # runtimeInputs = [ pkgs.];
  text = ./nixos-specializations;
}
