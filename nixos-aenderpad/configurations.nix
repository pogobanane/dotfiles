{ nixpkgs, lambda-pirate, nixosSystem, retiolum, home-manager }: {
  aenderpad = nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      home-manager.nixosModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.peter = import ./users-hm/peter.nix;
      }
      ({ pkgs, ... }: {
        imports = [
          #retiolum.nixosModules.retiolum
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

