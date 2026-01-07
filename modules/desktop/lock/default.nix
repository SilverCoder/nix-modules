{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.lock;

  # Convert #RRGGBB to RRGGBBAA format
  toRGBA = color: alpha:
    let
      hex = lib.removePrefix "#" color;
    in
    "${hex}${alpha}";

  # Betterlockscreen config (X11)
  betterlockscreenConfig = pkgs.writeText "betterlockscreenrc" ''
    # Betterlockscreen config - themed

    lockargs=()

    # Background
    bgcolor=${toRGBA cfg.colors.background "ff"}

    # Login box
    loginbox=${toRGBA cfg.colors.background "99"}
    loginshadow=00000000

    # Ring colors
    ringcolor=${toRGBA cfg.colors.accent "ff"}
    insidecolor=${toRGBA cfg.colors.background "cc"}
    separatorcolor=${toRGBA cfg.colors.backgroundAlt "ff"}

    # Verification ring
    ringvercolor=${toRGBA cfg.colors.accent "ff"}
    insidevercolor=${toRGBA cfg.colors.backgroundAlt "cc"}

    # Wrong password ring
    ringwrongcolor=${toRGBA cfg.colors.warning "ff"}
    insidewrongcolor=${toRGBA cfg.colors.warning "66"}

    # Text colors
    timecolor=${toRGBA cfg.colors.text "ff"}
    greetercolor=${toRGBA cfg.colors.textAlt "ff"}
    layoutcolor=${toRGBA cfg.colors.text "ff"}
    verifcolor=${toRGBA cfg.colors.text "ff"}
    wrongcolor=${toRGBA cfg.colors.warning "ff"}
    modifcolor=${toRGBA cfg.colors.accent "ff"}

    # Key highlight
    keyhlcolor=${toRGBA cfg.colors.accent "ff"}
    bshlcolor=${toRGBA cfg.colors.warning "ff"}

    # Effects
    fx_list=(blur)
    dim_level=${toString cfg.dimLevel}
    blur_level=${toString cfg.blurLevel}

    # Time/date format
    time_format="%H:%M"
    date_format="%A, %d %B"

    # Greeter
    greeter="${cfg.greeterText}"
    locktext=""
    font="sans-serif"

    # Display
    display_on=0
    span_image=false
  '';

  # Swaylock config (Wayland)
  swaylockConfig = pkgs.writeText "swaylock-config" ''
    daemonize
    show-failed-attempts
    ignore-empty-password

    # Effects
    screenshots
    effect-blur=${toString (cfg.blurLevel * 5)}x${toString (cfg.blurLevel * 3)}
    effect-vignette=0.5:0.5
    fade-in=0.2

    # Colors (RRGGBBAA)
    color=${toRGBA cfg.colors.background "ff"}

    # Inside
    inside-color=${toRGBA cfg.colors.background "cc"}
    inside-clear-color=${toRGBA cfg.colors.backgroundAlt "cc"}
    inside-ver-color=${toRGBA cfg.colors.backgroundAlt "cc"}
    inside-wrong-color=${toRGBA cfg.colors.warning "66"}

    # Ring
    ring-color=${toRGBA cfg.colors.accent "ff"}
    ring-clear-color=${toRGBA cfg.colors.accent "ff"}
    ring-ver-color=${toRGBA cfg.colors.accent "ff"}
    ring-wrong-color=${toRGBA cfg.colors.warning "ff"}

    # Line (between ring and inside)
    line-color=00000000
    line-clear-color=00000000
    line-ver-color=00000000
    line-wrong-color=00000000

    # Separator
    separator-color=${toRGBA cfg.colors.backgroundAlt "ff"}

    # Key highlight
    key-hl-color=${toRGBA cfg.colors.accent "ff"}
    bs-hl-color=${toRGBA cfg.colors.warning "ff"}

    # Text
    text-color=${toRGBA cfg.colors.text "ff"}
    text-clear-color=${toRGBA cfg.colors.text "ff"}
    text-ver-color=${toRGBA cfg.colors.text "ff"}
    text-wrong-color=${toRGBA cfg.colors.warning "ff"}

    # Layout
    indicator
    indicator-radius=100
    indicator-thickness=10

    # Clock
    clock
    timestr=%H:%M
    datestr=%A, %d %B

    # Font
    font=sans-serif
    font-size=24
  '';

  # Wrapper script
  lockScript = pkgs.writeShellScriptBin "lock-screen" ''
    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      exec ${pkgs.swaylock-effects}/bin/swaylock -C ${swaylockConfig}
    else
      exec ${pkgs.betterlockscreen}/bin/betterlockscreen -l blur
    fi
  '';

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable screen locker (X11 + Wayland)";
    };

    greeterText = mkOption {
      type = types.str;
      default = "Type password to unlock";
      description = "Text shown on lock screen";
    };

    blurLevel = mkOption {
      type = types.int;
      default = 1;
      description = "Blur level (1-5)";
    };

    dimLevel = mkOption {
      type = types.int;
      default = 40;
      description = "Dim level (0-100)";
    };

    colors = {
      background = mkOption {
        type = types.str;
        description = "Background color";
      };
      backgroundAlt = mkOption {
        type = types.str;
        description = "Alternate background color";
      };
      text = mkOption {
        type = types.str;
        description = "Primary text color";
      };
      textAlt = mkOption {
        type = types.str;
        description = "Secondary text color";
      };
      accent = mkOption {
        type = types.str;
        description = "Accent color";
      };
      warning = mkOption {
        type = types.str;
        description = "Warning/error color";
      };
    };
  };
in
{
  homeManagerModule = {
    options.modules.desktop.lock = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      home.packages = [
        lockScript
        pkgs.betterlockscreen
        pkgs.swaylock-effects
      ];

      # Betterlockscreen config
      xdg.configFile."betterlockscreen/betterlockscreenrc".source = betterlockscreenConfig;

      # Cache wallpaper for betterlockscreen on activation
      home.activation.betterlockscreenCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -f "${toString desktopCfg.wallpaper}" ]; then
          ${pkgs.betterlockscreen}/bin/betterlockscreen -u "${toString desktopCfg.wallpaper}" --fx blur 2>/dev/null || true
        fi
      '';
    };
  };
}
