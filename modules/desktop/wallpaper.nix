{ ... }: {
  flake.nixosModules.wallpaper = { config, lib, ... }: {
    options.modules.desktop.wallpaper = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to wallpaper image (symlinked to /run/current-system/wallpaper)";
    };

    config = lib.mkIf (config.modules.desktop.wallpaper != null) {
      system.systemBuilderCommands = ''
        ln -s ${config.modules.desktop.wallpaper} $out/wallpaper
      '';
    };
  };
}
