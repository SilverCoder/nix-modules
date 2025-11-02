{ ... }:
let
  options = { lib, machineCfg, ... }: {
    enable = lib.mkEnableOption "desktop environment modules" // { default = machineCfg.features.desktop; };

    theme = lib.mkOption {
      type = lib.types.enum [ "dracula" ];
      default = "dracula";
      description = "Desktop theme to use";
    };

    color-scheme = lib.mkOption {
      type = lib.types.enum [ "light" "dark" ];
      default = "dark";
      description = "Color scheme preference (light or dark)";
    };

    wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to wallpaper image";
    };
  };
in
{
  nixosModule = { config, lib, pkgs, ... }:
    let
      machineCfg = config.modules.machine;
    in
    {
      options.modules.desktop = options { inherit lib machineCfg; };

      imports = [
        (import ./bspwm { inherit config lib pkgs; }).nixosModule
        (import ./cosmic { inherit config lib; }).nixosModule
        (import ./lightdm { inherit config lib pkgs; }).nixosModule
      ];
    };

  homeManagerModule = { config, lib, pkgs, ... }:
    let
      machineCfg = config.modules.machine;
      cfg = config.modules.desktop;
    in
    {
      options.modules.desktop = options { inherit lib machineCfg; };

      imports = [
        (import ./bspwm { inherit config lib pkgs; }).homeManagerModule
        (import ./lightdm { inherit config lib pkgs; }).homeManagerModule
        ./dunst
        ./localsend.nix
        ./picom
      ];

      config = lib.mkIf cfg.enable {
        programs = {
          thunderbird = {
            enable = false;
            profiles = { };
          };
        };
      };
    };
}
