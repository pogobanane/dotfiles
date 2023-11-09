{ pkgs, ... }: pkgs.nix.overrideAttrs (_finalAttrs: _previousAttrs: {
  pname = "nix-patched";
  patches = [ ./nix-patched2.patch  ];
})
