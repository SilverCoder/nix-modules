{ config, lib, pkgs, ... }:
let
  cfg = config.modules.desktop.rofi;
in
{
  options.modules.desktop.rofi = with lib; {
    enable = lib.mkEnableOption "rofi application launcher and menu system";

    colors = mkOption {
      type = types.attrsOf types.str;
      default = {};
      description = "Rofi colors for custom scripts (set by theme module)";
    };

    powermenu = mkOption {
      type = types.package;
      default = pkgs.callPackage ./powermenu.nix { inherit config; };
    };

    launcher = mkOption {
      type = types.package;
      default = pkgs.callPackage ./launcher.nix { inherit config; };
    };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      rofi.enable = true;
    };
  };
}
