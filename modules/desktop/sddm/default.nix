{ config, lib, pkgs, ... }:
let
  desktopCfg = config.modules.desktop;
  cfg = config.modules.desktop.sddm;

  options = with lib; {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable SDDM display manager";
    };

    colors = {
      background = mkOption {
        type = types.str;
        description = "Background color (base00)";
      };
      backgroundAlt = mkOption {
        type = types.str;
        description = "Alternate background for inputs/buttons (base02)";
      };
      text = mkOption {
        type = types.str;
        description = "Primary text color (base05)";
      };
      textAlt = mkOption {
        type = types.str;
        description = "Secondary text color (base04)";
      };
      accent = mkOption {
        type = types.str;
        description = "Accent color for hover states (base0E)";
      };
      warning = mkOption {
        type = types.str;
        description = "Warning color (base08)";
      };
    };
  };
in
{
  nixosModule = {
    options.modules.desktop.sddm = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) (
      let
        sddm-astronaut-package = pkgs.sddm-astronaut.override {
          embeddedTheme = "black_hole";
          themeConfig = {
            Background = toString desktopCfg.wallpaper;
            FormBackgroundColor = cfg.colors.background;
            BackgroundColor = cfg.colors.background;
            DimBackgroundColor = cfg.colors.background;
            LoginFieldBackgroundColor = cfg.colors.backgroundAlt;
            PasswordFieldBackgroundColor = cfg.colors.backgroundAlt;
            LoginFieldTextColor = cfg.colors.text;
            PasswordFieldTextColor = cfg.colors.text;
            UserIconColor = cfg.colors.text;
            PasswordIconColor = cfg.colors.text;
            PlaceholderTextColor = cfg.colors.textAlt;
            WarningColor = cfg.colors.warning;
            LoginButtonTextColor = cfg.colors.text;
            LoginButtonBackgroundColor = cfg.colors.backgroundAlt;
            SystemButtonsIconsColor = cfg.colors.text;
            SessionButtonTextColor = cfg.colors.text;
            VirtualKeyboardButtonTextColor = cfg.colors.text;
            DropdownTextColor = cfg.colors.text;
            DropdownSelectedBackgroundColor = cfg.colors.backgroundAlt;
            DropdownBackgroundColor = cfg.colors.background;
            HighlightTextColor = cfg.colors.textAlt;
            HighlightBackgroundColor = cfg.colors.backgroundAlt;
            HighlightBorderColor = cfg.colors.backgroundAlt;
            HoverUserIconColor = cfg.colors.accent;
            HoverPasswordIconColor = cfg.colors.accent;
            HoverSystemButtonsIconsColor = cfg.colors.accent;
            HoverSessionButtonTextColor = cfg.colors.accent;
            HoverVirtualKeyboardButtonTextColor = cfg.colors.accent;
            HeaderTextColor = cfg.colors.text;
            DateTextColor = cfg.colors.text;
            TimeTextColor = cfg.colors.text;
          };
        };
      in
      {
        environment.systemPackages = [ sddm-astronaut-package ];

        services.displayManager.sddm = {
          enable = true;
          wayland.enable = false;
          theme = "sddm-astronaut-theme";
          extraPackages = [ sddm-astronaut-package ];
          settings = {
            General = {
              InputMethod = "";
            };
            X11 = {
              ServerArguments = "-nolisten tcp";
            };
          };
        };

        services.xserver = {
          xkb = {
            layout = "de";
            variant = "";
          };
          displayManager.setupCommands = ''
            ${pkgs.xorg.xrandr}/bin/xrandr --auto
          '';
        };
      }
    );
  };

  homeManagerModule = {
    options.modules.desktop.sddm = options;
  };
}
