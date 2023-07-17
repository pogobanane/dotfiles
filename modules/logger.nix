{ lib, config, pkgs, ... }: with lib; {

  systemd.timers.logger.timerConfig = {
    "OnCalendar"= "*-*-* *:*:00";
    "Unit"= "logger.service";
  };
  systemd.timers.logger.wantedBy = [ "timers.target" ];
  systemd.timers.logger.enable = true;
  systemd.services.logger.path = [ pkgs.bash pkgs.coreutils pkgs.procps pkgs.gawk ];
  systemd.services.logger.serviceConfig = {
    # Restart = "never";
    ExecStart = ''${pkgs.bash}/bin/bash -c "echo $(date) $(awk '/^size/ { print $3 / 1048576 }' < /proc/spl/kstat/zfs/arcstats) $(free -h | head -n 2 | tail -n 1) >> /root/log
    echo \"$(ps aux --sort=-%mem | head -n4 | tail -n3)\" >> /root/log
    " '';
  };
  
#  environment.sessionVariables = {
#    QT_QPA_PLATFORM = "wayland"; # qt apps disable wayland by default
#    XDG_SESSION_TYPE = "wayland";
#    MOZ_ENABLE_WAYLAND = "1"; # mozillas wayland backend is experimental and disabled by default
#  };
#  nixpkgs.overlays = [ (self: super: { chromium = super.chromium.override {
#    commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
#  }; } ) ];
#  # chromium --enable-features=UseOzonePlatform --ozone-platform=wayland
#  # opening chrome://flags/#enable-webrtc-pipewire-capturer in chrome and change "WebRTC PipeWire support" to "Enabled" makes screen sharing work
#  # not there yet: flatpak run --env=XDG_SESSION_TYPE=wayland --env=QT_QPA_PLATFORM=wayland --socket=wayland --enable-features=UseOzonePlatform --ozone-platform=wayland io.typora.Typora
#
#  environment.systemPackages = with pkgs; [
#    firefox
#    chromium
#    # fprintd # seems to brick the login screen on ThinkPad E14 amd
#    nextcloud-client
#    gnomeExtensions.appindicator
#    gnome.gnome-tweaks
#    keepassxc
#    alacritty
#    vlc
#    obs-studio
#  ];
#  # geary sucks. Or does it?
#  # environment.gnome.excludePackages = with pkgs; [ gnome.geary ];
#  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
#  # allow fractional scaling:
#  # gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"
#
#  services.xserver.enable = true;
#  services.xserver.displayManager.gdm.enable = true;
#  services.xserver.desktopManager.gnome.enable = true;
#
#  services.flatpak.enable = true;
#
#  services.shairport-sync.enable = true;
#  users.users.shairport.group = "shairport";
#  users.groups.shairport = {};
#  networking.firewall.allowedTCPPorts = [ 
#    5353 # avahi
#    # shairport-sync
#    5000 
#    6000
#    6001
#    6002
#    6003
#  ];
}

