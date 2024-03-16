{ config
, pkgs
, astro-nvim
, ...
}:
let
  # inherit (self.packages.${pkgs.hostPlatform.system}) astro-nvim-config nvim-open;
  astro-nvim-config = pkgs.callPackage ./astro-nvim-config.nix { inherit astro-nvim; };
  nvim-open = pkgs.python3Packages.callPackage ./nvim-open.nix { };

in
{
  home.packages = [ astro-nvim-config.neovim nvim-open ] ++ astro-nvim-config.lspPackages;
  xdg.dataHome = "${config.home.homeDirectory}/.data";
  xdg.dataFile."nvim/lazy/telescope-fzf-native.nvim/build/libfzf.so".source = "${pkgs.vimPlugins.telescope-fzf-native-nvim}/build/libfzf.so";
  # check the symlinking in nvim-standalone.nix on what link needs to actually exist for libfzf to work
  xdg.configFile."nvim".source = astro-nvim-config;
}
