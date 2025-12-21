{ pkgs, flakepkgs, ... }: {
  imports = [
    ./jack.nix
  ];

  environment.systemPackages = with pkgs; [
    ardour
    # flakepkgs.jack-keyboard # fails to build since 25.11
    calf
    helm
    odin2
    zam-plugins
    tambura
    lsp-plugins
    delayarchitect
    dexed
    cardinal
  ];

}
