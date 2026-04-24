{ config, lib, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.dunst;
in
{
  options.modules.desktop.dunst = {
    enable = lib.mkEnableOption "dunst notification daemon";
  };

  config = lib.mkIf (desktopCfg.enable && cfg.enable) {
    services.dunst.enable = true;
  };
}
