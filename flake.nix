{
  description = "NixOS configuration with flakes";

  nixConfig = {
    extra-substituters = [
      "https://nix-gaming.cachix.org"
      "https://tum-dse.cachix.org"
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "tum-dse.cachix.org-1:v67rK18oLwgO0Z4b69l30SrV1yRtqxKpiHodG4YxhNM="
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  # To update all inputs:
  # $ nix flake update .
  inputs = {
    #flake-utils.url = "github:numtide/flake-utils";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nixpkgs.url = "github:Nixos/nixpkgs/nixos-24.05";
    #nixpkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    #unstablepkgs.url = "/home/peter/dev/nix/nixpkgs";
    unstablepkgs.url = "github:Nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";

    lambda-pirate.url = "github:pogobanane/lambda-pirate";
    lambda-pirate.inputs.nixpkgs.follows = "nixpkgs";

    ctile.url = "git+https://gitlab.com/pogobanane/gnome-ctile.git";
    ctile.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    #doom-emacs.url = "github:hlissner/doom-emacs";
    #doom-emacs.url = "github:Mic92/doom-emacs/org-msg";
    #doom-emacs.flake = false;

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    retiolum.url = "github:Mic92/retiolum";

    tex2nix.url = "github:Mic92/tex2nix";
    tex2nix.inputs.utils.follows = "nixpkgs";

    discord-tar.url = "tarball+https://discord.com/api/download?platform=linux&format=tar.gz";
    discord-tar.flake = false;

    loc-src.url = "github:cgag/loc";
    loc-src.flake = false;

    hosthog.url = "github:pogobanane/hosthog/develop";
    hosthog.inputs.nixpkgs.follows = "nixpkgs";

    nix-top-src.url = "github:pogobanane/nix-top/dev/owner";
    nix-top-src.flake = false;

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    astro-nvim.url = "github:AstroNvim/AstroNvim/49d48171c22bcc1c3e67b36930f6b9c710f0c70c"; # pin to working version
    astro-nvim.flake = false;

    wondershaper-src.url = "github:magnific0/wondershaper";
    wondershaper-src.flake = false;


    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nix-gaming.url = "github:fufexan/nix-gaming";

    # TODO i cant get self to leak into peter.nix, so i leak self through this wtf, because inputs reach into peter.nix...
    wtf.url = "github:pogobanane/dotfiles";
    wtf.inputs.nixpkgs.follows = "nixpkgs";

    fenix = {
      url = "github:nix-community/fenix";
      # if we follow nixpkgs, nixpkgs updates will trigger a fenixPkgs.rust-analyzer rebuild
      #inputs.nixpkgs.follows = "nixpkgs";
    };

    impurity.url = "path:./modules/empty";
    impurity.flake = false;
  };

  outputs = {
    flake-parts,
    ...
  } @ inputs: flake-parts.lib.mkFlake
    { inherit inputs; }
    { 
      imports = [
        ./flake-packages.nix
        ./flake-configurations.nix
      ];
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ];
      perSystem = { ... }: {
        packages = {
        };
      };
      flake = {
        devShells.x86_64-linux = let 
          pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
          fenixPkgs = inputs.fenix.packages.x86_64-linux;
          tex2nixPkgs = inputs.tex2nix.packages.x86_64-linux;
          diskoPkgs = inputs.disko.packages.x86_64-linux;
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              just
              nix-output-monitor
              diskoPkgs.disko
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
      };
    };
}

