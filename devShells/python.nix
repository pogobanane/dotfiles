{pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    buildInputs = with pkgs.python3.pkgs; [
      black # auto formatting
      flake8 # annoying "good practice" annotations
      mypy # static typing
      pkgs.ruff # language server ("linting")
    ];
  }
