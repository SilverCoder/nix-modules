{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.waybar;
  rofiCfg = config.modules.desktop.rofi;

  bg = cfg.colors.background or "rgba(36, 39, 58, 0.4)";
  text = cfg.colors.text or "#cad3f5";
  textActive = cfg.colors.text-active or "#c6a0f6";
  textDisabled = cfg.colors.text-disabled or "rgba(202, 211, 245, 0.4)";
in
{
  options.modules.desktop.waybar = with lib; {
    enable = mkEnableOption "waybar status bar";

    audioSink = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Specific audio sink to control";
    };

    colors = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Waybar colors";
    };
  };

  config = lib.mkIf (desktopCfg.enable && cfg.enable) {
    programs.waybar = {
      enable = true;

      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 28;
        margin-top = 8;
        margin-left = 8;
        margin-right = 8;

        modules-left = [ "tray" ];
        modules-center = [ "clock" ];
        modules-right = [ "cpu" "memory" "pulseaudio" "custom/powermenu" ];

        clock = {
          format = " {:%A %d.%m.%Y, Week %W %H:%M:%S}";
          interval = 1;
        };

        cpu = {
          format = " {usage}%";
          interval = 2;
        };

        memory = {
          format = " {percentage}%";
          interval = 1;
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = " muted";
          format-icons = {
            default = [ "" "" "" ];
          };
          on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
        } // lib.optionalAttrs (cfg.audioSink != null) {
          on-scroll-up = "${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.audioSink} +2%";
          on-scroll-down = "${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.audioSink} -2%";
          on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute ${cfg.audioSink} toggle";
        };

        tray = {
          icon-size = 18;
          spacing = 8;
        };

        "custom/powermenu" = {
          format = "";
          tooltip = false;
          on-click = "${rofiCfg.powermenu}/bin/powermenu";
        };
      };

      style = ''
        * {
          font-family: "JetBrainsMono Nerd Font", "Fira Code";
          font-size: 11px;
          min-height: 0;
        }

        window#waybar {
          background: transparent;
          color: ${text};
        }

        #tray,
        #clock {
          background-color: ${bg};
          color: ${text};
          border-radius: 16px;
          padding: 0 16px;
        }

        #cpu,
        #memory,
        #pulseaudio,
        #custom-powermenu {
          background-color: ${bg};
          color: ${text};
          padding: 0 12px;
          margin: 0;
          border-radius: 0;
        }

        #cpu {
          border-radius: 16px 0 0 16px;
          padding-left: 16px;
        }

        #custom-powermenu {
          border-radius: 0 16px 16px 0;
          padding-right: 16px;
        }
      '';
    };
  };
}
