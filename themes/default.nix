{ lib, ... }:
let
  mkThemes = pkgs: {
    dracula = import ./dracula.nix { inherit pkgs lib; };
  };

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
      config = lib.mkIf (config.modules.desktop.enable or false && config.modules.desktop.lightdm.enable or false) {
        services.xserver.displayManager.lightdm.greeters.gtk = theme.gtk;
      };
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
        modules.desktop = theme.modules.desktop;
      };
    };
}
