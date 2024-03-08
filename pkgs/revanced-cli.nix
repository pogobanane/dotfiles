{ pkgs, ... }: 
pkgs.stdenv.mkDerivation {
  buildInputs = with pkgs; [
    jdk17_headless
  ];
}
