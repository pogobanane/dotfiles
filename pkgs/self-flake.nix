{ stdenv, impure-debug-info, ... }:

stdenv.mkDerivation {
  name = "self-flake";

  src = ../.;

  preUnpack = ''
  ls -la
  ls -la $src
  ls -la ${impure-debug-info}
  '';

  installPhase = ''
  cp -r . $out/
  cp -r ${impure-debug-info} $out/impure-debug-info
  '';
}
