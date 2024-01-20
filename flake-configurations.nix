{ self, inputs, ...}: let
  system = "x86_64-linux";
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  flakepkgs = self.packages.${pkgs.hostPlatform.system};
  extraArgs = [
    ({ pkgs, ... }: {
      config._module.args = {
        #   # This is the new, hip extraArgs.
        inherit flakepkgs;
      };
    })
  ];
  specialArgs = {
    inherit inputs;
    inherit self;
  };
  nixosSystem = inputs.nixpkgs.lib.nixosSystem;
in {
  # TODO: merge this file somehow with the home config as stated in configuration.nix
  systems = [ system ];
  perSystem = { self', pkgs, ... }: {
      apps = {
        doctor-home = {
          type = "app";
          program = "${self.packages.${system}.flake-app-doctor-home}/bin/flake-app-doctor-home";
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
            ./homeManager/peter.nix
          ];
          extraSpecialArgs = {
            # inputs = inputs; # TODO why does this still arrive in peter.nix?
            # flakepkgs = pkgs; # TODO why does this not arrive in peter.nix?
            inherit (inputs) sops-nix nur nixpkgs nix-index-database astro-nvim;
            username = "peter";
            homeDirectory = "/home/peter";
            my-gui = true;
          };
        };

        homeConfigurations.peter-doctor-cluster = inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./homeManager/peter.nix
          ];
          extraSpecialArgs = {
            inputs = inputs;
            inherit (inputs) sops-nix nur nixpkgs nix-index-database astro-nvim;
            username = "okelmann";
            homeDirectory = "/home/okelmann";
            my-gui = false;
          };
        };

        nixosConfigurations.aendernix = nixosSystem {
          system = "x86_64-linux";
          modules = extraArgs ++ [
            ./hardware-aendernix.nix
            ./aendernix.nix
            ./config-common.nix
            ./modules/gnome.nix
          ];
          inherit specialArgs;
        };

        nixosConfigurations.aenderpad = nixosSystem {
          system = "x86_64-linux";
          modules = extraArgs ++ [
            ./hardware-aenderpad.nix
            ./aenderpad.nix
            inputs.nixos-hardware.nixosModules.lenovo-thinkpad-e14-amd
            ./config-common.nix
            ./modules/gnome.nix
          ];
          inherit specialArgs;
        };

        nixosConfigurations.aendernext = nixosSystem {
          system = "x86_64-linux";
          modules = extraArgs ++ [
            ./hardware-aendernext.nix
            ./aenderpad.nix
            ./config-common.nix
          ];
          inherit specialArgs;
        };

};
  }
