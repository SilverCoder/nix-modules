{ niri ? null, ... }:
let
  options = { lib, machineCfg, ... }: {
    enable = lib.mkEnableOption "desktop environment modules" // { default = machineCfg.features.desktop; };

    nm-applet = {
      enable = lib.mkEnableOption "NetworkManager applet in system tray" // { default = true; };
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
        (import ./cosmic { inherit config lib pkgs; }).nixosModule
        (import ./lightdm { inherit config lib pkgs; }).nixosModule
        (import ./lock { inherit config lib pkgs; }).nixosModule
        (import ./niri { inherit config lib pkgs niri; }).nixosModule
        (import ./sddm { inherit config lib pkgs; }).nixosModule
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
        (import ./cosmic { inherit config lib pkgs; }).homeManagerModule
        (import ./lightdm { inherit config lib pkgs; }).homeManagerModule
        (import ./lock { inherit config lib pkgs; }).homeManagerModule
        (import ./niri { inherit config lib pkgs niri; }).homeManagerModule
        (import ./sddm { inherit config lib pkgs; }).homeManagerModule
        ./dunst
        ./localsend.nix
        ./picom
        ./waybar
      ];

      config = lib.mkIf cfg.enable {
        programs = {
          thunderbird = {
            enable = false;
            profiles = { };
          };
        };

        services.network-manager-applet.enable = cfg.nm-applet.enable;
      };
    };
}
