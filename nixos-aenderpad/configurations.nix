{ nixpkgs, lambda-pirate, nixosSystem, retiolum, home-manager, nixos-hardware }: {
  aenderpad = nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
      nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
      ./hardware-configuration.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
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
        ];
      })
    ];
  };

}

