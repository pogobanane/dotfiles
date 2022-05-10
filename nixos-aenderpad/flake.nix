{
  description = "NixOS configuration with flakes";

  # To update all inputs:
  # $ nix flake update .
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    # nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-21.11";
    # nixpkgs.url = "/home/peter/dev/nix/nixpkgs";
    stablepkgs.url = "github:Nixos/nixpkgs/nixos-21.11";
    nur.url = github:nix-community/NUR;

    lambda-pirate.url = "github:pogobanane/lambda-pirate";
    lambda-pirate.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-21.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    #doom-emacs.url = "github:hlissner/doom-emacs";
    #doom-emacs.url = "github:Mic92/doom-emacs/org-msg";
    #doom-emacs.flake = false;

    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    retiolum.url = "github:Mic92/retiolum";

    fenix = {
      url = "github:nix-community/fenix/b3e5ce9985c380c8fe1b9d14879a14b749d1af51";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nur,
    stablepkgs,
    retiolum,
    home-manager,
    lambda-pirate,
    nixos-hardware,
    #doom-emacs,
    sops-nix,
    flake-utils,
    fenix
  }: {
      nixosConfigurations = import ./configurations.nix {
        inherit nixpkgs nur stablepkgs lambda-pirate home-manager retiolum nixos-hardware sops-nix;
        nixosSystem = nixpkgs.lib.nixosSystem;
      };
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      fenixPkgs = fenix.packages.${system};
    in {
      devShells = {
        sys-stats = pkgs.callPackage ./devShells/sys-stats.nix { inherit pkgs; };
        rust = pkgs.callPackage ./devShells/rust.nix { inherit pkgs; inherit fenixPkgs; };
      };
    }));
}

