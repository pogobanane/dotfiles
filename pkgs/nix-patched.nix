{ pkgs, ... }: pkgs.nix.overrideAttrs (finalAttrs: previousAttrs: {
  pname = "nix-patched";
  patches = [ ./nix-patched2.patch  ];
})
