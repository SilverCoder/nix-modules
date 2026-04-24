{ lib, ... }: {
  options.modules.rofi = with lib; {
    colors = mkOption {
      type = types.attrsOf types.str;
      default = { };
      description = "Rofi colors for custom scripts (set by theme module)";
    };

    powermenuImage = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Background image for the power menu";
    };

    launcherImage = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Background image for the launcher";
    };

    powermenu = mkOption {
      type = types.package;
      readOnly = true;
      description = "Powermenu launcher package";
    };

    launcher = mkOption {
      type = types.package;
      readOnly = true;
      description = "Launcher package";
    };
  };

  config.flake.homeManagerModules.rofi = { config, pkgs, ... }: {
    modules.rofi = {
      powermenu = pkgs.callPackage ../../lib/rofi/powermenu.nix { inherit config; };
      launcher = pkgs.callPackage ../../lib/rofi/launcher.nix { inherit config; };
    };

    programs.rofi.enable = true;
  };
}
