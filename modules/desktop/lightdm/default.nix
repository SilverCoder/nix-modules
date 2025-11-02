{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.lightdm;

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable LightDM display manager with Dracula theme";
    };
  };
in
{
  nixosModule = {
    options.modules.desktop.lightdm = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      services.xserver.displayManager.lightdm = {
        enable = true;
        greeters.gtk = {
          theme = {
            name = "Dracula";
            package = pkgs.dracula-theme;
          };
          iconTheme = {
            name = "Dracula";
            package = pkgs.dracula-icon-theme;
          };
        };
      };
    };
  };

  homeManagerModule = {
    options.modules.desktop.lightdm = options;
  };
}
