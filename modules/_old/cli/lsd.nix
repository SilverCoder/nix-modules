{ config, lib, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.lsd;
in
{
  options.modules.cli.lsd = {
    enable = lib.mkEnableOption "lsd (ls alternative with icons)" // { default = true; };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs = {
      lsd = {
        enable = true;
      };
    };
  };
}
