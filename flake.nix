{
  description = "NixOS configuration with flakes";

  # To update all inputs:
  # $ nix flake update .
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    # nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-22.05";
    # nixpkgs.url = "/home/peter/dev/nix/nixpkgs";
    stablepkgs.url = "github:Nixos/nixpkgs/nixos-22.05";
    nur.url = github:nix-community/NUR;

    lambda-pirate.url = "github:pogobanane/lambda-pirate";
    lambda-pirate.inputs.nixpkgs.follows = "nixpkgs";

    ctile.url = "git+https://gitlab.com/pogobanane/gnome-ctile.git";
    ctile.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    #doom-emacs.url = "github:hlissner/doom-emacs";
    #doom-emacs.url = "github:Mic92/doom-emacs/org-msg";
    #doom-emacs.flake = false;

    sops-nix.url = github:Mic92/sops-nix/feat/home-manager;
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
    fenix,
    ctile,
  }: let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    fenixPkgs = fenix.packages.x86_64-linux;
  in {
      nixosConfigurations = import ./configurations.nix {
        inherit nixpkgs nur stablepkgs lambda-pirate home-manager retiolum nixos-hardware sops-nix ctile;
        nixosSystem = nixpkgs.lib.nixosSystem;
      };
      devShells.x86_64-linux = { 
        containers = pkgs.callPackage ./devShells/containers.nix { inherit pkgs; };
        latex = pkgs.callPackage ./devShells/latex.nix { inherit pkgs; };
        networking = pkgs.callPackage ./devShells/networking.nix { inherit pkgs; };
        node = pkgs.callPackage ./devShells/node.nix { inherit pkgs; };
        python = pkgs.callPackage ./devShells/python.nix { inherit pkgs; };
        rust = pkgs.callPackage ./devShells/rust.nix { inherit pkgs; inherit fenixPkgs; };
        sys-stats = pkgs.callPackage ./devShells/sys-stats.nix { inherit pkgs; };
      };
    }
    // (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      fenixPkgs = fenix.packages.${system};
    in {
      packages = {
        map-cmd = pkgs.callPackage ./pkgs/map.nix { };
        nixos-generations = pkgs.callPackage ./pkgs/nixos-generations.nix { };
      };
    }));
}

