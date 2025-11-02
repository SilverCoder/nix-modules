{ config, lib, pkgs, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.dotnet;
in
{
  options.modules.development.dotnet = {
    enable = lib.mkEnableOption ".NET development SDK" // { default = true; };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {
    home = {
      packages = with pkgs; [
        dotnet-sdk
        msbuild
      ];
    };
  };
}
