{ lib, config, pkgs, ... }: with lib; {
  
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland"; # qt apps disable wayland by default
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1"; # mozillas wayland backend is experimental and disabled by default
  };
  nixpkgs.overlays = [ (self: super: { chromium = super.chromium.override {
    commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
  }; } ) ];
  # chromium --enable-features=UseOzonePlatform --ozone-platform=wayland
  # not there yet: flatpak run --env=XDG_SESSION_TYPE=wayland --env=QT_QPA_PLATFORM=wayland --socket=wayland --enable-features=UseOzonePlatform --ozone-platform=wayland io.typora.Typora

  environment.systemPackages = with pkgs; [
    firefox
    chromium
    # fprintd # seems to brick the login screen on ThinkPad E14 amd
    nextcloud-client
    gnomeExtensions.appindicator
    gnome.gnome-tweaks
    keepassxc
    alacritty
  ];
  # geary sucks. Or does it?
  # environment.gnome.excludePackages = with pkgs; [ gnome.geary ];
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
  # allow fractional scaling:
  # gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  services.flatpak.enable = true;
}

