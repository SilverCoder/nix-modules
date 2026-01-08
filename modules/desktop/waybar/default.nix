{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.waybar;
  rofiCfg = config.modules.desktop.rofi;
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

      settings = {
        left = {
          layer = "top";
          position = "top";
          width = 0;
          margin-top = 3;
          margin-left = 3;
          height = 28;

          modules-left = [ "niri/workspaces" ];

          "niri/workspaces" = {
            format = "{icon}";
            format-icons = {
              active = "";
              default = "";
            };
          };
        };

        center = {
          layer = "top";
          position = "top";
          width = 0;
          margin-top = 3;
          height = 28;

          modules-center = [ "clock" ];

          clock = {
            format = " {:%A %d.%m.%Y, Week %W}   {:%H:%M:%S}";
            interval = 1;
          };
        };

        right = {
          layer = "top";
          position = "top";
          width = 0;
          margin-top = 3;
          margin-right = 3;
          height = 28;

          modules-right = [ "cpu" "memory" "pulseaudio" "custom/powermenu" ];

          cpu = {
            format = " {usage}%";
            interval = 2;
          };

          memory = {
            format = " {percentage_used}%";
            interval = 1;
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-muted = " muted";
            format-icons = {
              default = [ "" "" "" ];
            };
            on-click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
          } // lib.optionalAttrs (cfg.audioSink != null) {
            on-scroll-up = "${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.audioSink} +2%";
            on-scroll-down = "${pkgs.pulseaudio}/bin/pactl set-sink-volume ${cfg.audioSink} -2%";
            on-click = "${pkgs.pulseaudio}/bin/pactl set-sink-mute ${cfg.audioSink} toggle";
          };

          "custom/powermenu" = {
            format = " ";
            on-click = "${rofiCfg.powermenu}/bin/powermenu";
          };
        };
      };

      style = ''
        * {
          font-family: "Fira Code", "JetBrainsMono Nerd Font";
          font-size: 11px;
        }

        window#waybar {
          background: transparent;
        }

        #workspaces,
        #clock,
        #cpu,
        #memory,
        #pulseaudio,
        #custom-powermenu {
          background-color: ${cfg.colors.background or "rgba(36, 39, 58, 0.4)"};
          color: ${cfg.colors.text or "#cad3f5"};
          border-radius: 16px;
          padding: 0 16px;
          margin: 0 3px;
        }

        #workspaces button {
          color: ${cfg.colors.text-disabled or "rgba(202, 211, 245, 0.4)"};
          padding: 0 5px;
        }

        #workspaces button.active {
          color: ${cfg.colors.text-active or "#c6a0f6"};
        }
      '';
    };
  };
}
