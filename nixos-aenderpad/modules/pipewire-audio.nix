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
}
