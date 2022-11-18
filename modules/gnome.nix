{ lib, config, pkgs, ... }: with lib; {

  imports = [
    ./pipewire-audio.nix
  ];
  
  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland"; # qt apps disable wayland by default
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1"; # mozillas wayland backend is experimental and disabled by default
  };
  nixpkgs.overlays = [ 
    (self: super: { 
      chromium = super.chromium.override {
        commandLineArgs = "--enable-features=UseOzonePlatform --ozone-platform=wayland";
      };
    } )
    #(self: super: { 
      #gnome = super.gnome.overrideScope' (gself: gsuper: {
        #gnome-keyring = gsuper.gnome-keyring.override {
          #doCheck = true;
          #dontPatch = true;
          #prePatch = ''
            #substituteInPlace $out/pkcs11/ssh-store/gkm-ssh-module.c
              #--replace "~/.ssh" "~/.ssh/gnome-autoload"
          #'';
        #};
      #});
    #} ) 
  ];
  # chromium --enable-features=UseOzonePlatform --ozone-platform=wayland
  # opening chrome://flags/#enable-webrtc-pipewire-capturer in chrome and change "WebRTC PipeWire support" to "Enabled" makes screen sharing work
  # not there yet: flatpak run --env=XDG_SESSION_TYPE=wayland --env=QT_QPA_PLATFORM=wayland --socket=wayland --enable-features=UseOzonePlatform --ozone-platform=wayland io.typora.Typora

  environment.systemPackages = with pkgs; [
    firefox
    chromium
    # fprintd # seems to brick the login screen on ThinkPad E14 amd
    nextcloud-client
    gnome.gnome-terminal
    gnome.gedit
    gnome.seahorse
    remmina # rdp/vnc client
    ctile
    gnomeExtensions.appindicator
    gnomeExtensions.gesture-improvements
    gnomeExtensions.bluetooth-quick-connect
    gnomeExtensions.switcher
    gnomeExtensions.sound-output-device-chooser
    # gnomeExtensions.tactile
    gnomeExtensions.noannoyance-2
    gnomeExtensions.forge
    # not as well wtf it should be
    # gnomeExtensions.noannoyance
    # gnomeExtensions.application-volume-mixer
    # gnomeExtensions.run-or-raise	
    # not available on gnome 41
    #gnomeExtensions.clock-override
    #gnomeExtensions.wintile-windows-10-window-tiling-for-gnome
    gnome.gnome-tweaks
    keepassxc
    bitwarden
    alacritty
    vlc
    obs-studio
    libreoffice
    gimp
    inkscape
    drawio
    thunderbird
    pdfarranger
    hexchat
    zoom-us
    element-desktop
    languagetool
    calibre
    mumble
    marktext
    dbeaver
    pavucontrol
    libheif # for apple media codecs
    cider

    # teamspeak
    #teamspeak_client
    #libsForQt5.qtwayland
    #libsForQt5.plasma-wayland-protocols
    # broken on wayland right now

    # for iphone
    libimobiledevice
    idevicerestore
    ifuse
    libheif
  ];
  # geary sucks. Or does it?
  # environment.gnome.excludePackages = with pkgs; [ gnome.geary ];
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
  # allow fractional scaling:
  # gsettings set org.gnome.mutter experimental-features "['scale-monitor-framebuffer']"

  # for iphone
  services.usbmuxd.enable = true;

  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # printing:
  services.printing.enable = true;
  services.printing.drivers = [ pkgs.gutenprint ]; # often replaces hplip

  services.flatpak.enable = true;

  systemd.services.audio-off = {
    description = "Mute audio before suspend";
    wantedBy = [ "sleep.target" ];
    serviceConfig = {
      Type = "oneshot";
      Environment = "XDG_RUNTIME_DIR=/run/user/1000";
      User = "joerg";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
    };
  };

  networking.firewall.allowedTCPPorts = [ 
    5353 # avahi
    # shairport-sync
    5000 
    6000
    6001
    6002
    6003
  ];
  networking.firewall.allowedUDPPorts = [ 
    5353 # avahi
    # shairport-sync
    5000 
    6000
    6001
    6002
    6003
  ];
}

