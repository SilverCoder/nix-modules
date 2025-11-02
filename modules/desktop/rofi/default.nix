{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop.rofi;
in
{
  options.modules.desktop.rofi = with lib; {
    enable = lib.mkEnableOption "rofi application launcher and menu system";

    powermenu = mkOption {
      type = types.package;
      default = pkgs.callPackage ./powermenu.nix { };
    };

    launcher = mkOption {
      type = types.package;
      default = pkgs.callPackage ./launcher.nix { };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      rofi.enable = true;
    };
  };
}
