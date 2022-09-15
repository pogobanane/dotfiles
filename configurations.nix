{ nixpkgs, nur, unstablepkgs, lambda-pirate, nixosSystem, retiolum, home-manager, nixos-hardware, sops-nix, ctile }: {
  aenderpad = nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
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
      {
        nixpkgs.overlays = [
          nur.overlay
          (final: prev: {
            ctile = ctile.packages.x86_64-linux.ctile;
            nextcloud-client = unstablepkgs.legacyPackages.x86_64-linux.nextcloud-client;
          })
        ];
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
    ];
  };

}

