{ self, pkgs, inputs, ...}: {
  flake = {
        homeConfigurations.peter = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./users-hm/peter.nix
            ./users-hm/gui.nix
          ];
          extraSpecialArgs = {
            inputs = inputs;
            inherit (inputs) sops-nix nur nixpkgs;
            username = "peter";
            homeDirectory = "/home/peter";
            my-gui = true;
          };
        };
        homeConfigurations.peter-doctor-cluster = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./users-hm/peter.nix
          ];
          extraSpecialArgs = {
            inputs = inputs;
            inherit (inputs) sops-nix nur nixpkgs;
            username = "okelmann";
            homeDirectory = "/home/okelmann";
            my-gui = false;
          };
        };
        nixosConfigurations = import ./configurations.nix ({
          nixosSystem = inputs.nixpkgs.lib.nixosSystem;
          flakepkgs = self.packages;
          inputs = inputs;
        } // inputs);
};
  }
