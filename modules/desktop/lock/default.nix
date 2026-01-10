{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.lock;

  toRGBA = color: alpha:
    let hex = lib.removePrefix "#" color;
    in "${hex}${alpha}";

  betterlockscreenConfig = pkgs.writeText "betterlockscreenrc" ''
    # layout: centered ring with time/date INSIDE (catppuccin style)
    lockargs=(
      --pass-media-keys --pass-screen-keys --pass-volume-keys --pass-power-keys
      --indicator --clock --force-clock
      --radius 100 --ring-width 7
      --ind-pos="x+w/2:y+h/2"
      --time-str="%H:%M"
      --time-pos="ix:iy-15"
      --time-align=0
      --time-color=${toRGBA cfg.colors.text "ff"}
      --date-str="%A %d.%m.%Y"
      --date-pos="ix:iy+20"
      --date-align=0
      --date-color=${toRGBA cfg.colors.text "ff"}
      --time-font="Fira Sans" --date-font="Fira Sans"
      --time-size=28 --date-size=12
      --verif-text="" --wrong-text="" --noinput-text=""
    )

    # catppuccin-style: transparent insides, colored rings
    bgcolor=${toRGBA cfg.colors.background "ff"}
    loginbox=00000000
    loginshadow=00000000

    ringcolor=${toRGBA cfg.colors.ring "ff"}
    insidecolor=00000000
    separatorcolor=00000000

    ringvercolor=${toRGBA cfg.colors.ringVerify "ff"}
    insidevercolor=00000000

    ringwrongcolor=${toRGBA cfg.colors.ringWrong "ff"}
    insidewrongcolor=00000000

    timecolor=${toRGBA cfg.colors.text "ff"}
    datecolor=${toRGBA cfg.colors.text "ff"}
    greetercolor=${toRGBA cfg.colors.text "ff"}
    layoutcolor=${toRGBA cfg.colors.text "ff"}
    verifcolor=${toRGBA cfg.colors.ringVerify "ff"}
    wrongcolor=${toRGBA cfg.colors.ringWrong "ff"}
    modifcolor=${toRGBA cfg.colors.ringCapsLock "ff"}

    keyhlcolor=${toRGBA cfg.colors.keyHighlight "ff"}
    bshlcolor=${toRGBA cfg.colors.bsHighlight "ff"}

    fx_list=(blur)
    dim_level=0
    blur_level=1

    greeter=""
    locktext=""

    display_on=0
    span_image=false
  '';

  swaylockConfig = pkgs.writeText "swaylock-config" ''
    show-failed-attempts
    ignore-empty-password
    indicator-caps-lock

    screenshots
    effect-blur=10x5
    effect-vignette=0.3:0.0
    fade-in=0.2

    # catppuccin-style: transparent insides, colored rings
    color=${toRGBA cfg.colors.background "ff"}
    inside-color=00000000
    inside-clear-color=00000000
    inside-caps-lock-color=00000000
    inside-ver-color=00000000
    inside-wrong-color=00000000

    ring-color=${toRGBA cfg.colors.ring "ff"}
    ring-clear-color=${toRGBA cfg.colors.bsHighlight "ff"}
    ring-caps-lock-color=${toRGBA cfg.colors.ringCapsLock "ff"}
    ring-ver-color=${toRGBA cfg.colors.ringVerify "ff"}
    ring-wrong-color=${toRGBA cfg.colors.ringWrong "ff"}

    line-color=00000000
    line-clear-color=00000000
    line-caps-lock-color=00000000
    line-ver-color=00000000
    line-wrong-color=00000000

    separator-color=00000000
    key-hl-color=${toRGBA cfg.colors.keyHighlight "ff"}
    bs-hl-color=${toRGBA cfg.colors.bsHighlight "ff"}
    caps-lock-bs-hl-color=${toRGBA cfg.colors.bsHighlight "ff"}
    caps-lock-key-hl-color=${toRGBA cfg.colors.keyHighlight "ff"}

    text-color=${toRGBA cfg.colors.text "ff"}
    text-clear-color=${toRGBA cfg.colors.bsHighlight "ff"}
    text-caps-lock-color=${toRGBA cfg.colors.ringCapsLock "ff"}
    text-ver-color=${toRGBA cfg.colors.ringVerify "ff"}
    text-wrong-color=${toRGBA cfg.colors.ringWrong "ff"}

    layout-bg-color=00000000
    layout-border-color=00000000
    layout-text-color=${toRGBA cfg.colors.text "ff"}

    # layout: centered ring with time/date INSIDE (catppuccin style)
    indicator
    indicator-radius=100
    indicator-thickness=7
    clock
    timestr=%H:%M
    datestr=%A %d.%m.%Y
    font=Fira Sans
    font-size=28
  '';

  lockScript = pkgs.writeShellScriptBin "lock-screen" ''
    # Force English for day/month names
    export LC_TIME=en_US.UTF-8

    if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
      exec ${pkgs.swaylock-effects}/bin/swaylock -C ${swaylockConfig}
    else
      # Ensure keyboard layout is set before locking
      ${pkgs.xorg.setxkbmap}/bin/setxkbmap de
      exec ${pkgs.betterlockscreen}/bin/betterlockscreen -l blur
    fi
  '';

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable screen locker";
    };

    colors = {
      background = mkOption { type = types.str; description = "Background color (base00)"; };
      text = mkOption { type = types.str; description = "Primary text color (base05)"; };
      ring = mkOption { type = types.str; description = "Ring color - normal state (lavender/base07)"; };
      ringVerify = mkOption { type = types.str; description = "Ring color - verifying (blue/base0D)"; };
      ringWrong = mkOption { type = types.str; description = "Ring color - wrong password (red/base08)"; };
      ringCapsLock = mkOption { type = types.str; description = "Ring color - caps lock (peach/base09)"; };
      keyHighlight = mkOption { type = types.str; description = "Key press highlight (green/base0B)"; };
      bsHighlight = mkOption { type = types.str; description = "Backspace highlight (rosewater/base06)"; };
    };
  };
in
{
  nixosModule = { lib, ... }: {
    options.modules.desktop.lock.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable screen locker";
    };

    # PAM for screen lockers (X11 + Wayland) - always enabled
    config.security.pam.services.i3lock.enable = true;
    config.security.pam.services.i3lock-color.enable = true;
    config.security.pam.services.swaylock.enable = true;
  };

  homeManagerModule = {
    options.modules.desktop.lock = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      home.packages = [
        lockScript
        pkgs.betterlockscreen
        pkgs.swaylock-effects
      ];

      xdg.configFile."betterlockscreen/betterlockscreenrc".source = betterlockscreenConfig;

      home.activation.betterlockscreenCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -f "${toString desktopCfg.wallpaper}" ]; then
          ${pkgs.betterlockscreen}/bin/betterlockscreen -u "${toString desktopCfg.wallpaper}" --fx blur 2>/dev/null || true
        fi
      '';
    };
  };
}
