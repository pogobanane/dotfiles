{ stdenv, ... }:

stdenv.mkDerivation {
  name = "self-flake";

  src = ../.;

  installPhase = ''
    cp -r . $out/
  '';
}
