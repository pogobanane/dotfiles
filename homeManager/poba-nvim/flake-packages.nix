{ self, inputs, ...}: {
  perSystem = { inputs', pkgs, ... }: {
    packages = {
      nvim2 = inputs'.mic92-dotfiles.packages.nvim.override {
        nvim-appname = "poba-nvim";
        lua-config = ./config;
      };
    };
  };
}
