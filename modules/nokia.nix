{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    intune-portal
  ];
}
