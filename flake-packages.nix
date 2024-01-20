{inputs, ...}: {
  perSystem = { pkgs, ... }: {
    packages = {
      map-cmd = pkgs.callPackage ./pkgs/map.nix { };
      loc-git = pkgs.callPackage ./pkgs/loc.nix { inherit (inputs) loc-src; };
      nixos-generations = pkgs.callPackage ./pkgs/nixos-generations.nix { };
      self-flake = pkgs.callPackage ./pkgs/self-flake.nix { impure-debug-info = inputs.impurity; };
      nix-patched = pkgs.callPackage ./pkgs/nix-patched.nix { };
      #wluma = pkgs.callPackage ./pkgs/wluma.nix { };
      #webcord = if "${system}" == "x86_64-linux" then pkgs.callPackage ./pkgs/webcord-appimage.nix { } else null;
      #webcord = pkgs.callPackage ./pkgs/webcord-appimage.nix { };
      nix-top = pkgs.nix-top.overrideAttrs (finalAttrs: previousAttrs: {
        # my nix-top fork
        src = inputs.nix-top-src;
      });
    };
  };
  flake = let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    make-disk-image = import (./nix/make-disk-image.nix);
  in {
    packages.x86_64-linux = {
      webcord = pkgs.callPackage ./pkgs/webcord-appimage.nix { };
      cider = pkgs.callPackage pkgs/cider.nix { };
      kobo-book-downloader = pkgs.callPackage pkgs/kobo-book-downloader.nix { };
      # broken/in development:
      # apple-music = pkgs.callPackage pkgs/apple-music.nix { };
    };

    #packages.x86_64-linux.geary = pkgs.callPackage pkgs/geary.nix { };
    #packages.x86_64-linux.geary = pkgs.gnome.geary.overrideAttrs (finalAttrs: previousAttrs: {
      #mesonFlags = [ "-Dprofile=development" "-Dcontractor=enabled" ];
      #dontStrip = true;
    #});
  };
}
