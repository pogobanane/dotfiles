{ stdenv, ... }:

stdenv.mkDerivation rec {
  name = "self-flake";

  src = ../.;

  installPhase = ''
    cp -r . $out/
  '';
}
