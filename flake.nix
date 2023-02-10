{
  description = "NixOS configuration with flakes";

  # To update all inputs:
  # $ nix flake update .
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:Nixos/nixpkgs/nixos-22.11";
    #unstablepkgs.url = "/home/peter/dev/nix/nixpkgs";
    unstablepkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    nur.url = github:nix-community/NUR;

    lambda-pirate.url = "github:pogobanane/lambda-pirate";
    lambda-pirate.inputs.nixpkgs.follows = "nixpkgs";

    ctile.url = "git+https://gitlab.com/pogobanane/gnome-ctile.git";
    ctile.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-22.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    #doom-emacs.url = "github:hlissner/doom-emacs";
    #doom-emacs.url = "github:Mic92/doom-emacs/org-msg";
    #doom-emacs.flake = false;

    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    retiolum.url = "github:Mic92/retiolum";

    tex2nix.url = "github:Mic92/tex2nix";
    tex2nix.inputs.utils.follows = "nixpkgs";

    discord-tar.url = "tarball+https://discord.com/api/download?platform=linux&format=tar.gz";
    discord-tar.flake = false;

    loc-src.url = "github:cgag/loc";
    loc-src.flake = false;

    fenix = {
      url = "github:nix-community/fenix/b3e5ce9985c380c8fe1b9d14879a14b749d1af51";
      # if we follow nixpkgs, nixpkgs updates will trigger a fenixPkgs.rust-analyzer rebuild
      #inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nur,
    unstablepkgs,
    retiolum,
    home-manager,
    lambda-pirate,
    nixos-hardware,
    #doom-emacs,
    sops-nix,
    flake-utils,
    fenix,
    ctile,
    tex2nix,
    discord-tar,
    loc-src
  }: let 
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
    fenixPkgs = fenix.packages.x86_64-linux;
    tex2nixPkgs = tex2nix.packages.x86_64-linux;
  in nixpkgs.lib.attrsets.recursiveUpdate
    (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      fenixPkgs = fenix.packages.${system};
    in {
      packages = {
        map-cmd = pkgs.callPackage ./pkgs/map.nix { };
        loc-git = pkgs.callPackage ./pkgs/loc.nix { inherit loc-src; };
        nixos-generations = pkgs.callPackage ./pkgs/nixos-generations.nix { };
        #webcord = if "${system}" == "x86_64-linux" then pkgs.callPackage ./pkgs/webcord-appimage.nix { } else null;
        #webcord = pkgs.callPackage ./pkgs/webcord-appimage.nix { };
      };
    }))
    (let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in {
      packages.x86_64-linux.webcord = pkgs.callPackage ./pkgs/webcord-appimage.nix { };
      packages.x86_64-linux.cider = pkgs.callPackage pkgs/cider.nix { };
      nixosConfigurations = import ./configurations.nix {
        inherit nixpkgs nur unstablepkgs lambda-pirate home-manager retiolum nixos-hardware sops-nix ctile 
        discord-tar
        ;
        nixosSystem = nixpkgs.lib.nixosSystem;
        flakepkgs = self.packages;
      };
      devShells.x86_64-linux = {
        default = pkgs.mkShell {
          buildInputs = with pkgs; [
            just
            nix-output-monitor
          ];
        };
        clang = pkgs.callPackage ./devShells/clang.nix { inherit pkgs; };
        containers = pkgs.callPackage ./devShells/containers.nix { inherit pkgs; };
        latex = pkgs.callPackage ./devShells/latex.nix { inherit pkgs; inherit tex2nixPkgs; };
        networking = pkgs.callPackage ./devShells/networking.nix { inherit pkgs; };
        node = pkgs.callPackage ./devShells/node.nix { inherit pkgs; };
        python = pkgs.callPackage ./devShells/python.nix { inherit pkgs; };
        rust = pkgs.callPackage ./devShells/rust.nix { inherit pkgs; inherit fenixPkgs; };
        sys-stats = pkgs.callPackage ./devShells/sys-stats.nix { inherit pkgs; };
      };
    });
}

