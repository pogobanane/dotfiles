{pkgs ? import <nixpkgs> {} }:
  pkgs.mkShell {
    buildInputs = with pkgs; [
      nodejs
      nodePackages.npm
      node2nix

      # vue js specific
      # nodePackages.vue-cli # has been replaced by create-vue which is not packaged yet
      # nodePackages.vue-language-server
    ];
  }
