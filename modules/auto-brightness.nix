{ lib, config, ... }: with lib; let
  cfg = config.services.auto-brightness;
in {
  options.services.auto-brightness = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        If enabled, your screen brightness is automatically adjusted based on different parameters.
      '';
    };
  };

  config = mkIf cfg.enable {

  };
}
