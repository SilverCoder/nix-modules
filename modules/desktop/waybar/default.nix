{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.waybar;
  rofiCfg = config.modules.desktop.rofi;

  bg = cfg.colors.background or "rgba(36, 39, 58, 0.4)";
  text = cfg.colors.text or "#cad3f5";
  textDisabled = cfg.colors.text-disabled or "rgba(202, 211, 245, 0.4)";
in
{
  options.modules.desktop.waybar = with lib; {
    enable = mkEnableOption "waybar status bar";

    battery = mkEnableOption "battery module";

    network = mkEnableOption "network module" // { default = true; };

    output = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Output to show waybar on (null = all outputs)";
    };

    audioSink = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Specific audio sink to control";
    };

    colors = mkOption {
      type = types.attrsOf types.str;
      default = { };
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
        modules-center = [ "clock#date" "clock#time" ];
        modules-right = lib.optional cfg.battery "battery"
          ++ lib.optional cfg.network "network"
          ++ [ "cpu" "memory" "pulseaudio" "custom/powermenu" ];

        "clock#date" = {
          format = " {:%A %d.%m.%Y, Week %W}";
          interval = 60;
        };

        "clock#time" = {
          format = " {:%H:%M:%S}";
          interval = 1;
        };

        cpu = {
          format = " {usage}%";
          interval = 2;
        };

        battery = {
          format = "{icon} {capacity}%";
          format-charging = "󰂄 {capacity}%";
          format-icons = [ "󰂎" "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
          states = {
            warning = 30;
            critical = 15;
          };
          interval = 10;
        };

        network = {
          format-wifi = "󰤨 {essid}";
          format-ethernet = "󰈀 {ipaddr}";
          format-disconnected = "󰤭";
          tooltip-format = "{ifname}: {ipaddr}/{cidr}\n󰁅 {bandwidthDownBytes}  󰁝 {bandwidthUpBytes}";
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
      } // lib.optionalAttrs (cfg.output != null) {
        output = cfg.output;
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
        .modules-center,
        .modules-right {
          background: ${bg};
          border-radius: 16px;
          padding: 0 16px;
        }

        #clock.date,
        #clock.time,
        #cpu,
        #memory,
        #battery,
        #network,
        #pulseaudio,
        #custom-powermenu {
          background: transparent;
          padding: 0 4px;
        }

        #pulseaudio.muted {
          color: ${textDisabled};
        }

        #battery.warning {
          color: #f5a97f;
        }

        #battery.critical {
          color: #ed8796;
        }
      '';
    };
  };
}
