{ lib, config, pkgs, ... }: with lib; {
  
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

