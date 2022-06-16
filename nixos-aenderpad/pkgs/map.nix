# delete this once map-cmd is available in nixpkgs
# https://github.com/NixOS/nixpkgs/pull/176552/files
{ lib, stdenv, fetchFromGitHub }:

stdenv.mkDerivation rec {
  pname = "map";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "soveran";
    repo = "map";
    rev = version;
    sha256 = "sha256-yGzmhZwv1qKy0JNcSzqL996APQO8OGWQ1GBkEkKTOXA=";
  };

  makeFlags = [ "PREFIX=$(out)" ];

  postInstall = ''
    mkdir -p "$out/share/doc/${pname}"
    cp README* LICENSE "$out/share/doc/${pname}"
  '';

  meta = with lib; {
    description = "Map lines from stdin to commands";
    homepage = "https://github.com/soveran/map";
    license = licenses.bsd2;
    maintainers = with maintainers; [ pogobanane ];
    platforms = platforms.unix;
  };
}
