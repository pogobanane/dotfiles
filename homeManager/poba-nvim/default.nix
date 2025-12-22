{
  config,
  pkgs,
  inputs,
  flakepkgs,
  ...
}:
let
  neovim = flakepkgs.nvim2;
  # neovim = inputs.mic92-dotfiles.packages.${pkgs.hostPlatform.system}.nvim;
  nvim-appname = "poba-nvim";
  inherit (inputs.mic92-dotfiles.packages.${pkgs.hostPlatform.system}) nvim-treesitter-plugins;
  inherit (inputs.mic92-dotfiles.packages.${pkgs.hostPlatform.system}) nvim-install-treesitter;
  # inherit (inputs.mic92-dotfiles.legacyPackages.${pkgs.hostPlatform.system}) nvim-lsp-packages;
  nvim-lsp-packages = with pkgs; [
            nodejs # copilot

            # based on ./suggested-pkgs.json
            basedpyright
            bash-language-server
            clang-tools
            golangci-lint
            gopls
            lua-language-server
            marksman
            nil
            nixd
            nixfmt-rfc-style
            prettierd
            ruff
            selene
            shellcheck
            shfmt
            stylua
            vtsls
            yaml-language-server
            vscode-langservers-extracted
            # based on https://github.com/ray-x/go.nvim#go-binaries-install-and-update
            go
            delve
            ginkgo
            gofumpt
            golines
            gomodifytags
            gotests
            gotestsum
            gotools
            govulncheck
            iferr
            impl

            # others
            rust-analyzer
            clippy
            rustfmt

            zls
            terraform-ls
            taplo
            typos
            typos-lsp
          ];
in
{
  home.packages = [ (inputs.mic92-dotfiles.packages.${pkgs.hostPlatform.system}.nvim.override {
    inherit nvim-appname;
    inherit nvim-lsp-packages;
    # nvim-lsp-packages = [];
    lua-config = (pkgs.runCommand "${nvim-appname}-config" {} ''
      mkdir -p ./config
      cp -r ${./config}/* ./config
      chmod -R u+w config

      # set treesitter version everywhere
      echo "${nvim-install-treesitter.rev}" > ./config/treesitter-rev
      ${pkgs.jq}/bin/jq '."nvim-treesitter"."commit" |= "${nvim-install-treesitter.rev}"' < ${./config/lazy-lock.json} > ./config/lazy-lock.json

      mkdir -p $out
      cp -Tr ./config $out
    '');
  }) ];
  # home.packages = nvim-lsp-packages ++ [ neovim ];
  # xdg.dataFile."nvim/site/parser".source = nvim-treesitter-plugins;

  # home.activation.nvim = ''
  #   NVIM_APPNAME="${nvim-appname}"
  #   XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
  #   NVIM_APPNAME=''${NVIM_APPNAME:-nvim}
  #   mkdir -p "$XDG_CONFIG_HOME/$NVIM_APPNAME"
  #   echo "${nvim-treesitter-plugins.rev}" > "$XDG_CONFIG_HOME/$NVIM_APPNAME/treesitter-rev"
  #   if [[ -f $XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json ]]; then
  #     if ! grep -q "${nvim-treesitter-plugins.rev}" "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"; then
  #       echo "Unexpected tree-sitter verion in $XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"
  #       echo "Expected version ${nvim-treesitter-plugins.rev}"
  #       exit 1
  #       ${neovim}/bin/nvim --headless "+Lazy! update" +qa
  #     fi
  #   fi
  # '';

  # xdg.dataFile."nvim/lib/libfzf.so".source = "${pkgs.vimPlugins.telescope-fzf-native-nvim}/build/libfzf.so";
}
