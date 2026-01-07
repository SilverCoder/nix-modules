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
        (lib.mkIf (config.services.xserver.displayManager.lightdm.enable or false) {
          services.xserver.displayManager.lightdm = {
            greeters.gtk = theme.gtk;
            background = lib.mkIf (theme ? defaultWallpaper) theme.defaultWallpaper;
          };
        })
        {
          modules.desktop = theme.modules.desktop;
        }
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
        modules.desktop = lib.mkMerge [
          theme.modules.desktop
          (lib.mkIf (theme ? defaultWallpaper) {
            wallpaper = lib.mkDefault theme.defaultWallpaper;
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
