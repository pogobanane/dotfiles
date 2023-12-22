{ self, inputs, lib, config, pkgs, ... }: with lib; {
  nix = {
    settings = {
      trusted-users = [ "peter" "root" ];
      auto-optimise-store = true;
      substituters = [
        "https://nix-community.cachix.org"
        "https://mic92.cachix.org"
        "https://cache.garnix.io"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "mic92.cachix.org-1:gi8IhgiT3CYZnJsaW7fxznzTkMUOn1RY4GmXdT/nXYQ="
        "cache.garnix.io-1:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
      ];
    };
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
  };

  nixpkgs.config.allowUnfree = true;

  # for legacy:
  nix.nixPath = [
    "nixpkgs=${pkgs.path}"
    "home-manager=${inputs.home-manager}"
    "dotfiles=${self}"
    # "nur=${nur}" #now managed by home-manager in ~/.config/nixpkgs/config.nix:
  ];
  # for flakes:
  nix.registry = {
    dotfiles = {
      from = { type = "indirect"; id = "dotfiles"; };
      to = {
        owner = "pogobanane";
        repo = "dotfiles";
        type = "github";
      };
      exact = false;
    };
    dotfilesLocal = {
      from = { type = "indirect"; id = "dotfilesLocal"; };
      to = {
        path = "/home/peter/dev/dotfiles";
        type = "path";
      };
      exact = false;
    };
  };

  nixpkgs.overlays = [
    inputs.nur.overlay
    (_final: prev: {
      ctile = inputs.ctile.packages.x86_64-linux.ctile;
      nerdfonts = inputs.unstablepkgs.legacyPackages.x86_64-linux.nerdfonts;
      nextcloud-client = inputs.unstablepkgs.legacyPackages.x86_64-linux.nextcloud-client; 
      wezterm = inputs.unstablepkgs.legacyPackages.x86_64-linux.wezterm;
      #nextcloud-client = nixpkgs.legacyPackages.x86_64-linux.libsForQt5.callPackage pkgs/nextcloud-client { }; 
      #chromium = unstablepkgs.legacyPackages.x86_64-linux.chromium;
      #slack = unstablepkgs.legacyPackages.x86_64-linux.slack;
      #cider = unstablepkgs.legacyPackages.x86_64-linux.cider;
      cider = self.packages.x86_64-linux.cider;
      webcord = self.packages.x86_64-linux.webcord;
      #loc = flakepkgs.x86_64-linux.loc-git;
      #discord = unstablepkgs.legacyPackages.x86_64-linux.discord;
      discord = prev.discord.overrideAttrs (_: { 
        src = inputs.discord-tar; 
        unpackCmd = "tar -xzf $curSrc";
      });
      alacritty = inputs.unstablepkgs.legacyPackages.x86_64-linux.alacritty;
    })
    #(self: super: { 
      #cider = super.cider.overrideAttrs (old: rec {
        #name = "cider-mine-${version}";
        #version = "1.5.6";
        #src = super.fetchurl rec {
          #url = "https://github.com/ciderapp/cider-releases/releases/download/v${version}/Cider-${version}.AppImage";
          #sha256 = "sha256-gn0dRoPPolujZ1ukuo/esSLwbhiPdcknIe9+W6iRaYw=";
        #};
      #});
    #})
    # (_final: _prev: {
      #linuxPackages_latest = prev.linuxPackages_latest.extend (lpself: lpsuper: let kernel = config.boot.kernelPackages.kernel; in {
      #  sysdig = prev.linuxPackages_latest.sysdig.overrideAttrs (oldAttrs: {
      #    meta.broken = kernel != null && (pkgs.lib.versionOlder kernel.version "4.14" || pkgs.lib.versionAtLeast kernel.version "6.2"); # doesnt work here because kernel is not yet "upstream specialization" (6.2)
      #  });
      #});
    # })
  ];

  nixpkgs.config.permittedInsecurePackages = [
    # upstream bitwarden depends on this as of now
    # should soon be backported to 23.05 https://github.com/NixOS/nixpkgs/pull/264472
    "electron-24.8.6"
    "electron-25.9.0"
  ];

}

