{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.sxhkd;
  rofiCfg = config.modules.desktop.rofi;
in
{
  options.modules.desktop.sxhkd = {
    enable = lib.mkEnableOption "sxhkd hotkey daemon for bspwm";
  };

  config = lib.mkIf (desktopCfg.enable && cfg.enable) {
    services = {
      sxhkd =
        let
          resizeNode = pkgs.writeShellScript "resize_node" ''
            motion="$1"
            direction="$2"
            size="$3"

            if [ "$motion" = 'expand' ]; then
            	# These expand the window's given side
            	case "$direction" in
            		west) bspc node -z left -"$size" 0 ;;
            		south) bspc node -z top 0 "$size" ;;
            		north) bspc node -z top 0 -"$size" ;;
            		east) bspc node -z left "$size" 0 ;;
            	esac
            else
            	# These contract the window's given side
            	case "$direction" in
            		west) bspc node -z right -"$size" 0 ;;
            		south) bspc node -z bottom 0 -"$size" ;;
            		north) bspc node -z bottom 0 "$size" ;;
            		east) bspc node -z right "$size" 0 ;;
            	esac
            fi      
          '';
        in
        {
          enable = true;
          keybindings = with pkgs; {
            "super + Escape" = "lock-screen";
            "super + space" = "${rofiCfg.launcher}/bin/launcher";
            "super + Tab" = "${rofiCfg.launcher}/bin/launcher window";
            "super + b" = "${google-chrome}/bin/google-chrome-stable --enable-unsafe-webgpu";
            "super + f" = "thunar";
            "super + t" = "${kitty}/bin/kitty";

            "super + q" = "bspc node -c";
            "super + m" = "bspc node -t {fullscreen,tiled} -f";
            "super + g" = "bspc node -t {floating,tiled} -f";

            "super + {h,j,k,l}" = "bspc node -f {west,south,north,east}";
            "super + {ctrl +}{h,l}" = "bspc desktop -f {prev,next}";
            "super + {shift +}{h,l}" = "bspc node -d {prev,next} --follow";
            "super + {shift +}{j,k}" = "bspc node @/ -C {forward,backward}";
            "super + {_, shift +}{1-8,0}" = "bspc {desktop -f, node -d} '^{1-8,9}' --follow";

            "super + Return: {h,j,k,l}" = "bspc node -s {west,south,north,east}";
            "super + shift + Return: {_, shift +}{h,j,k,l}" = "${resizeNode} {expand, contract} {west,south,north,east} 10";
          };
        };

    };
  };
}
