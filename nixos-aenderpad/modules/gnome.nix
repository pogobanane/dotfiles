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
  # opening chrome://flags/#enable-webrtc-pipewire-capturer in chrome and change "WebRTC PipeWire support" to "Enabled" makes screen sharing work
  # not there yet: flatpak run --env=XDG_SESSION_TYPE=wayland --env=QT_QPA_PLATFORM=wayland --socket=wayland --enable-features=UseOzonePlatform --ozone-platform=wayland io.typora.Typora

  environment.systemPackages = with pkgs; [
    firefox
    chromium
    # fprintd # seems to brick the login screen on ThinkPad E14 amd
    nextcloud-client
    gnomeExtensions.appindicator
    gnomeExtensions.gesture-improvements
    gnomeExtensions.bluetooth-quick-connect
    gnomeExtensions.switcher
    gnomeExtensions.sound-output-device-chooser
    gnomeExtensions.tactile
    gnomeExtensions.noannoyance-2
    # not as well wtf it should be
    # gnomeExtensions.noannoyance
    # gnomeExtensions.application-volume-mixer
    # gnomeExtensions.run-or-raise	
    # not available on gnome 41
    #gnomeExtensions.clock-override
    #gnomeExtensions.wintile-windows-10-window-tiling-for-gnome
    gnome.gnome-tweaks
    keepassxc
    alacritty
    vlc
    obs-studio
    libreoffice
    gimp
    thunderbird
    pdfarranger
  ];
  # geary sucks. Or does it?
  # environment.gnome.excludePackages = with pkgs; [ gnome.geary ];
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
  # allow fractional scaling:
  # gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # printing:
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ]; # often replaces hplip

  services.flatpak.enable = true;

  services.shairport-sync.enable = true;
  users.users.shairport.group = "shairport";
  users.groups.shairport = {};
  networking.firewall.allowedTCPPorts = [ 
    5353 # avahi
    # shairport-sync
    5000 
    6000
    6001
    6002
    6003
  ];
}

