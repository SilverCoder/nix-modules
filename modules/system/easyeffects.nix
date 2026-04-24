{ lib, ... }: {
  options.modules.easyeffects = with lib; {
    presets = mkOption {
      type = types.listOf types.str;
      default = [ "Bass Boosted" ];
    };
    preset = mkOption {
      type = types.str;
      default = "Bass Boosted";
    };
  };

  config.flake.homeManagerModules.easyeffects = { config, lib, pkgs, ... }:
    let
      cfg = config.modules.easyeffects;
      owner = "JackHack96";
      repo = "EasyEffects-Presets";
      rev = "master";
      sha256 = "sha256-t+9E1l0ejRCmIUu8dK3e+0OX4lslRm1AN7yHUfd9frg=";
    in
    {
      home.file = lib.mkMerge [
        {
          ".config/easyeffects/irs" = {
            source = (pkgs.fetchFromGitHub { inherit owner repo rev sha256; } + "/irs");
            recursive = true;
          };
        }
        (builtins.listToAttrs (builtins.map
          (preset: lib.nameValuePair (".config/easyeffects/output/${preset}.json") ({
            source = (pkgs.fetchFromGitHub { inherit owner repo rev sha256; } + "/${preset}.json");
          }))
          cfg.presets))
      ];

      services.easyeffects = {
        enable = true;
        preset = cfg.preset;
      };
    };
}
