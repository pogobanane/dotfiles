{pkgs, tex2nixPkgs}:
  pkgs.mkShell {
    buildInputs = with pkgs; [
      texlab # lang serv
      tex2nixPkgs.tex2nix
      (texlive.combine { inherit (texlive) scheme-small latexmk latexindent; })
    ];
  }
