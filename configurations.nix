{ nixpkgs, lambda-pirate, nixosSystem, }: { # retiolum 
  aendernix = nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      {
        imports = [
          #retiolum.nixosModules.retiolum
          #lambda-pirate.nixosModules.knative
          #lambda-pirate.nixosModules.vhive
        ];
      }
    ];
  };

}

