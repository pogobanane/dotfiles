{
  config,
  pkgs,
  inputs,
  flakepkgs,
  ...
}:
let
  neovim = flakepkgs.nvim2;
  nvim-appname = "poba-nvim";
  inherit (inputs.mic92-dotfiles.packages.${pkgs.hostPlatform.system}) treesitter-grammars;
  inherit (inputs.mic92-dotfiles.legacyPackages.${pkgs.hostPlatform.system}) nvim-lsp-packages;
in
{
  home.packages = nvim-lsp-packages ++ [ neovim ];
  # treesitter-grammars
  xdg.dataFile."nvim/site/parser".source = treesitter-grammars;

  home.activation.nvim = ''
    NVIM_APPNAME="${nvim-appname}"
    XDG_CONFIG_HOME=''${XDG_CONFIG_HOME:-$HOME/.config}
    NVIM_APPNAME=''${NVIM_APPNAME:-nvim}
    mkdir -p "$XDG_CONFIG_HOME/$NVIM_APPNAME"
    echo "${treesitter-grammars.rev}" > "$XDG_CONFIG_HOME/$NVIM_APPNAME/treesitter-rev"
    if [[ -f $XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json ]]; then
      if ! grep -q "${treesitter-grammars.rev}" "$XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"; then
        echo "Unexpected tree-sitter verion in $XDG_CONFIG_HOME/$NVIM_APPNAME/lazy-lock.json"
        echo "Expected version ${treesitter-grammars.rev}"
        exit 1
        ${neovim}/bin/nvim --headless "+Lazy! update" +qa
      fi
    fi
  '';

  xdg.dataFile."nvim/lib/libfzf.so".source = "${pkgs.vimPlugins.telescope-fzf-native-nvim}/build/libfzf.so";
}
