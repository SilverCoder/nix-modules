{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.sddm;

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable SDDM display manager";
    };

    package = mkOption {
      type = types.package;
      description = "SDDM theme package (set by theme module)";
    };
  };
in
{
  nixosModule = {
    options.modules.desktop.sddm = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        package = pkgs.kdePackages.sddm;
      };

      services.xserver.xkb = {
        layout = "de";
        variant = "";
      };

      environment.systemPackages = [ cfg.package ];
    };
  };

  homeManagerModule = {
    options.modules.desktop.sddm = options;
  };
}
