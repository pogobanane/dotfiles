{ nixpkgs, nur, stablepkgs, lambda-pirate, nixosSystem, retiolum, home-manager, nixos-hardware, sops-nix, ctile }: {
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
        home-manager.users.peter = import ./users-hm/peter.nix;
      }
      {
        nixpkgs.overlays = [
          nur.overlay
          #(final: prev: {
            #sops = stablepkgs.legacyPackages.x86_64-linux.sops;
          #})
          (final: prev: {
            ctile = ctile.packages.x86_64-linux.ctile;
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
          #now managed by home-manager in ~/.config/nixpkgs/config.nix
          #"nur=${nur}"
        ];
      })
    ];
  };

}

