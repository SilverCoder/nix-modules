{ ... }: {
  flake.nixosModules.sddm = { config, lib, pkgs, ... }: {
    options.modules.sddm = with lib; {
      cursor = {
        name = mkOption { type = types.str; default = "Adwaita"; };
        package = mkOption { type = types.nullOr types.package; default = null; };
        size = mkOption { type = types.int; default = 32; };
      };
      colors = {
        background = mkOption { type = types.str; };
        backgroundAlt = mkOption { type = types.str; };
        text = mkOption { type = types.str; };
        textAlt = mkOption { type = types.str; };
        accent = mkOption { type = types.str; };
        warning = mkOption { type = types.str; };
      };
    };

    config =
      let
        cfg = config.modules.sddm;
        sddm-astronaut-package = pkgs.sddm-astronaut.override {
          embeddedTheme = "black_hole";
          themeConfig = {
            Background = "/run/current-system/wallpaper";
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
        cursorPackage = if cfg.cursor.package != null then cfg.cursor.package else pkgs.adwaita-icon-theme;
      in
      {
        environment.systemPackages = [ sddm-astronaut-package cursorPackage ];

        services.displayManager.sddm = {
          enable = true;
          wayland.enable = false;
          theme = "sddm-astronaut-theme";
          extraPackages = [ sddm-astronaut-package ];
          settings = {
            General.InputMethod = "";
            Theme.CursorTheme = cfg.cursor.name;
            Theme.CursorSize = cfg.cursor.size;
            X11.ServerArguments = "-nolisten tcp";
          };
        };

        services.xserver = {
          xkb.layout = "de";
          xkb.variant = "";
          displayManager.setupCommands = ''
            ${pkgs.xrandr}/bin/xrandr --auto
          '';
        };
      };
  };
}
