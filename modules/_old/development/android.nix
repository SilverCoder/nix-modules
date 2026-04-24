{ config, lib, pkgs, ... }:
let
  developmentCfg = config.modules.development;
  cfg = config.modules.development.android;
in
{
  options.modules.development.android = {
    enable = lib.mkEnableOption "Android development tools" // { default = true; };
  };

  config = lib.mkIf (developmentCfg.enable && cfg.enable) {
    home = {
      packages = with pkgs; [
        android-studio
      ];
    };
  };
}
