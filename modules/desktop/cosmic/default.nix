{ config, lib, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.cosmic;

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable COSMIC desktop environment";
    };
  };
in
{
  nixosModule = {
    options.modules.desktop.cosmic = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      services.desktopManager.cosmic = {
        enable = true;
      };
    };
  };
}
