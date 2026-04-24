{ ... }: {
  flake.nixosModules.lock = {
    security.pam.services.i3lock.enable = true;
    security.pam.services.i3lock-color.enable = true;
    security.pam.services.swaylock.enable = true;
  };

  flake.homeManagerModules.lock = { config, lib, pkgs, ... }: {
    options.modules.lock = with lib; {
      colors = {
        background = mkOption { type = types.str; };
        text = mkOption { type = types.str; };
        ring = mkOption { type = types.str; };
        ringVerify = mkOption { type = types.str; };
        ringWrong = mkOption { type = types.str; };
        ringCapsLock = mkOption { type = types.str; };
        keyHighlight = mkOption { type = types.str; };
        bsHighlight = mkOption { type = types.str; };
      };
    };

    config =
      let
        cfg = config.modules.lock;
        toRGBA = color: alpha:
          let hex = lib.removePrefix "#" color;
          in "${hex}${alpha}";

        betterlockscreenConfig = pkgs.writeText "betterlockscreenrc" ''
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
          export LC_TIME=en_US.UTF-8

          if [ "$XDG_SESSION_TYPE" = "wayland" ]; then
            exec ${pkgs.swaylock-effects}/bin/swaylock -C ${swaylockConfig}
          else
            ${pkgs.setxkbmap}/bin/setxkbmap de
            exec ${pkgs.betterlockscreen}/bin/betterlockscreen -l blur
          fi
        '';
      in
      {
        home.packages = [
          lockScript
          pkgs.betterlockscreen
          pkgs.swaylock-effects
        ];

        xdg.configFile."betterlockscreen/betterlockscreenrc".source = betterlockscreenConfig;

        home.activation.betterlockscreenCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ -f "/run/current-system/wallpaper" ]; then
            ${pkgs.betterlockscreen}/bin/betterlockscreen -u "/run/current-system/wallpaper" --fx blur 2>/dev/null || true
          fi
        '';
      };
  };
}
