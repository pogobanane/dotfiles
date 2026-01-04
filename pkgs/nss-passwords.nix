{pkgs ? <nixpkgs>} :

pkgs.stdenv.mkDerivation {
  name = "nss-passwords";

  src = pkgs.fetchFromGitHub {
    owner = "glondu";
    repo = "nss-passwords";
    rev = "fbcc5dbfd0820e62e746fefd8e6c9a6755a95465";
    sha256 = "sha256-3hiW5wAIm7tzbFTdachMOyGdQKnn71PNMb1vupCwBBs=";
  };

  patchPhase = ''
    substituteInPlace stubs/nss_stubs.c --replace "#include <nss/" "#include <"
    substituteInPlace stubs/nss_stubs.c --replace "#include <nspr/" "#include <"
  '';


  nativeBuildInputs = with pkgs; [
    dune
    ocamlPackages.findlib
    ocamlPackages.dune-configurator
    ocaml
    nss
    ocamlPackages.ppx_yojson_conv
    ocamlPackages.ocaml_sqlite3
    ocamlPackages.fileutils
    pkg-config
    nss.dev
    nspr
    nspr.dev
  ];

  NIX_CFLAGS_COMPILE="-isystem ${pkgs.nspr.dev}/include";

  buildInputs = with pkgs; [
    ocaml
    nss
    ocamlPackages.ppx_yojson_conv
    ocamlPackages.ocaml_sqlite3
    ocamlPackages.fileutils
  ];

  buildPhase = ''
    dune build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp -r _build/default/main.exe  $out/bin/nss-passwords
  '';

  meta = with pkgs.lib; {
    description = "NSS module to store passwords in an encrypted database";
    homepage = "https://directory.fsf.org/wiki/Nss-passwords";
    broken = true; # builds, but does not find passwords
  };
}

