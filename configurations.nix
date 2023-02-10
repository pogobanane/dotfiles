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
, ctile
, discord-tar 
}: let 
  common-modules = [
      ./config-common.nix
      sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = {
          inherit sops-nix;
          inherit nur;
          inherit nixpkgs;
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

        nix.nixPath = [
          "nixpkgs=${pkgs.path}"
          "home-manager=${home-manager}"
          # "nur=${nur}" #now managed by home-manager in ~/.config/nixpkgs/config.nix:
        ];
      })
      {
        nixpkgs.overlays = [
          nur.overlay
          (final: prev: {
            ctile = ctile.packages.x86_64-linux.ctile;
            nextcloud-client = unstablepkgs.legacyPackages.x86_64-linux.nextcloud-client;
            wezterm = unstablepkgs.legacyPackages.x86_64-linux.wezterm;
            #nextcloud-client = nixpkgs.legacyPackages.x86_64-linux.libsForQt5.callPackage pkgs/nextcloud-client { };
            #chromium = unstablepkgs.legacyPackages.x86_64-linux.chromium;
            #slack = unstablepkgs.legacyPackages.x86_64-linux.slack;
            #cider = unstablepkgs.legacyPackages.x86_64-linux.cider;
            cider = nixpkgs.legacyPackages.x86_64-linux.callPackage pkgs/cider.nix {};
            webcord = flakepkgs.x86_64-linux.webcord;
            #loc = flakepkgs.x86_64-linux.loc;
            #discord = unstablepkgs.legacyPackages.x86_64-linux.discord;
            discord = prev.discord.overrideAttrs (_: { 
              src = discord-tar; 
              unpackCmd = "tar -xzf $curSrc";
            });
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

