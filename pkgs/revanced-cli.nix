{ pkgs, ... }: 
pkgs.stdenv.mkDerivation {
  name = "revanced-cli";

  src = pkgs.fetchFromGitHub {
    owner = "revanced";
    repo = "revanced-cli";
    rev = "cf20efd467466f851a606a61b01c3ba256db6b3c";
    sha256 = "sha256-K8SL6wxRusctliHscEUXqJqC3nOhSr4fTUvKKzwhZ14=";
  };

  nativeBuildInputs = with pkgs; [
    gradle
  ];

  buildInputs = with pkgs; [
    jdk11_headless
  ];
}
