{ inputs, ... }: {
  flake.nixosModules.niri = { pkgs, ... }: {
    imports = [ inputs.niri.nixosModules.niri ];

    programs.niri.enable = true;
    # unstable for blur support; niri-flake's stable is still pinned to 25.08
    programs.niri.package = pkgs.niri-unstable;
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];

    # binary cache for niri-flake's niri-stable/niri-unstable builds
    nix.settings = {
      substituters = [ "https://niri.cachix.org" ];
      trusted-public-keys = [ "niri.cachix.org-1:Wv0OmO7PsuocRKzfDoJ3mulSl7Z6oezYhGhR+3W2964=" ];
    };

    xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome ];
    # niri screencast goes through the gnome (Mutter) backend; wlr backend doesn't work under niri.
    xdg.portal.config.niri.default = [ "gnome" ];
    # gnome backend's FileChooser is broken under niri (no dialog appears); route it to gtk.
    xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = [ "gtk" ];

    environment.etc."nvidia/nvidia-application-profiles-rc.d/50-niri.json".text = builtins.toJSON {
      rules = [{
        pattern = { feature = "procname"; matches = "niri"; };
        profile = "GLVidHeapReuseRatio0";
      }];
      profiles = [{
        name = "GLVidHeapReuseRatio0";
        settings = [{ key = "GLVidHeapReuseRatio"; value = 0; }];
      }];
    };
  };

  flake.homeManagerModules.niri = { config, options, lib, osConfig, pkgs, ... }: {
    options.modules.niri = with lib; {
      scale = mkOption {
        type = types.float;
        default = 1.0;
      };
      outputs = mkOption {
        type = types.listOf (types.submodule {
          options = {
            name = mkOption { type = types.str; };
            scale = mkOption { type = types.float; default = 1.0; };
            position = mkOption { type = types.nullOr (types.attrsOf types.int); default = null; };
            primary = mkOption { type = types.bool; default = false; };
          };
        });
        default = [ ];
      };
      activeBorderColor = mkOption { type = types.str; };
      inactiveBorderColor = mkOption { type = types.str; };
    };

    config =
      let
        cfg = config.modules.niri;
        rofiCfg = config.modules.rofi;
        wallpaper = osConfig.modules.desktop.wallpaper or null;
      in
      {
        home.sessionVariables.DISPLAY = ":2";

        gtk.enable = true;

        programs.niri.settings = {
          prefer-no-csd = true;
          hotkey-overlay.skip-at-startup = true;
          screenshot-path = "~/Pictures/Screenshots/%Y-%m-%dT%H:%M:%S.png";
          gestures.hot-corners.enable = false;

          outputs = if cfg.outputs == [ ] then {
            "*" = { scale = cfg.scale; };
          } else builtins.listToAttrs (map
            (o: {
              name = o.name;
              value = { scale = o.scale; } // lib.optionalAttrs (o.position != null) { position = o.position; };
            })
            cfg.outputs);

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

          spawn-at-startup = lib.optional (wallpaper != null)
            { command = [ "${pkgs.swaybg}/bin/swaybg" "-i" "/run/current-system/wallpaper" "-m" "fill" ]; }
          ++ [
            { command = [ "${pkgs.waybar}/bin/waybar" ]; }
          ];

          environment = {
            DISPLAY = ":2";
            NIXOS_OZONE_WL = "1";
          };

          binds =
            let
              monitorBinds = lib.listToAttrs (lib.imap0
                (i: o: {
                  name = "Mod+Ctrl+${toString (i + 1)}";
                  value = { action.focus-monitor = o.name; };
                })
                cfg.outputs);
            in
            monitorBinds // {
              "Mod+T".action.spawn = [ "${pkgs.kitty}/bin/kitty" ];
              "Mod+B".action.spawn = [ "${pkgs.google-chrome}/bin/google-chrome-stable" ];
              "Mod+E".action.spawn = [ "${pkgs.thunar}/bin/thunar" ];
              "Mod+Space".action.spawn = [ "${rofiCfg.launcher}/bin/launcher" ];
              "Mod+Escape".action.spawn = [ "lock-screen" ];

              "Mod+Q".action.close-window = { };
              "Mod+F".action.fullscreen-window = { };
              "Mod+M".action.expand-column-to-available-width = { };
              "Mod+Shift+M".action.maximize-column = { };
              "Mod+G".action.toggle-window-floating = { };
              "Mod+O".action.toggle-overview = { };

              "Mod+H".action.focus-column-left = { };
              "Mod+J".action.focus-window-down = { };
              "Mod+K".action.focus-window-up = { };
              "Mod+L".action.focus-column-right = { };
              "Mod+Left".action.focus-column-left = { };
              "Mod+Down".action.focus-window-down = { };
              "Mod+Up".action.focus-window-up = { };
              "Mod+Right".action.focus-column-right = { };

              "Mod+Shift+H".action.move-column-left = { };
              "Mod+Shift+J".action.move-window-down = { };
              "Mod+Shift+K".action.move-window-up = { };
              "Mod+Shift+L".action.move-column-right = { };

              "Mod+Ctrl+H".action.focus-monitor-left = { };
              "Mod+Ctrl+L".action.focus-monitor-right = { };

              "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = { };
              "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = { };

              "Mod+Ctrl+J".action.focus-workspace-down = { };
              "Mod+Ctrl+K".action.focus-workspace-up = { };
              "Mod+Shift+Ctrl+J".action.move-window-to-workspace-down = { };
              "Mod+Shift+Ctrl+K".action.move-window-to-workspace-up = { };

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

              "Mod+R".action.switch-preset-column-width = { };
              "Mod+Minus".action.set-column-width = "-10%";
              "Mod+Equal".action.set-column-width = "+10%";
              "Mod+Comma".action.consume-window-into-column = { };
              "Mod+Period".action.expel-window-from-column = { };
              "Mod+C".action.center-column = { };
              "Mod+W".action.toggle-column-tabbed-display = { };

              "Print".action.spawn = [ "sh" "-c" ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp)" - | ${pkgs.satty}/bin/satty -f -'' ];
              "Ctrl+Print".action.spawn = [ "sh" "-c" ''${pkgs.grim}/bin/grim - | ${pkgs.satty}/bin/satty -f -'' ];
              "Alt+Print".action.spawn = [ "sh" "-c" ''${pkgs.grim}/bin/grim -g "$(${pkgs.slurp}/bin/slurp -o)" - | ${pkgs.satty}/bin/satty -f -'' ];

              "Mod+Shift+Slash".action.show-hotkey-overlay = { };
              "Mod+Shift+E".action.quit = { };

              "XF86AudioRaiseVolume".action.spawn = [ "${pkgs.pulseaudio}/bin/pactl" "set-sink-volume" "@DEFAULT_SINK@" "+5%" ];
              "XF86AudioLowerVolume".action.spawn = [ "${pkgs.pulseaudio}/bin/pactl" "set-sink-volume" "@DEFAULT_SINK@" "-5%" ];
              "XF86AudioMute".action.spawn = [ "${pkgs.pulseaudio}/bin/pactl" "set-sink-mute" "@DEFAULT_SINK@" "toggle" ];
              "XF86MonBrightnessUp".action.spawn = [ "${pkgs.brightnessctl}/bin/brightnessctl" "set" "+5%" ];
              "XF86MonBrightnessDown".action.spawn = [ "${pkgs.brightnessctl}/bin/brightnessctl" "set" "5%-" ];
              "XF86AudioPlay".action.spawn = [ "${pkgs.playerctl}/bin/playerctl" "play-pause" ];
              "XF86AudioNext".action.spawn = [ "${pkgs.playerctl}/bin/playerctl" "next" ];
              "XF86AudioPrev".action.spawn = [ "${pkgs.playerctl}/bin/playerctl" "previous" ];
              "XF86Calculator".action.spawn = [ "${pkgs.gnome-calculator}/bin/gnome-calculator" ];

              "Mod+WheelScrollDown".action.focus-column-right = { };
              "Mod+WheelScrollUp".action.focus-column-left = { };
              "Mod+Shift+WheelScrollDown".action.focus-workspace-down = { };
              "Mod+Shift+WheelScrollUp".action.focus-workspace-up = { };
            };
        };

        # niri-flake's settings schema doesn't cover background-effect yet;
        # append the blur rules as raw KDL nodes to the rendered settings.
        # real (non-xray) blur: blurs windows beneath, not just the wallpaper.
        # experimental upstream: drops out during animations/window drag.
        # match-less rules apply to every window/layer; blur is only visible
        # behind transparent pixels, so opaque surfaces are unaffected.
        # slurp's fullscreen overlay (namespace "selection") is excluded, else
        # the whole desktop blurs while picking a region screenshot.
        programs.niri.config =
          let
            inherit (inputs.niri.lib) kdl;
            blur = kdl.node "background-effect" [ ] [
              (kdl.leaf "blur" true)
              (kdl.leaf "xray" false)
            ];
          in
          options.programs.niri.config.default ++ [
            (kdl.node "window-rule" [ ] [ blur ])
            (kdl.node "layer-rule" [ ] [
              (kdl.leaf "exclude" { namespace = "^selection$"; })
              blur
            ])
            (kdl.node "blur" [ ] [
              (kdl.leaf "passes" 2)
              (kdl.leaf "offset" 2)
            ])
          ];

        home.packages = with pkgs; [
          wl-clipboard
          grim
          slurp
          satty
          swaybg
          xwayland-satellite
        ];

        systemd.user.services.xwayland-satellite = {
          Unit = {
            Description = "XWayland Satellite";
            PartOf = [ "graphical-session.target" ];
            After = [ "graphical-session.target" ];
          };
          Service = {
            ExecStart = "${pkgs.xwayland-satellite}/bin/xwayland-satellite :2";
            Restart = "on-failure";
            RestartSec = 3;
          };
          Install = {
            WantedBy = [ "graphical-session.target" ];
          };
        };
      };
  };
}
