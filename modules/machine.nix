{ ... }: {
  flake.nixosModules.host = { lib, config, ... }: {
    options.host = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Machine hostname";
      };

      features.desktop = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Desktop features available";
      };
    };

    config = {
      networking.hostName = config.host.name;
    };
  };

  flake.homeManagerModules.host = { lib, ... }: {
    options.host = {
      name = lib.mkOption { type = lib.types.str; };
      features.desktop = lib.mkOption { type = lib.types.bool; default = true; };
    };
  };
}
