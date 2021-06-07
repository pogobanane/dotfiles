{ nixpkgs, nixosSystem, retiolum }: {
  aendernix = nixosSystem {
    system = "x86_64-linux";
    modules = [
      ./configuration.nix
      ./hardware-configuration.nix
      {
        imports = [
          retiolum.nixosModules.retiolum
        ];
      }
    ];
  };

}

