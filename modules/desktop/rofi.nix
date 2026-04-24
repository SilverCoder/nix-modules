{ ... }: {
  flake.homeManagerModules.rofi = { config, lib, pkgs, ... }: {
    options.modules.rofi = with lib; {
      colors = mkOption {
        type = types.attrsOf types.str;
        default = { };
      };

      powermenuImage = mkOption {
        type = types.nullOr types.path;
        default = null;
      };

      launcherImage = mkOption {
        type = types.nullOr types.path;
        default = null;
      };

      powermenu = mkOption {
        type = types.package;
        readOnly = true;
      };

      launcher = mkOption {
        type = types.package;
        readOnly = true;
      };
    };

    config = {
      modules.rofi = {
        powermenu = pkgs.callPackage ../../lib/rofi/powermenu.nix { inherit config; };
        launcher = pkgs.callPackage ../../lib/rofi/launcher.nix { inherit config; };
      };

      programs.rofi.enable = true;
    };
  };
}
