{ config, lib, pkgs, niri, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.niri;
  rofiCfg = config.modules.desktop.rofi;

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable niri Wayland compositor";
    };

    scale = mkOption {
      type = types.float;
      default = 1.0;
      description = "Output scale factor";
    };

    activeBorderColor = mkOption { type = types.str; };
    inactiveBorderColor = mkOption { type = types.str; };
  };
in
{
  nixosModule = {
    options.modules.desktop.niri = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      programs.niri.enable = true;
      nixpkgs.overlays = [ niri.overlays.niri ];

      environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri.json".text = builtins.toJSON {
        rules = [{
          pattern = {
            feature = "procname";
            matches = "niri";
          };
          profile = "GLVidHeapReuseRatio0";
        }];
        profiles = [{
          name = "GLVidHeapReuseRatio0";
          settings = [{
            key = "GLVidHeapReuseRatio";
            value = 0;
          }];
        }];
      };
    };
  };

  homeManagerModule = {
    options.modules.desktop.niri = options;

    imports = [
      ./../dunst
      ./../rofi
      ./../waybar
    ];

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      modules.desktop = {
        dunst.enable = true;
        rofi.enable = true;
        waybar.enable = true;
      };

      programs.niri.settings = {
        prefer-no-csd = true;
        hotkey-overlay.skip-at-startup = true;
        screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";

        outputs."*" = {
          scale = cfg.scale;
        };

        input = {
          keyboard.xkb.layout = "de";
          mouse.accel-profile = "flat";
          focus-follows-mouse.enable = false;
        };

        layout = {
          gaps = 16;
          focus-ring.enable = false;
          border = {
            enable = true;
            width = 2;
            active.color = cfg.activeBorderColor;
            inactive.color = cfg.inactiveBorderColor;
          };

          default-column-width.proportion = 0.5;
          preset-column-widths = [
            { proportion = 0.33; }
            { proportion = 0.5; }
            { proportion = 0.67; }
          ];
        };

        spawn-at-startup = [
          { command = [ "${pkgs.swaybg}/bin/swaybg" "-i" "${toString desktopCfg.wallpaper}" "-m" "fill" ]; }
          { command = [ "${pkgs.waybar}/bin/waybar" ]; }
        ];

        environment = {
          NIXOS_OZONE_WL = "1";
        };

        binds = {
          "Mod+T".action.spawn = [ "env" "-u" "DISPLAY" "${pkgs.kitty}/bin/kitty" ];
          "Mod+B".action.spawn = [ "${pkgs.google-chrome}/bin/google-chrome-stable" "--enable-unsafe-webgpu" ];
          "Mod+E".action.spawn = [ "${pkgs.thunar}/bin/thunar" ];
          "Mod+Space".action.spawn = [ "${rofiCfg.launcher}/bin/launcher" ];
          "Mod+Escape".action.spawn = [ "lock-screen" ];

          "Mod+Q".action.close-window = {};
          "Mod+F".action.maximize-column = {};
          "Mod+M".action.expand-column-to-available-width = {};
          "Mod+Shift+F".action.fullscreen-window = {};
          "Mod+G".action.toggle-window-floating = {};
          "Mod+Tab".action.toggle-overview = {};
          "Mod+O".action.toggle-overview = {};

          "Mod+H".action.focus-column-left = {};
          "Mod+J".action.focus-window-down = {};
          "Mod+K".action.focus-window-up = {};
          "Mod+L".action.focus-column-right = {};
          "Mod+Left".action.focus-column-left = {};
          "Mod+Down".action.focus-window-down = {};
          "Mod+Up".action.focus-window-up = {};
          "Mod+Right".action.focus-column-right = {};

          "Mod+Shift+H".action.move-column-left = {};
          "Mod+Shift+J".action.move-window-down = {};
          "Mod+Shift+K".action.move-window-up = {};
          "Mod+Shift+L".action.move-column-right = {};

          "Mod+Ctrl+H".action.focus-workspace-down = {};
          "Mod+Ctrl+L".action.focus-workspace-up = {};

          "Mod+Shift+Ctrl+H".action.move-window-to-workspace-down = {};
          "Mod+Shift+Ctrl+L".action.move-window-to-workspace-up = {};

          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;

          "Mod+Shift+1".action.move-window-to-workspace = 1;
          "Mod+Shift+2".action.move-window-to-workspace = 2;
          "Mod+Shift+3".action.move-window-to-workspace = 3;
          "Mod+Shift+4".action.move-window-to-workspace = 4;
          "Mod+Shift+5".action.move-window-to-workspace = 5;
          "Mod+Shift+6".action.move-window-to-workspace = 6;
          "Mod+Shift+7".action.move-window-to-workspace = 7;
          "Mod+Shift+8".action.move-window-to-workspace = 8;

          "Mod+R".action.switch-preset-column-width = {};
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Comma".action.consume-window-into-column = {};
          "Mod+Period".action.expel-window-from-column = {};
          "Mod+C".action.center-column = {};
          "Mod+W".action.toggle-column-tabbed-display = {};

          "Print".action.screenshot = {};
          "Ctrl+Print".action.screenshot-screen = {};
          "Alt+Print".action.screenshot-window = {};

          "Mod+Alt+H".action.focus-monitor-left = {};
          "Mod+Alt+L".action.focus-monitor-right = {};
          "Mod+Alt+Shift+H".action.move-column-to-monitor-left = {};
          "Mod+Alt+Shift+L".action.move-column-to-monitor-right = {};

          "Mod+Shift+Slash".action.show-hotkey-overlay = {};
          "Mod+Shift+E".action.quit.skip-confirmation = true;

          "Mod+WheelScrollDown".action.focus-column-right = {};
          "Mod+WheelScrollUp".action.focus-column-left = {};
          "Mod+Shift+WheelScrollDown".action.focus-workspace-down = {};
          "Mod+Shift+WheelScrollUp".action.focus-workspace-up = {};
        };
      };

      home.packages = with pkgs; [
        wl-clipboard
        grim
        slurp
        swaybg
        xwayland-satellite
      ];
    };
  };
}
