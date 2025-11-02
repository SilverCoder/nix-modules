{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop.polybar;
  rofiCfg = config.modules.desktop.rofi;
in
{
  options.modules.desktop.polybar = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable polybar status bar";
    };
    battery = mkOption {
      type = types.bool;
      default = false;
    };
    audioSink = mkOption {
      type = types.str;
      default = "alsa_output.usb-SteelSeries_SteelSeries_Arctis_7-00.stereo-game";
    };
    colors = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Polybar colors (set by theme module)";
    };
  };

  config = lib.mkIf cfg.enable {
    services = {
      polybar = {
          enable = true;
          package = pkgs.polybar.override {
            alsaSupport = true;
            githubSupport = true;
            mpdSupport = true;
            pulseSupport = true;
          };
          settings = {
            "module/bspwm" = {
              type = "internal/bspwm";
              pin-workspaces = true;
              enable = {
                click = true;
                scroll = true;
              };
              reverse-scroll = false;
              fuzzy-match = true;
              occupied-scroll = true;
              label = {
                focused-foreground = cfg.colors.text-active;
                empty-foreground = cfg.colors.text-disabled;
              };
            };

            "module/date" = {
              type = "internal/date";
              internal = 5;
              date = " %A %d.%m.%Y, Week %OW";
              time = " %H:%M:%S";
              label = "%date% %time%";
            };

            "module/cpu" = {
              type = "internal/cpu";
              interval = 2;
              warn-percentage = 95;
              label = " %percentage%% ";
            };

            "module/memory" = {
              type = "internal/memory";
              interval = 1;
              warn-percentage = 95;
              label = " %percentage_used%% ";
            };

            "module/pulseaudio" = {
              type = "internal/pulseaudio";
              sink = cfg.audioSink;
              format-volume = "<ramp-volume> <label-volume>";
              label = {
                volume.text = "%percentage%%";
                muted.text = " muted";
                muted.foreground = cfg.colors.text-disabled;

              };
              ramp.volume = [ "" "" "" ];
              click-right = "${pkgs.pavucontrol}/bin/pavucontrol";
            };

            "module/battery" = {
              type = "internal/battery";
              full-at = 99;
              adapter = "ACAD";
              battery = "BAT1";
              ramp-capacity-0 = "";
              ramp-capacity-1 = "";
              ramp-capacity-2 = "";
              ramp-capacity-3 = "";
              ramp-capacity-4 = "";
              label-charging = "%percentage%% ";
              format-charging = "<ramp-capacity>  <label-charging>";
              label-discharging = "%percentage%% ";
              format-discharging = "<ramp-capacity>  <label-discharging>";
              label-full = "  %percentage%% ";
            };

            "module/powermenu" = {
              type = "custom/text";
              content = " ";
              click.left = "${rofiCfg.powermenu}/bin/powermenu";
            };
          };
          config = {
            "bar/base" = {
              monitor = "\${env:MONITOR:}";
              background = cfg.colors.background;
              foreground = cfg.colors.text;
              height = 28;
              line-size = "3pt";
              border-size = "3pt";
              border-color = cfg.colors.transparent;
              font-0 = "Fira Code:size=11;2";
              font-1 = "JetBrainsMono Nerd Font;2";
              wm-restack = "bspwm";
            };

            "bar/left" = {
              "inherit" = "bar/base";
              width = "25%";
              radius = 16;
              padding-left = "16px";
              padding-right = "16px";
              modules-left = "bspwm";
            };
            "bar/secondary" = {
              "inherit" = "bar/base";
              width = "100%";
              radius = 16;
              padding-left = "16px";
              padding-right = "16px";
              modules-left = "bspwm";
            };

            "bar/center" = {
              "inherit" = "bar/base";
              offset-x = "37.5%";
              width = "25%";
              radius = 16;
              modules-center = "date";
            };

            "bar/right" = {
              "inherit" = "bar/base";
              offset-x = "75%";
              width = "25%";
              radius = 16;
              padding-left = "16px";
              padding-right = "16px";
              tray-detached = true;
              tray-position = "left";
              tray-offset-x = 16;
              modules-right = (if cfg.battery then [ "battery" ] else [ ]) ++ [ "cpu" "memory" "pulseaudio" "powermenu" ];
            };
          };
          script = "";
        };
    };

    systemd = {
      user = {
        services = {
          polybar = {
            Install.WantedBy = [ "graphical-session.target" ];
          };
        };
      };
    };
  };
}
