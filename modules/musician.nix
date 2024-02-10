{ pkgs, flakepkgs, ... }: {
  imports = [
    ./jack.nix
  ];

  environment.systemPackages = with pkgs; [
    ardour
    flakepkgs.jack-keyboard
    calf
    helm
    odin2
  ];

}
