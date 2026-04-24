{ lib, ... }: {
  options.host = {
    name = lib.mkOption {
      type = lib.types.str;
      description = "Machine hostname";
    };

    features.desktop = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Desktop features available (set false for servers/wsl)";
    };
  };

  config.flake.nixosModules.host = { config, ... }: {
    networking.hostName = config.host.name;
  };
}
