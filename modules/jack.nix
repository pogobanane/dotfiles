{ config, pkgs, lib, ... }: 
{
  config = {
    # To do low-latency audio processing, use this module with:
    # nix-jack guitarix
    # nix-jack qjackctl
    warnings = (lib.optionals config.hardware.pulseaudio.enable ["Jack is somewhat incompatible with pulseaudio i think."]) ++
      (lib.optionals (!config.services.pipewire.enable) "Seems wrong that you seem to want jack without pipewire")
    ;
    users.groups.audio.members = [
      "peter"
    ];
    environment.systemPackages = with pkgs; [
      (writeShellScriptBin "nix-jack" ''
        exec /usr/bin/env \
          LD_LIBRARY_PATH=${pipewire.jack}/lib''${LD_LIBRARY_PATH:+:''${LD_LIBRARY_PATH}} \
          "''$@"
      '')
    ];
  };
}
