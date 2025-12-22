{ self, inputs, ...}: {
  perSystem = { inputs', pkgs, ... }: let
      inherit (inputs.mic92-dotfiles.packages.${pkgs.stdenv.hostPlatform.system}) treesitter-grammars;
    in {
    packages = {
      nvim2 = inputs'.mic92-dotfiles.packages.nvim.override rec {
        nvim-appname = "poba-nvim";
        lua-config = (pkgs.runCommand "${nvim-appname}-config" {} ''
          mkdir -p ./config
          cp -r ${./config}/* ./config
          chmod -R u+w config

          # set treesitter version everywhere
          echo "${treesitter-grammars.rev}" > ./config/treesitter-rev
          ${pkgs.jq}/bin/jq '."nvim-treesitter"."commit" |= "${treesitter-grammars.rev}"' < ${./config/lazy-lock.json} > ./config/lazy-lock.json

          mkdir -p $out
          cp -Tr ./config $out
        '');
      };
    };
  };
}
