{ config, lib, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.picom;
in
{
  options.modules.desktop.picom = {
    enable = lib.mkEnableOption "picom compositor";
  };

  config = lib.mkIf (desktopCfg.enable && cfg.enable) {
    services.picom = {
      enable = true;
      backend = "glx";
      fade = true;
      fadeDelta = 2;
      shadow = true;
      wintypes = {
        dock = { shadow = false; };
      };
      settings = {
        blur = {
          method = "dual_kawase";
          size = 16;
          deviation = 5.0;
        };
      };
    };
  };
}
