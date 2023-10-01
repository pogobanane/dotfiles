{ lib, config, pkgs, unstablepkgs, flakepkgs, inputs, ... }: with lib; {

  imports = [
    ./pipewire-audio.nix
  ];

  environment.sessionVariables = {
    QT_QPA_PLATFORM = "wayland"; # qt apps disable wayland by default
    XDG_SESSION_TYPE = "wayland";
    MOZ_ENABLE_WAYLAND = "1"; # mozillas wayland backend is experimental and disabled by default
    NIXOS_OZONE_WL = "1"; # enables wayland for chrome/electron since nixos 22.11
  };
  nixpkgs.overlays = [
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
    (self: super: {
      gnomeExtensions = super.gnomeExtensions // rec {
        #switcher = gsuper.switcher.overrideAttrs (finalAttrs: previousAttrs: {
        switcher-patched = super.pkgs.gnomeExtensions.switcher.overrideAttrs (finalAttrs: previousAttrs: rec {
          postPatch = ''
            substituteInPlace metadata.json \
              --replace '"42"' '"43", "42"'
          '';
        });
      };
    })
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
    gnomeExtensions.gesture-improvements # disabled
    gnomeExtensions.bluetooth-quick-connect # disabled
    gnomeExtensions.switcher-patched
    gnomeExtensions.sound-output-device-chooser # disabled
    # gnomeExtensions.tactile
    gnomeExtensions.noannoyance-2
    gnomeExtensions.forge
    gnomeExtensions.ssh-search-provider-reborn
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
    wezterm
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
    mumble
    marktext # markdown editor
    logseq # markdown editor
    dbeaver
    pavucontrol
    libheif # for apple media codecs
    cider
    webcord
    discord
    slack
    signal-desktop
    # pretty ebook reader with one bug that has a workaround https://github.com/johnfactotum/foliate/issues/719#issuecomment-830874744
    foliate
    # big plugin ecosystem for ebooks. Has a plugin that supposedly works to read and back up Kobo (rakuten) and some amazon ebooks: https://github.com/apprenticeharper/DeDRM_tools
    calibre
    # cli tool to log in and back up Kobo (rakuten) ebooks:
    flakepkgs.kobo-book-downloader
    AusweisApp2
    via # for qmk keyboard flashing

    inputs.nix-gaming.packages.${pkgs.system}.osu-lazer-bin

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

  # fix for many rust based guis on wayland/gnome/nixos
  # https://github.com/alacritty/alacritty/issues/4780#issuecomment-890408502
  # https://github.com/NixOS/nixpkgs/issues/22652#issuecomment-890512607
  # TODO this does not arrive yet inside the gnome session
  environment.variables.XCURSOR_THEME = "Adwaita";

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
