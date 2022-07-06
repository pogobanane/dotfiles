{ pkgs, stdenv, ... }: 
stdenv.mkDerivation {
  name = "nixos-generations";
  runtimeInputs = [ pkgs.perl pkgs.perlPackages.GetoptLong ];
  src = ./.;
  skipUnpack = true;
  installPhase = ''
    ls
    mkdir -p $out/bin
    cp ./nixos-generations $out/bin/nixos-generations
  '';
}
# for some reason GetoptLong does not work with writeShellApp
# nixos-generations-broken = pkgs.writeShellApplication {
#   name = "nixos-generations2";
#   runtimeInputs = [ pkgs.perl pkgs.perlPackages.GetoptLong ];
#   text = ./users-hm/nixos-generations;
# };
