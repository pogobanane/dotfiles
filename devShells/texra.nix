{ nixpkgs, ... }: let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
in pkgs.mkShell {
    buildInputs = with pkgs; [
      # my latex environment:
      texlab # lang serv
      biber # needed for biblatex
      texliveFull
      # (texlive.combine { inherit (texlive) scheme-small latexmk latexindent; })

      # vscode (with extensions required for texra):
      (vscode-with-extensions.override {
        vscodeExtensions = with vscode-extensions; [
          # jnoortheen.nix-ide
          # ms-python.python
          # ms-azuretools.vscode-docker
          # ms-vscode-remote.remote-ssh
          vscode-extensions.james-yu.latex-workshop
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "texra";
            publisher = "texra-ai";
            version = "0.35.3";
            sha256 = "sha256-LWgpzz/QveBUYotUfQ5pCbNLONaousPjFfX16dkpToY=";
          }
        ];
      })

      # system dependencies fo texra (excluding latex)
      graphicsmagick # for LLMs to do graphics
      ghostscript


    ];
  }

