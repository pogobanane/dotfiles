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
    zam-plugins
    tambura
    lsp-plugins
    distrho
    delayarchitect
    dexed
    cardinal
  ];

}
