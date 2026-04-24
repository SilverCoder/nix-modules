{ ... }:
let
  featuresModule = { lib, ... }: lib.types.submodule {
    options = {
      desktop = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable desktop environment features";
      };
    };
  };

  options = { lib, CONFIG, ... }: {
    name = lib.mkOption {
      type = lib.types.str;
      default = CONFIG.hostname;
      description = "Machine hostname";
    };

    features = lib.mkOption {
      type = featuresModule { inherit lib; };
      default = { };
      description = "Machine-specific feature flags";
    };
  };
in
{
  nixosModule = { config, lib, CONFIG, ... }:
    let
      cfg = config.modules.machine;
    in
    {
      options.modules.machine = options { inherit lib CONFIG; };

      config = {
        networking = {
          hostName = cfg.name;
        };
      };
    };

  homeManagerModule = { lib, CONFIG, ... }: {
    options.modules.machine = options { inherit lib CONFIG; };
  };
}
