{ lib, pkgs, flakepkgs, inputs, ... }: with lib; {
  imports = [
  ];

  environment.systemPackages = with pkgs; [
    android-studio
  ];

  # android stuff
  programs.adb.enable = true;
  users.extraUsers.peter.extraGroups = [ "adbusers" ];
  # simple audio streaming for andoid
  # https://github.com/kaytat/SimpleProtocolPlayer
  # https://docs.pipewire.org/page_module_protocol_simple.html
  # upnp renderer: gmrender-resurrect `gmediarender`
  # upnp recorder/transmitter: BubbleUPnP or AirMusic (payed)
  # The chromecast protocol is very much more closed that airplay.
  # Chromecast binary: nix run github:rgerganov/shanocast#shanocast -- enp4s0
  virtualisation.waydroid.enable = true;

}
