{ self, inputs, ...}: let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
in {
  # TODO: merge this file somehow with the home config as stated in configuration.nix
  systems = [ system ];
  perSystem = { config, self', inputs', pkgs, system, ... }: {
      apps = {
        doctor-home = {
          type = "app";
          program = "${self'.packages.flake-app-doctor-home}/bin/flake-app-doctor-home";
        };
      };
      packages = {
        flake-app-doctor-home = pkgs.writeScriptBin "flake-app-doctor-home" ''
          ${self.homeConfigurations.peter-doctor-cluster.activationPackage}/activate
        '';
      };
  };
  flake = {
        homeConfigurations.peter = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./users-hm/peter.nix
          ];
          extraSpecialArgs = {
            inputs = inputs;
            inherit (inputs) sops-nix nur nixpkgs nix-index-database astro-nvim;
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
            inherit (inputs) sops-nix nur nixpkgs nix-index-database astro-nvim;
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
