{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.lightdm;

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable LightDM display manager";
    };
  };
in
{
  nixosModule = {
    options.modules.desktop.lightdm = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      services.xserver.displayManager.lightdm = {
        enable = true;
        background = desktopCfg.wallpaper;
        extraConfig = ''
          sessions-directory=/run/current-system/sw/share/wayland-sessions:/run/current-system/sw/share/xsessions
        '';
      };
    };
  };

  homeManagerModule = {
    options.modules.desktop.lightdm = options;
  };
}
