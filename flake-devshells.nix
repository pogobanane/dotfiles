{ ... }: {
  perSystem = { pkgs, inputs', ... }: {
    devShells = {
      default = pkgs.mkShell {
        buildInputs = with pkgs; [
          just
          nix-output-monitor
          inputs'.disko.packages.disko
        ];
      };
      clang = pkgs.callPackage ./devShells/clang.nix { inherit pkgs; };
      containers = pkgs.callPackage ./devShells/containers.nix { inherit pkgs; };
      latex = pkgs.callPackage ./devShells/latex.nix { inherit pkgs; tex2nixPkgs = inputs'.tex2nix.packages; };
      networking = pkgs.callPackage ./devShells/networking.nix { inherit pkgs; };
      node = pkgs.callPackage ./devShells/node.nix { inherit pkgs; };
      python = pkgs.callPackage ./devShells/python.nix { inherit pkgs; };
      rust = pkgs.callPackage ./devShells/rust.nix { inherit pkgs; fenixPkgs = inputs'.fenix.packages; };
      sys-stats = pkgs.callPackage ./devShells/sys-stats.nix { inherit pkgs; };
    };
  };
  flake = {
    packages.x86_64-linux = {
    };
  };
}
