{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    easyeffects # optional for audio post processing
    qjackctl
  ];

  hardware.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };
  security.rtkit.enable = true;

  # Not using the nixos service since that has not been working.
  # TODO fix nixos module/doc.
  services.shairport-sync.enable = true;
  systemd.services.shairport-sync.enable = false; # this one no worky
  users.users.shairport.group = "shairport";
  users.groups.shairport = {};
  systemd.user.services = {
    shairport-sync = {
      description = "Apple AirPlay audio sink";
      serviceConfig.ExecStart = ''${pkgs.shairport-sync}/bin/shairport-sync -v -o pa'';
      after = [ "pipewire.service" ];
    };
  };
  # the following works on pipewire in userspace: shairport-sync -v -o pa
}
