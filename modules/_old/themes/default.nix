{ lib, ... }:
let
  mkThemes = pkgs: {
    dracula = import ./dracula { inherit pkgs lib; };
  } // (import ./catppuccin { inherit pkgs lib; });

  mkThemeOption = themes: lib.mkOption {
    type = lib.types.enum (builtins.attrNames themes);
    default = "dracula";
    description = "Global theme applied to all tools";
  };
in
{
  nixosModule = { config, pkgs, ... }:
    let
      themes = mkThemes pkgs;
      theme = themes.${config.modules.theme.name};
    in
    {
      options.modules.theme.name = mkThemeOption themes;
      config = lib.mkMerge [
        (lib.mkIf (theme ? wallpaper) {
          modules.desktop.wallpaper = lib.mkDefault theme.wallpaper;
        })
        (lib.mkIf (config.services.xserver.displayManager.lightdm.enable or false) {
          services.xserver.displayManager.lightdm = {
            greeters.gtk = theme.gtk;
            background = lib.mkIf (theme ? wallpaper) theme.wallpaper;
          };
        })
        (lib.mkIf (theme ? modules.desktop.sddm) {
          modules.desktop.sddm = theme.modules.desktop.sddm;
        })
        (lib.mkIf (theme ? pointerCursor) {
          modules.desktop.sddm.cursor = {
            name = theme.pointerCursor.name;
            package = theme.pointerCursor.package;
            size = theme.pointerCursor.size;
          };
        })
      ];
    };

  homeManagerModule = { config, pkgs, ... }:
    let
      themes = mkThemes pkgs;
      theme = themes.${config.modules.theme.name};
    in
    {
      options.modules.theme.name = mkThemeOption themes;
      config = {
        inherit (theme) programs services gtk;
        home.pointerCursor = lib.mkIf (theme ? pointerCursor) theme.pointerCursor;
        modules.desktop = lib.mkMerge [
          theme.modules.desktop
          (lib.mkIf (theme ? wallpaper) {
            wallpaper = lib.mkDefault theme.wallpaper;
          })
          (lib.mkIf (theme ? powermenuImage) {
            rofi.powermenuImage = lib.mkDefault theme.powermenuImage;
          })
          (lib.mkIf (theme ? launcherImage) {
            rofi.launcherImage = lib.mkDefault theme.launcherImage;
          })
        ];
      };
    };
}
