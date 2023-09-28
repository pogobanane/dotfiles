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
, dotfiles
, ...
}: let 
  common-modules = [
      ./config-common.nix
      ({ config._module.args = {
        # This is the new, hip extraArgs.
        inherit inputs;
      };})
      sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit sops-nix;
          inherit nix-index-database;
          inherit nur;
          inherit nixpkgs;
          inherit astro-nvim;
          inherit inputs;
          username = "peter";
          homeDirectory = "/home/peter";
          my-gui = true;
        };
        home-manager.users.peter = import ./users-hm/peter.nix;
      }
      ({ pkgs, ... }: {
        imports = [
          retiolum.nixosModules.retiolum
          retiolum.nixosModules.ca
          #lambda-pirate.nixosModules.knative
          #lambda-pirate.nixosModules.vhive
        ];

        # for legacy:
        nix.nixPath = [
          "nixpkgs=${pkgs.path}"
          "home-manager=${home-manager}"
          "dotfiles=${dotfiles}"
          # "nur=${nur}" #now managed by home-manager in ~/.config/nixpkgs/config.nix:
        ];
        # for flakes:
        nix.registry = {
          dotfiles = {
            from = { type = "indirect"; id = "dotfiles"; };
            to = {
              owner = "pogobanane";
              repo = "dotfiles";
              type = "github";
            };
            exact = false;
          };
          dotfilesLocal = {
            from = { type = "indirect"; id = "dotfilesLocal"; };
            to = {
              path = "/home/peter/dev/dotfiles";
              type = "path";
            };
            exact = false;
          };
        };
      })
      {
        nixpkgs.overlays = [
          nur.overlay
          (final: prev: {
            ctile = ctile.packages.x86_64-linux.ctile;
            nerdfonts = unstablepkgs.legacyPackages.x86_64-linux.nerdfonts;
            nextcloud-client = unstablepkgs.legacyPackages.x86_64-linux.nextcloud-client; wezterm = unstablepkgs.legacyPackages.x86_64-linux.wezterm; #nextcloud-client = nixpkgs.legacyPackages.x86_64-linux.libsForQt5.callPackage pkgs/nextcloud-client { }; #chromium = unstablepkgs.legacyPackages.x86_64-linux.chromium;
            #slack = unstablepkgs.legacyPackages.x86_64-linux.slack;
            #cider = unstablepkgs.legacyPackages.x86_64-linux.cider;
            cider = flakepkgs.x86_64-linux.cider;
            webcord = flakepkgs.x86_64-linux.webcord;
            #loc = flakepkgs.x86_64-linux.loc-git;
            #discord = unstablepkgs.legacyPackages.x86_64-linux.discord;
            discord = prev.discord.overrideAttrs (_: { 
              src = discord-tar; 
              unpackCmd = "tar -xzf $curSrc";
            });
            alacritty = unstablepkgs.legacyPackages.x86_64-linux.alacritty;
          })
          #(self: super: { 
            #cider = super.cider.overrideAttrs (old: rec {
              #name = "cider-mine-${version}";
              #version = "1.5.6";
              #src = super.fetchurl rec {
                #url = "https://github.com/ciderapp/cider-releases/releases/download/v${version}/Cider-${version}.AppImage";
                #sha256 = "sha256-gn0dRoPPolujZ1ukuo/esSLwbhiPdcknIe9+W6iRaYw=";
              #};
            #});
          #})
        ];
      }
  ];
in {
  aendernix = nixosSystem {
    system = "x86_64-linux";
    modules = common-modules ++ [
      ./hardware-aendernix.nix
      ./aendernix.nix
    ];
  };
  aenderpad = nixosSystem {
    system = "x86_64-linux";
    modules = common-modules ++ [
      ./hardware-aenderpad.nix
      ./aenderpad.nix
      nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
    ];
  };

}

