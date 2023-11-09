{ nixpkgs
, nur
, unstablepkgs
, flakepkgs
, lambda-pirate
, nixosSystem
, retiolum
, home-manager
, nixos-hardware
, sops-nix
, nix-index-database
, astro-nvim
, ctile
, discord-tar
, inputs
, self
, ...
}:
let
  extraArgs = [
    ({ pkgs, ... }: {
      config._module.args = {
        #   # This is the new, hip extraArgs.
        flakepkgs = flakepkgs.${pkgs.hostPlatform.system};
      };
    })
  ];
  specialArgs = {
    inherit inputs;
    inherit self;
  };
in
{
  aendernix = nixosSystem rec {
    system = "x86_64-linux";
    modules = extraArgs ++ [
      ./hardware-aendernix.nix
      ./aendernix.nix
      ./config-common.nix
    ];
    inherit specialArgs;
  };
  aenderpad = nixosSystem rec {
    system = "x86_64-linux";
    modules = extraArgs ++ [
      ./hardware-aenderpad.nix
      ./aenderpad.nix
      nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
      ./config-common.nix
    ];
    inherit specialArgs;
  };

}
