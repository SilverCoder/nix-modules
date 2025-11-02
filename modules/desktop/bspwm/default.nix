{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.bspwm;

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = true;
      description = "Enable bspwm tiling window manager";
    };

    monitors = mkOption {
      type = types.str;
      default = ''
        bspc monitor -d 1 2 3 4 5 6 7 8
      '';
    };

    secondaryPolybars = mkOption {
      type = types.listOf types.str;
      default = [ ];
    };

    normalBorderColor = mkOption {
      type = types.str;
    };
    activeBorderColor = mkOption { type = types.str; };
    focusedBorderColor = mkOption { type = types.str; };
    preselBorderColor = mkOption { type = types.str; };
  };
in
{
  nixosModule = {
    options.modules.desktop.bspwm = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      services.xserver.windowManager.bspwm.enable = true;
    };
  };

  homeManagerModule = {
    options.modules.desktop.bspwm = options;

    imports = [
      ./../dunst
      ./../picom
      ./../polybar
      ./../rofi
      ./../sxhkd
    ];

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      assertions = [
        {
          assertion = desktopCfg.wallpaper == null || builtins.pathExists (toString desktopCfg.wallpaper);
          message = "Desktop wallpaper path does not exist: ${toString desktopCfg.wallpaper}";
        }
      ];

      modules.desktop = {
        dunst.enable = true;
        picom.enable = true;
        polybar.enable = true;
        rofi.enable = true;
        sxhkd.enable = true;
      };

      home = {
        packages = with pkgs; [
          shutter
        ];
      };

      gtk.enable = true;

      programs = {
        feh.enable = true;
      };

      xsession.windowManager.bspwm = {
        enable = true;
        extraConfig = ''
          ${cfg.monitors}

          bspc config focus_follows_pointer false

          bspc config border_width 2
          bspc config window_gap 16
          bspc config normal_border_color "${cfg.normalBorderColor}"
          bspc config active_border_color "${cfg.activeBorderColor}"
          bspc config focused_border_color "${cfg.focusedBorderColor}"
          bspc config presel_feedback_color "${cfg.preselBorderColor}"
        '';
        startupPrograms = lib.mkMerge [
          ([
            "polybar left"
            "polybar center"
            "polybar right"
          ])
          cfg.secondaryPolybars
          (lib.mkIf (desktopCfg.wallpaper != null) [ "feh --bg-fill ${desktopCfg.wallpaper}" ])
        ];
      };
    };
  };
}
