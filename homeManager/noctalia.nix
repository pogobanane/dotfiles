{ config, lib, pkgs, inputs, ... }:
{
  imports = [ ./wluma.nix ];

  options.my-noctalia = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Add home config for noctalia shell for niri";
    };
  };

  config = lib.mkIf config.my-noctalia.enable {
    # Startup chain: greetd (modules/niri.nix) runs niri-session, which starts
    # the niri.service user unit; niri then spawns noctalia via
    # spawn-sh-at-startup in niri.kdl. Since v5 noctalia is a native Wayland
    # shell (C++ rewrite), no longer a quickshell/QML config; the binary is
    # `noctalia` (was `noctalia-shell`).
    #
    # Logs: niri -> `journalctl --user -u niri.service`.
    #
    # v5 migration status (see git log of this file for the v4 setup):
    # - The v4 QML plugins cannot run on v5 (plugins are Luau now).
    #   keybind-cheatsheet and slowbongo have v5 equivalents in noctalia's
    #   default plugin repos (wired below); our own display-config
    #   (github:pogoba/noctalia-plugins) still needs a Luau port, khal-next
    #   was dropped.
    my-wluma.enable = true;

    # Set the GTK icon theme so gtk apps pick up breeze instead of falling
    # back to hicolor.
    gtk = {
      enable = true;
      iconTheme = {
        name = "breeze";
        package = pkgs.kdePackages.breeze-icons;
      };
    };

    # kanshi driven by ~/.config/kanshi/config, which the (v4) display-config
    # plugin wrote via "Remember monitors". The existing config keeps working
    # while the plugin is unported; don't manage profiles here.
    services.kanshi = {
      enable = true;
      systemdTarget = "graphical-session.target";
    };

    systemd.user.services.keepassxc = {
      Unit = {
        Description = "KeePassXC password manager";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.keepassxc}/bin/keepassxc";
        Restart = "on-failure";
      };
      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Ensure XDG autostart apps (Nextcloud, etc.) start after KeePassXC
    # so they can use it as a Secret Service provider.
    home.file.".config/systemd/user/xdg-desktop-autostart.target.d/after-keepassxc.conf".text = ''
      [Unit]
      After=keepassxc.service
      Wants=keepassxc.service
    '';

    home.file.".config/niri/config.kdl".source = ./niri.kdl;

    home.packages = with pkgs; [
      jq
      nextcloud-client
      remmina
      keepassxc
      bitwarden-desktop

      # terminal emulators:
      alacritty
      wezterm
      ghostty

      vlc
      libreoffice
      gimp
      gthumb
      inkscape
      rawtherapee
      drawio
      thunderbird
      evince
      pdfarranger
      hexchat
      zoom-us
      element-desktop
      languagetool
      mumble
      marktext
      dbeaver-bin
      gitg
      zed-editor
      rstudio
      pavucontrol
      libheif
      audacity
      webcord
      discord
      slack
      signal-desktop
      zulip
      ferdium
      foliate
      calibre
      ausweisapp
      via
      zotero

      inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.osu-lazer-bin

      atlauncher

      # for iphone
      libimobiledevice
      idevicerestore
      ifuse
      libheif

      gnome-calculator
      gnome-clocks
      eog # gnome image viewer
      gnome-system-monitor
      nautilus
      adwaita-icon-theme

      evtest # dependency for the bongocat plugin (input reactivity)
    ];

    # configure options
    programs.noctalia = {
      enable = true;
      # Port of the v4 LauncherCore.qml patch: open windows always sort above
      # apps in the launcher (Mod+D), making it double as a window switcher.
      # Windows join the unprefixed search via shell.launcher.providers below;
      # the sort priority needs a source patch (sort lives in C++ now).
      package =
        inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs
          (old: {
            patches = (old.patches or [ ]) ++ [ ./noctalia-launcher-windows-first.patch ];
          });
      # settings become ~/.config/noctalia/config.toml and are validated at
      # build time with `noctalia config validate`. Runtime tweaks from the
      # settings UI land in the state dir's settings.toml, not here.
      settings = {
        bar.default = {
          position = "right";
          start_widgets = [
            "clock"
            "notifications"
          ];
          center_widgets = [ "workspaces" ];
          end_widgets = [
            "keybinds"
            "bongocat"
            "tray"
            "network"
            "volume"
            "battery"
            "control-center"
          ];
        };
        widget.clock = {
          format = "{:%H:%M}";
          vertical_format = "{:%H %M}";
        };
        widget.battery = {
          show_label = true;
        };
        widget.keybinds.type = "kenn/keybind-cheatsheet:keybinds"; # empty widget setting
        widget.bongocat = {
          type = "noctalia/bongocat:cat";
          input_devices = [ "/dev/input/event1" ];
        };
        plugins = {
          source = [
            {
              name = "official-nix";
              kind = "path";
              location = "${inputs.noctalia-official-plugins-src}";
            }
            {
              name = "community-nix";
              kind = "path";
              location = "${inputs.noctalia-community-plugins-src}";
            }
          ];
          enabled = [
            "noctalia/bongocat" # slowbongo equivalent (evtest-based)
            "kenn/keybind-cheatsheet" # supports niri, reads ~/.config/niri/config.kdl
          ];
        };
        theme = {
          source = "builtin";
          builtin = "Gruvbox";
          mode = "dark";
        };
        wallpaper.directory = "${../users-hm}";
        location.address = "Munich, Germany";
        # Lock the screen before suspend (e.g. lid close); replaces the v4
        # lock-screen-on-suspend user unit (built into v5, default on — set
        # explicitly since we rely on it).
        lockscreen.lock_before_suspend = true;
        # Open windows show up in the plain launcher search (>= 2 typed
        # chars), not only behind the "win " prefix; the package patch above
        # sorts them first.
        shell.launcher.providers = [
          {
            name = "Windows";
            global = true;
          }
        ];
        keybinds = {
          up = [ "Up" "Ctrl+P" ];
          down = [ "Down" "Ctrl+N" ];
        };
        control_center.shortcuts = [
          { type = "wifi"; }
          { type = "bluetooth"; }
          { type = "power_profile"; }
          { type = "notification"; }
          { type = "nightlight"; }
          { type = "dark_mode"; }
        ];
      };
    };
  };
}
