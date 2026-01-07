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

    colors = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "SDDM theme colors (set by theme module)";
    };
  };

  themePackage = pkgs.sddm-astronaut.override {
    embeddedTheme = "black_hole";
    themeConfig = {
      Background = toString desktopCfg.wallpaper;
      FormBackgroundColor = cfg.colors.background;
      BackgroundColor = cfg.colors.background;
      DimBackgroundColor = cfg.colors.background;
      LoginFieldBackgroundColor = cfg.colors.surface;
      PasswordFieldBackgroundColor = cfg.colors.surface;
      LoginFieldTextColor = cfg.colors.text;
      PasswordFieldTextColor = cfg.colors.text;
      UserIconColor = cfg.colors.text;
      PasswordIconColor = cfg.colors.text;
      PlaceholderTextColor = cfg.colors.textDim;
      WarningColor = cfg.colors.warning;
      LoginButtonTextColor = cfg.colors.text;
      LoginButtonBackgroundColor = cfg.colors.surface;
      SystemButtonsIconsColor = cfg.colors.text;
      SessionButtonTextColor = cfg.colors.text;
      VirtualKeyboardButtonTextColor = cfg.colors.text;
      DropdownTextColor = cfg.colors.text;
      DropdownSelectedBackgroundColor = cfg.colors.surface;
      DropdownBackgroundColor = cfg.colors.background;
      HighlightTextColor = cfg.colors.textDim;
      HighlightBackgroundColor = cfg.colors.surface;
      HighlightBorderColor = cfg.colors.surface;
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
  nixosModule = {
    options.modules.desktop.sddm = options;

    config = lib.mkIf (desktopCfg.enable && cfg.enable) {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
        theme = "sddm-astronaut-theme";
        package = pkgs.kdePackages.sddm;
      };

      services.xserver.xkb = {
        layout = "de";
        variant = "";
      };

      environment.systemPackages = [ themePackage ];
    };
  };

  homeManagerModule = {
    options.modules.desktop.sddm = options;
  };
}
