{
  description = "NixOS configuration with flakes";

  # To update all inputs:
  # $ nix flake update .
  inputs = {
    nixpkgs.url = "github:Mic92/nixpkgs/master";

    #home-manager.url = "github:rycee/home-manager/release-21.05";
    #home-manager.inputs.nixpkgs.follows = "nixpkgs";

    retiolum.url = "github:Mic92/retiolum";
  };

  outputs = {
    self,
    nixpkgs,
    retiolum,
  }: {
      nixosConfigurations = import ./configurations.nix {
        inherit nixpkgs retiolum;
        nixosSystem = nixpkgs.lib.nixosSystem;
      };
  };
}

