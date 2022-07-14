{pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    buildInputs = with pkgs; [
      tex2nix
      texlive.latexmk
      texlive.latexindent
      texlab # lang serv
    ];
  }
