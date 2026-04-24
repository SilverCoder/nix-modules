{ config, lib, ... }:
let
  cliCfg = config.modules.cli;
  cfg = config.modules.cli.bat;
in
{
  options.modules.cli.bat = {
    enable = lib.mkEnableOption "bat (cat alternative with syntax highlighting)" // { default = true; };
  };

  config = lib.mkIf (cliCfg.enable && cfg.enable) {
    programs = {
      bat = {
        enable = true;
      };
    };
  };
}
