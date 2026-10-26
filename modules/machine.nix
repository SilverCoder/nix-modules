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

      # CVE-2026-111497 et al.: nixpkgs default nodejs (24) is unpatched; drop once nodejs_24 >= 24.22.1
      nixpkgs.overlays = [
        (final: prev: {
          nodejs = final.nodejs_26;
          nodejs-slim = final.nodejs-slim_26;
          # signal-desktop, bitwarden-desktop pin nodejs_24
          nodejs_24 = final.nodejs_26;
          nodejs-slim_24 = final.nodejs-slim_26;
        })
      ];
    };
  };

  flake.homeManagerModules.host = { lib, ... }: {
    options.host = {
      name = lib.mkOption { type = lib.types.str; };
      features.desktop = lib.mkOption { type = lib.types.bool; default = true; };
    };
  };
}
