{
  description = "NixOS configuration with flakes";

  # To update all inputs:
  # $ nix flake update .
  inputs = {
    # nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable-small";
    nixpkgs.url = "/home/peter/dev/nix/nixpkgs";

    lambda-pirate.url = "github:pogobanane/lambda-pirate";
    lambda-pirate.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    #doom-emacs.url = "github:hlissner/doom-emacs";
    #doom-emacs.url = "github:Mic92/doom-emacs/org-msg";
    #doom-emacs.flake = false;

    retiolum.url = "github:Mic92/retiolum";
  };

  outputs = {
    self,
    nixpkgs,
    retiolum,
    home-manager,
    lambda-pirate,
    nixos-hardware,
    #doom-emacs
  }: {
      nixosConfigurations = import ./configurations.nix {
        inherit nixpkgs lambda-pirate home-manager retiolum nixos-hardware;
        nixosSystem = nixpkgs.lib.nixosSystem;
      };
  };
}

