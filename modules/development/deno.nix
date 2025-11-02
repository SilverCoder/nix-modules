{ config, lib, pkgs, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.deno;
in
{
  options.modules.development.deno = {
    enable = lib.mkEnableOption "Deno runtime" // { default = true; };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {
    home = {
      packages = with pkgs; [ deno ];
    };
  };
}
