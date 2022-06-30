{ lib, config, pkgs, ... }: with lib; {
  nix = {
    trustedUsers = [ "peter" "root" ];
    gc.automatic = true;
    gc.dates = "03:15";
    gc.options = "--delete-older-than 30d";
    package = pkgs.nixFlakes;

    # should be enough?
    nrBuildUsers = 32;

    # https://github.com/NixOS/nix/issues/719
    extraOptions = ''
      builders-use-substitutes = true
      keep-outputs = true
      keep-derivations = true
      # in zfs we trust
      fsync-metadata = ${lib.boolToString (config.fileSystems."/".fsType != "zfs")}
      experimental-features = nix-command flakes
    '';

    autoOptimiseStore = true;

    binaryCaches = [
      #"https://nix-community.cachix.org"
      #"https://mic92.cachix.org"
      #"https://cache.garnix.io"
    ];

    settings.substituters = [
      "https://nix-community.cachix.org"
      "https://mic92.cachix.org"
    ];

    binaryCachePublicKeys = [
      #"nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      #"mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
      #"cache.garnix.io-1:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
  };

  nixpkgs.config.allowUnfree = true;
}

