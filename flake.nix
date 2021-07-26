{
  description = "NixOS configuration with flakes";

  # To update all inputs:
  # $ nix flake update .
  inputs = {
    nixpkgs.url = "github:Mic92/nixpkgs/master";

    lambda-pirate.url = "github:pogobanane/lambda-pirate";
    lambda-pirate.inputs.nixpkgs.follows = "nixpkgs";

    #home-manager.url = "github:rycee/home-manager/release-21.05";
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";

    #doom-emacs.url = "github:hlissner/doom-emacs";
    #doom-emacs.url = "github:Mic92/doom-emacs/org-msg";
    #doom-emacs.flake = false;

    retiolum.url = "github:Mic92/retiolum";
  };

  outputs = {
    self,
    nixpkgs,
    retiolum,
    lambda-pirate,
    #doom-emacs
  }: {
      nixosConfigurations = import ./configurations.nix {
        inherit nixpkgs retiolum lambda-pirate;
        nixosSystem = nixpkgs.lib.nixosSystem;
      };
  };
}

