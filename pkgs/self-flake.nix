{ self, stdenv, impure-debug-info, ... }:

stdenv.mkDerivation {
  name = "self-flake";

  src = ../.;

  preUnpack = ''
  ls -la
  ls -la $src
  ls -la ${self}
  '';

  dontFixup = true;

  installPhase = ''
  cp -r . $out/
  # cp -r ${self} $out/impure-debug-info
  '';
}
